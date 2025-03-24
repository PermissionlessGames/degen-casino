// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {MultipleCurrencyToken} from "../src/token/ERC20/MultipleCurrencyToken.sol";
import {IMultipleCurrencyToken} from "../src/token/ERC20/interfaces/IMultipleCurrencyToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {MockERC20} from "../src/dev/mock/MockERC20.sol";
import {MockERC1155} from "../src/dev/mock/MockERC1155.sol";
import {CreatePricingDataParams, MCTTokens} from "../src/token/ERC20/structs/MCTStructs.sol";

contract MultipleCurrencyTokenTest is Test {
    MultipleCurrencyToken mct;
    MockERC20 mockUsdt;
    MockERC20 mockUsdc;
    MockERC1155 mockGold;

    address constant INATIVE = address(0x1);
    uint256 constant GOLD_TOKEN_ID = 1;

    address user1;
    address user2;

    event NewPricingDataAdded(CreatePricingDataParams pricingData);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
        // Deploy mock tokens
        mockUsdt = new MockERC20("USDT", "USDT");
        mockUsdc = new MockERC20("USDC", "USDC");
        mockGold = new MockERC1155("GOLD");

        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        // Mint initial tokens to users
        mockUsdt.mint(user1, 1000e18);
        mockUsdc.mint(user1, 1000e18);
        mockGold.mint(user1, GOLD_TOKEN_ID, 10);
        vm.deal(user1, 100 ether);

        mockUsdt.mint(user2, 1000e18);
        mockUsdc.mint(user2, 1000e18);
        mockGold.mint(user2, GOLD_TOKEN_ID, 10);
        vm.deal(user2, 100 ether);

        // Create initial currencies array for constructor
        CreatePricingDataParams[]
            memory initialCurrencies = new CreatePricingDataParams[](4);

        // ETH as anchor currency
        initialCurrencies[0] = CreatePricingDataParams({
            currency: INATIVE,
            price: 1e18, // 1 ETH = 1 token
            decimalCount: 18,
            is1155: false,
            tokenId: 0
        });

        // USDT
        initialCurrencies[1] = CreatePricingDataParams({
            currency: address(mockUsdt),
            price: 1e6, // 1 USDT = 0.001 token
            decimalCount: 6,
            is1155: false,
            tokenId: 0
        });

        // USDC
        initialCurrencies[2] = CreatePricingDataParams({
            currency: address(mockUsdc),
            price: 1e6, // 1 USDC = 0.001 token
            decimalCount: 6,
            is1155: false,
            tokenId: 0
        });

        // GOLD
        initialCurrencies[3] = CreatePricingDataParams({
            currency: address(mockGold),
            price: 5e17, // 1 GOLD = 0.5 token
            decimalCount: 0,
            is1155: true,
            tokenId: GOLD_TOKEN_ID
        });

        // Deploy MCT
        mct = new MultipleCurrencyToken(
            "Multiple Currency Token",
            "MCT",
            INATIVE,
            5, // 5% adjustment
            100,
            initialCurrencies
        );
    }

    // Constructor Tests
    function testConstructorInitialization() public view {
        assertEq(mct.name(), "Multiple Currency Token");
        assertEq(mct.symbol(), "MCT");
        assertEq(mct.INATIVE(), INATIVE);

        // Check initial token setup
        CreatePricingDataParams memory token0 = mct.tokens(0);
        assertEq(token0.currency, INATIVE);
        assertEq(token0.price, 1e18);
        assertFalse(token0.is1155);
        assertEq(token0.tokenId, 0);
    }

    function testConstructorEvents() public {
        CreatePricingDataParams[]
            memory initialCurrencies = new CreatePricingDataParams[](2);
        initialCurrencies[0] = CreatePricingDataParams({
            currency: INATIVE,
            price: 1e18,
            decimalCount: 18,
            is1155: false,
            tokenId: 0
        });
        initialCurrencies[1] = CreatePricingDataParams({
            currency: address(mockUsdt),
            price: 1e6,
            decimalCount: 6,
            is1155: false,
            tokenId: 0
        });

        vm.expectEmit(true, true, true, true);
        emit NewPricingDataAdded(initialCurrencies[1]);

        new MultipleCurrencyToken(
            "Test Token",
            "TEST",
            INATIVE,
            5,
            100,
            initialCurrencies
        );
    }

    // Additional Constructor Tests
    function testRevertConstructorWithEmptyCurrencies() public {
        CreatePricingDataParams[]
            memory emptyCurrencies = new CreatePricingDataParams[](0);
        vm.expectRevert("Must provide at least one currency");
        new MultipleCurrencyToken(
            "Test Token",
            "TEST",
            INATIVE,
            5,
            100,
            emptyCurrencies
        );
    }

    function testRevertConstructorWithZeroPrice() public {
        CreatePricingDataParams[]
            memory currencies = new CreatePricingDataParams[](1);
        currencies[0] = CreatePricingDataParams({
            currency: INATIVE,
            price: 0,
            decimalCount: 18,
            is1155: false,
            tokenId: 0
        });

        vm.expectRevert("Anchor price must be greater than 0");
        new MultipleCurrencyToken(
            "Test Token",
            "TEST",
            INATIVE,
            5,
            100,
            currencies
        );
    }

    // Deposit Tests
    function testDepositETH() public {
        vm.startPrank(user1);

        MCTTokens memory currency;
        currency.currency = INATIVE;
        currency.tokenId = 0;
        currency.is1155 = false;

        uint256 amount = 1e18;

        uint256 expectedMintAmount = mct.estimateDepositAmount(
            currency,
            amount
        );
        assertGt(
            expectedMintAmount,
            0,
            "Expected mint amount should be greater than 0"
        );

        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), user1, expectedMintAmount);

        uint256 mintAmount = mct.deposit{value: 1e18}(currency, amount);

        assertEq(mintAmount, expectedMintAmount);
        assertEq(mct.balanceOf(user1), expectedMintAmount);

        vm.stopPrank();
    }

    function testDepositERC20() public {
        vm.startPrank(user1);

        mockUsdt.approve(address(mct), 1000e18);

        MCTTokens memory currency;
        currency.currency = address(mockUsdt);
        currency.tokenId = 0;
        currency.is1155 = false;

        uint256 amount = 100e18;

        uint256 expectedMintAmount = mct.estimateDepositAmount(
            currency,
            amount
        );

        uint256 mintAmount = mct.deposit(currency, amount);

        assertEq(mintAmount, expectedMintAmount);
        assertEq(mct.balanceOf(user1), expectedMintAmount);
        assertEq(mockUsdt.balanceOf(address(mct)), 100e18);

        vm.stopPrank();
    }

    function testDepositERC1155() public {
        vm.startPrank(user1);

        mockGold.setApprovalForAll(address(mct), true);

        MCTTokens memory currency;
        currency.currency = address(mockGold);
        currency.tokenId = GOLD_TOKEN_ID;
        currency.is1155 = true;

        uint256 amount = 1;

        uint256 expectedMintAmount = mct.estimateDepositAmount(
            currency,
            amount
        );

        uint256 mintAmount = mct.deposit(currency, amount);

        assertEq(mintAmount, expectedMintAmount);
        assertEq(mct.balanceOf(user1), expectedMintAmount);
        assertEq(mockGold.balanceOf(address(mct), GOLD_TOKEN_ID), 1);

        vm.stopPrank();
    }

    // Withdraw Tests
    function testWithdrawETH() public {
        // First deposit some ETH
        vm.startPrank(user1);
        MCTTokens memory currency;
        currency.currency = INATIVE;
        currency.tokenId = 0;
        currency.is1155 = false;
        uint256 amount = 1e18;
        uint256 mintAmount = mct.deposit{value: 1e18}(currency, amount);
        vm.stopPrank();

        // Now withdraw
        vm.startPrank(user1);
        uint256 withdrawAmount = mct.withdraw(currency, mintAmount);
        vm.stopPrank();

        assertEq(withdrawAmount, 1e18);
        assertEq(address(mct).balance, 0);
        assertEq(mct.balanceOf(user1), 0);
    }

    function testWithdrawERC20() public {
        // First deposit some USDT
        vm.startPrank(user1);
        mockUsdt.approve(address(mct), 1000e18);
        MCTTokens memory currency;
        currency.currency = address(mockUsdt);
        currency.tokenId = 0;
        currency.is1155 = false;
        uint256 amount = 100e18;
        uint256 mintAmount = mct.deposit(currency, amount);
        vm.stopPrank();

        // Now withdraw
        vm.startPrank(user1);
        uint256 withdrawAmount = mct.withdraw(currency, mintAmount);
        vm.stopPrank();

        assertEq(withdrawAmount, 100e18);
        assertEq(mockUsdt.balanceOf(address(mct)), 0);
        assertEq(mct.balanceOf(user1), 0);
    }

    function testWithdrawERC1155() public {
        // First deposit some GOLD
        vm.startPrank(user1);
        mockGold.setApprovalForAll(address(mct), true);
        MCTTokens memory currency;
        currency.currency = address(mockGold);
        currency.tokenId = GOLD_TOKEN_ID;
        currency.is1155 = true;
        uint256 amount = 1;
        uint256 mintAmount = mct.deposit(currency, amount);
        vm.stopPrank();

        // Now withdraw
        vm.startPrank(user1);
        uint256 withdrawAmount = mct.withdraw(currency, mintAmount);
        vm.stopPrank();

        assertEq(withdrawAmount, 1);
        assertEq(mockGold.balanceOf(address(mct), GOLD_TOKEN_ID), 0);
        assertEq(mct.balanceOf(user1), 0);
    }

    // Price Adjustment Tests
    function testPriceAdjustment() public {
        // First deposit some USDT
        vm.startPrank(user1);
        mockUsdt.approve(address(mct), 1000e18);
        MCTTokens memory currency;
        currency.currency = address(mockUsdt);
        currency.tokenId = 0;
        currency.is1155 = false;
        uint256 amount = 100e18;
        uint256 mintAmount = mct.deposit(currency, amount);
        vm.stopPrank();

        // Now withdraw some USDT
        vm.startPrank(user1);
        uint256 withdrawAmount = mct.withdraw(currency, mintAmount / 2);
        vm.stopPrank();

        // The price should have been adjusted
        assertEq(withdrawAmount, 50e18);
        assertEq(mockUsdt.balanceOf(address(mct)), 50e18);
        assertEq(mct.balanceOf(user1), mintAmount / 2);
    }

    // Error Tests
    function testRevertDepositWithInsufficientValue() public {
        vm.startPrank(user1);
        MCTTokens memory currency;
        currency.currency = INATIVE;
        currency.tokenId = 0;
        currency.is1155 = false;
        uint256 amount = 1e18;

        vm.expectRevert("Insufficient native value");
        mct.deposit{value: 0.5e18}(currency, amount);
        vm.stopPrank();
    }

    function testRevertWithdrawWithInsufficientBalance() public {
        vm.startPrank(user1);
        MCTTokens memory currency;
        currency.currency = INATIVE;
        currency.tokenId = 0;
        currency.is1155 = false;
        vm.expectRevert("Insufficient balance");
        mct.withdraw(currency, 1e18);
        vm.stopPrank();
    }

    function testRevertWithdrawWithInvalidCurrency() public {
        // First deposit some ETH to get MCT tokens
        vm.startPrank(user1);
        MCTTokens memory validCurrency;
        validCurrency.currency = INATIVE;
        validCurrency.tokenId = 0;
        validCurrency.is1155 = false;
        uint256 amount = 1e18;
        uint256 mintAmount = mct.deposit{value: 1e18}(validCurrency, amount);
        vm.stopPrank();

        // Now attempt to withdraw with invalid currency
        vm.startPrank(user1);
        MCTTokens memory invalidCurrency;
        invalidCurrency.currency = address(0x123);
        invalidCurrency.tokenId = 0;
        invalidCurrency.is1155 = false;

        vm.expectRevert("Currency price not set");
        mct.withdraw(invalidCurrency, mintAmount);
        vm.stopPrank();
    }

    // Add receive function to handle ETH transfers
    receive() external payable {}
}
