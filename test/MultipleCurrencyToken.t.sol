// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {MultipleCurrencyToken} from "../src/token/ERC20/MultipleCurrencyToken.sol";
import {IMultipleCurrencyToken} from "../src/token/ERC20/interfaces/IMultipleCurrencyToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {MockERC20} from "../src/dev/mock/MockERC20.sol";
import {MockERC1155} from "../src/dev/mock/MockERC1155.sol";

contract MultipleCurrencyTokenTest is Test {
    MultipleCurrencyToken mct;
    MockERC20 mockUsdt;
    MockERC20 mockUsdc;
    MockERC1155 mockGold;

    address constant INATIVE = address(0x1);
    uint256 constant GOLD_TOKEN_ID = 1;

    address user1;
    address user2;

    event NewPricingDataAdded(
        IMultipleCurrencyToken.CreatePricingDataParams pricingData
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
        // Deploy mock tokens
        mockUsdt = new MockERC20("USDT", "USDT");
        mockUsdc = new MockERC20("USDC", "USDC");
        mockGold = new MockERC1155("URI");

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
        IMultipleCurrencyToken.CreatePricingDataParams[]
            memory initialCurrencies = new IMultipleCurrencyToken.CreatePricingDataParams[](
                4
            );

        // ETH as anchor currency
        initialCurrencies[0] = IMultipleCurrencyToken.CreatePricingDataParams({
            currency: INATIVE,
            price: 1e18, // 1 ETH = 1 token
            is1155: false,
            tokenId: 0
        });

        // USDT
        initialCurrencies[1] = IMultipleCurrencyToken.CreatePricingDataParams({
            currency: address(mockUsdt),
            price: 1e6, // 1 USDT = 0.001 token
            is1155: false,
            tokenId: 0
        });

        // USDC
        initialCurrencies[2] = IMultipleCurrencyToken.CreatePricingDataParams({
            currency: address(mockUsdc),
            price: 1e6, // 1 USDC = 0.001 token
            is1155: false,
            tokenId: 0
        });

        // GOLD
        initialCurrencies[3] = IMultipleCurrencyToken.CreatePricingDataParams({
            currency: address(mockGold),
            price: 5e17, // 1 GOLD = 0.5 token
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
        IMultipleCurrencyToken.CreatePricingDataParams memory token0 = mct
            .tokens(0);
        assertEq(token0.currency, INATIVE);
        assertEq(token0.price, 1e18);
        assertFalse(token0.is1155);
        assertEq(token0.tokenId, 0);
    }

    function testConstructorEvents() public {
        IMultipleCurrencyToken.CreatePricingDataParams[]
            memory initialCurrencies = new IMultipleCurrencyToken.CreatePricingDataParams[](
                2
            );
        initialCurrencies[0] = IMultipleCurrencyToken.CreatePricingDataParams({
            currency: INATIVE,
            price: 1e18,
            is1155: false,
            tokenId: 0
        });
        initialCurrencies[1] = IMultipleCurrencyToken.CreatePricingDataParams({
            currency: address(mockUsdt),
            price: 1e6,
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

    // Deposit Tests
    function testDepositETH() public {
        vm.startPrank(user1);

        address[] memory currencies = new address[](1);
        currencies[0] = INATIVE;

        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 0;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 1 ether;

        uint256 expectedMintAmount = mct.estimateDepositAmount(
            currencies,
            tokenIds,
            amounts
        );

        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), user1, expectedMintAmount);

        uint256 mintAmount = mct.deposit{value: 1 ether}(
            currencies,
            tokenIds,
            amounts
        );

        assertEq(mintAmount, expectedMintAmount);
        assertEq(mct.balanceOf(user1), expectedMintAmount);

        vm.stopPrank();
    }

    function testDepositERC20() public {
        vm.startPrank(user1);

        mockUsdt.approve(address(mct), 1000e18);

        address[] memory currencies = new address[](1);
        currencies[0] = address(mockUsdt);

        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 0;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 100e18;

        uint256 expectedMintAmount = mct.estimateDepositAmount(
            currencies,
            tokenIds,
            amounts
        );

        uint256 mintAmount = mct.deposit(currencies, tokenIds, amounts);

        assertEq(mintAmount, expectedMintAmount);
        assertEq(mct.balanceOf(user1), expectedMintAmount);
        assertEq(mockUsdt.balanceOf(address(mct)), 100e18);

        vm.stopPrank();
    }

    function testDepositERC1155() public {
        vm.startPrank(user1);

        mockGold.setApprovalForAll(address(mct), true);

        address[] memory currencies = new address[](1);
        currencies[0] = address(mockGold);

        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = GOLD_TOKEN_ID;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 1;

        uint256 expectedMintAmount = mct.estimateDepositAmount(
            currencies,
            tokenIds,
            amounts
        );

        uint256 mintAmount = mct.deposit(currencies, tokenIds, amounts);

        assertEq(mintAmount, expectedMintAmount);
        assertEq(mct.balanceOf(user1), expectedMintAmount);
        assertEq(mockGold.balanceOf(address(mct), GOLD_TOKEN_ID), 1);

        vm.stopPrank();
    }

    function testDepositMultipleTokens() public {
        vm.startPrank(user1);

        mockUsdt.approve(address(mct), 1000e18);
        mockGold.setApprovalForAll(address(mct), true);

        address[] memory currencies = new address[](3);
        currencies[0] = INATIVE;
        currencies[1] = address(mockUsdt);
        currencies[2] = address(mockGold);

        uint256[] memory tokenIds = new uint256[](3);
        tokenIds[0] = 0;
        tokenIds[1] = 0;
        tokenIds[2] = GOLD_TOKEN_ID;

        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 1 ether;
        amounts[1] = 100e18;
        amounts[2] = 1;

        uint256 expectedMintAmount = mct.estimateDepositAmount(
            currencies,
            tokenIds,
            amounts
        );

        uint256 mintAmount = mct.deposit{value: 1 ether}(
            currencies,
            tokenIds,
            amounts
        );

        assertEq(mintAmount, expectedMintAmount);
        assertEq(mct.balanceOf(user1), expectedMintAmount);

        vm.stopPrank();
    }

    // Withdraw Tests
    function testWithdrawETH() public {
        // First deposit
        vm.startPrank(user1);
        address[] memory currencies = new address[](1);
        currencies[0] = INATIVE;

        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 0;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 1 ether;
        // Deposit ETH
        uint256 mintAmount = mct.deposit{value: 1 ether}(
            currencies,
            tokenIds,
            amounts
        );
        assertEq(mct.balanceOf(user1), mintAmount);
        // Record balance before withdrawal
        uint256 preWithdrawBalance = user1.balance;
        console.log("Line 298");
        // Withdraw ETH
        uint256 withdrawAmount = mct.withdraw(INATIVE, 0, mintAmount);
        console.log("Line 301");
        // Check results
        assertEq(withdrawAmount, 1 ether, "Withdraw amount should be 1 ether");
        assertEq(
            mct.balanceOf(user1),
            0,
            "User should have 0 tokens after withdrawal"
        );
        assertGt(
            user1.balance,
            preWithdrawBalance,
            "User should have received ETH"
        );

        vm.stopPrank();
    }

    function testWithdrawERC20() public {
        // First deposit
        vm.startPrank(user1);

        mockUsdt.approve(address(mct), 1000e18);

        address[] memory currencies = new address[](1);
        currencies[0] = address(mockUsdt);

        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 0;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 100e18;

        uint256 mintAmount = mct.deposit(currencies, tokenIds, amounts);

        // Then withdraw
        uint256 balanceBefore = mockUsdt.balanceOf(user1);
        uint256 withdrawAmount = mct.withdraw(address(mockUsdt), 0, mintAmount);

        assertEq(mockUsdt.balanceOf(user1) - balanceBefore, withdrawAmount);
        assertEq(mct.balanceOf(user1), 0);

        vm.stopPrank();
    }

    function testWithdrawERC1155() public {
        // First deposit
        vm.startPrank(user1);

        mockGold.setApprovalForAll(address(mct), true);

        address[] memory currencies = new address[](1);
        currencies[0] = address(mockGold);

        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = GOLD_TOKEN_ID;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 1;

        uint256 mintAmount = mct.deposit(currencies, tokenIds, amounts);

        // Then withdraw
        uint256 balanceBefore = mockGold.balanceOf(user1, GOLD_TOKEN_ID);
        uint256 withdrawAmount = mct.withdraw(
            address(mockGold),
            GOLD_TOKEN_ID,
            mintAmount
        );

        assertEq(
            mockGold.balanceOf(user1, GOLD_TOKEN_ID) - balanceBefore,
            withdrawAmount
        );
        assertEq(mct.balanceOf(user1), 0);

        vm.stopPrank();
    }

    // Price Adjustment Tests
    function testPriceAdjustmentOnDeposit() public {
        vm.startPrank(user1);

        mockUsdt.approve(address(mct), 1000e18);

        address[] memory currencies = new address[](1);
        currencies[0] = address(mockUsdt);

        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 0;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 100e18;

        uint256 initialPrice = mct.getMintPrice(
            mct.encodeCurrency(address(mockUsdt), 0, false)
        );
        mct.deposit(currencies, tokenIds, amounts);
        uint256 newPrice = mct.getMintPrice(
            mct.encodeCurrency(address(mockUsdt), 0, false)
        );

        assertGt(newPrice, initialPrice);

        vm.stopPrank();
    }

    function testPriceAdjustmentOnWithdraw() public {
        // First deposit
        vm.startPrank(user1);

        mockUsdt.approve(address(mct), 1000e18);

        address[] memory currencies = new address[](1);
        currencies[0] = address(mockUsdt);

        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 0;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 100e18;

        uint256 mintAmount = mct.deposit(currencies, tokenIds, amounts);

        uint256 initialPrice = mct.getRedeemPrice(
            mct.encodeCurrency(address(mockUsdt), 0, false)
        );
        mct.withdraw(address(mockUsdt), 0, mintAmount);
        uint256 newPrice = mct.getRedeemPrice(
            mct.encodeCurrency(address(mockUsdt), 0, false)
        );

        assertLt(newPrice, initialPrice);

        vm.stopPrank();
    }

    // Failure Tests
    function testFailDepositZeroAmount() public {
        vm.startPrank(user1);

        address[] memory currencies = new address[](1);
        currencies[0] = INATIVE;

        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 0;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 0;

        mct.deposit{value: 0}(currencies, tokenIds, amounts);

        vm.stopPrank();
    }

    function testFailDepositMismatchedArrayLengths() public {
        vm.startPrank(user1);

        address[] memory currencies = new address[](1);
        currencies[0] = INATIVE;

        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 0;
        tokenIds[1] = 0;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 1 ether;

        mct.deposit{value: 1 ether}(currencies, tokenIds, amounts);

        vm.stopPrank();
    }

    function testFailWithdrawZeroAmount() public {
        vm.startPrank(user1);
        mct.withdraw(INATIVE, 0, 0);
        vm.stopPrank();
    }

    function testFailWithdrawInsufficientBalance() public {
        vm.startPrank(user1);
        mct.withdraw(INATIVE, 0, 1e18);
        vm.stopPrank();
    }

    // View Function Tests
    function testEncodeCurrency() public view {
        bytes memory encoded = mct.encodeCurrency(address(mockUsdt), 0, false);
        assertGt(encoded.length, 0);
    }

    function testGetMintPrice() public view {
        uint256 price = mct.getMintPrice(mct.encodeCurrency(INATIVE, 0, false));
        assertEq(price, 1e18);
    }

    function testGetRedeemPrice() public view {
        uint256 price = mct.getRedeemPrice(
            mct.encodeCurrency(INATIVE, 0, false)
        );
        assertEq(price, 1e18);
    }

    function testGetTokens() public view {
        (
            address[] memory currencies,
            uint256[] memory tokenIds,
            bool[] memory is1155
        ) = mct.getTokens();

        assertEq(currencies.length, 4);
        assertEq(tokenIds.length, 4);
        assertEq(is1155.length, 4);

        assertEq(currencies[0], INATIVE);
        assertEq(currencies[1], address(mockUsdt));
        assertEq(currencies[2], address(mockUsdc));
        assertEq(currencies[3], address(mockGold));
    }

    receive() external payable {}
}
