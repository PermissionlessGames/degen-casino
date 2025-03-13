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

    // Additional Constructor Tests
    function testFailConstructorWithEmptyCurrencies() public {
        IMultipleCurrencyToken.CreatePricingDataParams[]
            memory emptyCurrencies = new IMultipleCurrencyToken.CreatePricingDataParams[](
                0
            );
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

    function testFailConstructorWithZeroPrice() public {
        IMultipleCurrencyToken.CreatePricingDataParams[]
            memory currencies = new IMultipleCurrencyToken.CreatePricingDataParams[](
                1
            );
        currencies[0] = IMultipleCurrencyToken.CreatePricingDataParams({
            currency: INATIVE,
            price: 0,
            is1155: false,
            tokenId: 0
        });

        vm.expectRevert("Price must be greater than zero");
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

    // Additional Deposit Tests
    function testDepositWithMaxAmount() public {
        vm.startPrank(user1);

        address[] memory currencies = new address[](1);
        currencies[0] = INATIVE;

        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 0;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = type(uint128).max; // Using uint128 to avoid overflow in calculations

        vm.deal(user1, amounts[0]); // Give user enough ETH

        uint256 expectedMintAmount = mct.estimateDepositAmount(
            currencies,
            tokenIds,
            amounts
        );
        uint256 mintAmount = mct.deposit{value: amounts[0]}(
            currencies,
            tokenIds,
            amounts
        );

        assertEq(mintAmount, expectedMintAmount);
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
        // Withdraw ETH
        uint256 withdrawAmount = mct.withdraw(INATIVE, 0, mintAmount);
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

    // Additional Withdraw Tests
    function testPartialWithdraw() public {
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

        // Partial withdraw
        uint256 withdrawAmount = mct.withdraw(
            address(mockUsdt),
            0,
            mintAmount / 2
        );
        assertEq(mct.balanceOf(user1), mintAmount / 2);
        assertEq(withdrawAmount, 50e18);

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

    // Price Estimation Tests
    function testEstimateWithMultipleCurrencies() public view {
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
        amounts[1] = 1000e18;
        amounts[2] = 2;

        uint256 estimate = mct.estimateDepositAmount(
            currencies,
            tokenIds,
            amounts
        );
        assertGt(estimate, 0);
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

    // Additional Failure Tests
    function testFailDepositWithInvalidCurrency() public {
        vm.startPrank(user1);

        address[] memory currencies = new address[](1);
        currencies[0] = address(0);

        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 0;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 1 ether;

        mct.deposit(currencies, tokenIds, amounts);
        vm.stopPrank();
    }

    function testFailWithdrawToZeroAddress() public {
        vm.startPrank(address(0));
        mct.withdraw(INATIVE, 0, 1 ether);
        vm.stopPrank();
    }

    function testFailDepositWithMismatchedValue() public {
        vm.startPrank(user1);

        address[] memory currencies = new address[](1);
        currencies[0] = INATIVE;

        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 0;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 2 ether;

        // This should fail because we're sending less ETH than specified in amounts
        mct.deposit{value: 1 ether}(currencies, tokenIds, amounts);
        assertEq(mct.balanceOf(user1), 0);
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

    // Token Management Tests
    function testGetTokenAtIndex() public view {
        IMultipleCurrencyToken.CreatePricingDataParams memory token;

        // Check each token
        token = mct.tokens(0);
        assertEq(token.currency, INATIVE);

        token = mct.tokens(1);
        assertEq(token.currency, address(mockUsdt));

        token = mct.tokens(2);
        assertEq(token.currency, address(mockUsdc));

        token = mct.tokens(3);
        assertEq(token.currency, address(mockGold));
    }

    function testFailGetTokenAtInvalidIndex() public view {
        mct.tokens(4); // Should revert as we only have 4 tokens (0-3)
    }

    // Price Adjustment Edge Cases
    function testPriceAdjustmentWithMinimumAmount() public {
        vm.startPrank(user1);
        mockUsdt.approve(address(mct), 1e6);

        address[] memory currencies = new address[](1);
        currencies[0] = address(mockUsdt);

        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 0;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 1; // Minimum possible amount

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

    function testDoesCurrencyExist() public view {
        bool exists = mct.doesCurrencyExist(address(mockUsdt), 0, false);
        assertTrue(exists, "USDT should exist");
        exists = mct.doesCurrencyExist(address(mockUsdt), 1, true);
        assertFalse(exists, "USDT should not exist as 1155");
    }

    function testAmountNeededToMint() public view {
        (uint256 amount, bool exists) = mct.amountNeededToMint(
            100e18,
            address(mockUsdt),
            0,
            false
        );
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;
        address[] memory currencies = new address[](1);
        currencies[0] = address(mockUsdt);
        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 0;
        uint256 estimatedAmount = mct.estimateDepositAmount(
            currencies,
            tokenIds,
            amounts
        );
        assertEq(100e18, estimatedAmount, "Amount should be estimated amount");
        assertTrue(exists, "USDT should exist");
    }

    function testAmountNeededToMintNoCurrency() public view {
        (uint256 amount, bool exists) = mct.amountNeededToMint(
            100e18,
            address(0),
            0,
            false
        );
        assertEq(amount, 0, "Amount should be 0");
        assertFalse(exists, "Currency should not exist");
    }

    // Price Ratio Tests
    function testGetTokenPriceRatiosSingleCurrency() public view {
        address[] memory currencies = new address[](1);
        currencies[0] = INATIVE;

        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 0;

        (uint256[] memory mintRatios, uint256[] memory redeemRatios) = mct
            .getTokenPriceRatios(currencies, tokenIds);

        assertEq(mintRatios.length, 1);
        assertEq(redeemRatios.length, 1);
        assertEq(mintRatios[0], 1e18);
        assertEq(redeemRatios[0], 1e18);
    }

    function testGetTokenPriceRatiosMultipleCurrencies() public view {
        address[] memory currencies = new address[](2);
        currencies[0] = INATIVE;
        currencies[1] = address(mockUsdt);

        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 0;
        tokenIds[1] = 0;

        (uint256[] memory mintRatios, uint256[] memory redeemRatios) = mct
            .getTokenPriceRatios(currencies, tokenIds);

        assertEq(mintRatios.length, 2);
        assertEq(redeemRatios.length, 2);
        // Check INATIVE ratios
        assertEq(mintRatios[0], 1e18);
        assertEq(redeemRatios[0], 1e18);
        // Check USDT ratios
        assertEq(mintRatios[1], 1e6);
        assertEq(redeemRatios[1], 1e6);
    }

    function testGetTokenPriceRatiosAfterPriceChange() public {
        // First make a deposit to change prices
        vm.startPrank(user1);
        mockUsdt.approve(address(mct), 1000e18);

        address[] memory depositCurrencies = new address[](1);
        depositCurrencies[0] = address(mockUsdt);

        uint256[] memory depositTokenIds = new uint256[](1);
        depositTokenIds[0] = 0;

        uint256[] memory depositAmounts = new uint256[](1);
        depositAmounts[0] = 100e18;

        mct.deposit(depositCurrencies, depositTokenIds, depositAmounts);
        vm.stopPrank();

        // Now check price ratios
        address[] memory currencies = new address[](1);
        currencies[0] = address(mockUsdt);

        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 0;

        (uint256[] memory mintRatios, uint256[] memory redeemRatios) = mct
            .getTokenPriceRatios(currencies, tokenIds);

        assertGt(mintRatios[0], 1e6); // Price should have increased
        assertEq(redeemRatios[0], 1e6); // Redeem price should stay the same
    }

    // Additional Price Adjustment Tests
    function testPriceAdjustmentWithAnchorCurrency() public {
        vm.startPrank(user1);

        // First deposit with anchor currency (ETH)
        address[] memory currencies = new address[](1);
        currencies[0] = INATIVE;

        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 0;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 1 ether;

        bytes memory currency = mct.encodeCurrency(address(mockUsdt), 0, false);

        assertEq(
            mct.getMintPrice(currency),
            mct.getRedeemPrice(currency),
            "Mint price should be equal to redeem price"
        );

        // Deposit ETH
        mct.deposit{value: 1 ether}(currencies, tokenIds, amounts);

        assertGt(
            mct.getMintPrice(currency),
            mct.getRedeemPrice(currency),
            "Mint price should be greater than redeem price"
        );

        vm.stopPrank();
    }

    function testPriceAdjustmentWithMultipleDeposits() public {
        vm.startPrank(user1);
        mockUsdt.approve(address(mct), 1000e18);
        mockGold.setApprovalForAll(address(mct), true);

        address[] memory currencies = new address[](2);
        currencies[0] = address(mockUsdt);
        currencies[1] = address(mockGold);

        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 0;
        tokenIds[1] = GOLD_TOKEN_ID;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 100e18;
        amounts[1] = 1;

        uint256 initialUsdtPrice = mct.getMintPrice(
            mct.encodeCurrency(address(mockUsdt), 0, false)
        );
        uint256 initialGoldPrice = mct.getMintPrice(
            mct.encodeCurrency(address(mockGold), GOLD_TOKEN_ID, true)
        );

        mct.deposit(currencies, tokenIds, amounts);

        uint256 newUsdtPrice = mct.getMintPrice(
            mct.encodeCurrency(address(mockUsdt), 0, false)
        );
        uint256 newGoldPrice = mct.getMintPrice(
            mct.encodeCurrency(address(mockGold), GOLD_TOKEN_ID, true)
        );

        assertGt(newUsdtPrice, initialUsdtPrice, "USDT price should increase");
        assertGt(newGoldPrice, initialGoldPrice, "GOLD price should increase");

        vm.stopPrank();
    }

    // Array Validation Tests
    function testGetTokenPriceRatiosEmptyArrays() public view {
        address[] memory currencies = new address[](0);
        uint256[] memory tokenIds = new uint256[](0);
        (uint256[] memory mintRatios, uint256[] memory redeemRatios) = mct
            .getTokenPriceRatios(currencies, tokenIds);
        assertEq(mintRatios.length, 0);
        assertEq(redeemRatios.length, 0);
    }

    function testFailGetTokenPriceRatiosMismatchedArrays() public view {
        address[] memory currencies = new address[](2);
        currencies[0] = INATIVE;
        currencies[1] = address(mockUsdt);

        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 0;

        mct.getTokenPriceRatios(currencies, tokenIds);
    }

    function testFailDepositEmptyArrays() public {
        vm.startPrank(user1);

        address[] memory currencies = new address[](0);
        uint256[] memory tokenIds = new uint256[](0);
        uint256[] memory amounts = new uint256[](0);

        mct.deposit(currencies, tokenIds, amounts);

        vm.stopPrank();
    }

    // Additional Withdrawal Price Adjustment Tests
    function testPriceAdjustmentOnAnchorWithdraw() public {
        // First deposit
        vm.startPrank(user1);
        address[] memory currencies = new address[](2);
        currencies[0] = INATIVE;
        currencies[1] = address(mockUsdt);
        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 0;
        tokenIds[1] = 0;
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 1 ether;
        amounts[1] = 100e18;
        bytes memory currency = mct.encodeCurrency(address(mockUsdt), 0, false);
        assertEq(
            mct.getRedeemPrice(currency),
            mct.getMintPrice(currency),
            "Initial price should be equal to mint price"
        );

        IERC20(address(mockUsdt)).approve(address(mct), 1000e18);

        uint256 mintAmount = mct.deposit{value: 1 ether}(
            currencies,
            tokenIds,
            amounts
        );

        assertGt(
            mct.getMintPrice(currency),
            mct.getRedeemPrice(currency),
            "Mint price should be greater than redeem price"
        );

        // Withdraw ETH
        mct.withdraw(INATIVE, 0, mintAmount);

        assertGt(
            mct.getMintPrice(currency),
            mct.getRedeemPrice(currency),
            "Mint price should be greater than redeem price"
        );

        vm.stopPrank();
    }

    function testPriceAdjustmentWithMultipleWithdraws() public {
        // First deposit multiple currencies
        vm.startPrank(user1);
        mockUsdt.approve(address(mct), 1000e18);
        mockGold.setApprovalForAll(address(mct), true);

        address[] memory currencies = new address[](2);
        currencies[0] = address(mockUsdt);
        currencies[1] = address(mockGold);

        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 0;
        tokenIds[1] = GOLD_TOKEN_ID;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 100e18;
        amounts[1] = 1;

        uint256 mintAmount = mct.deposit(currencies, tokenIds, amounts);

        // Get prices after deposit
        uint256 postDepositUsdtPrice = mct.getRedeemPrice(
            mct.encodeCurrency(address(mockUsdt), 0, false)
        );
        uint256 postDepositGoldPrice = mct.getRedeemPrice(
            mct.encodeCurrency(address(mockGold), GOLD_TOKEN_ID, true)
        );

        // Withdraw half of each
        mct.withdraw(address(mockUsdt), 0, mintAmount / 2);
        mct.withdraw(address(mockGold), GOLD_TOKEN_ID, mintAmount / 2);

        // Check price adjustments
        uint256 postWithdrawUsdtPrice = mct.getRedeemPrice(
            mct.encodeCurrency(address(mockUsdt), 0, false)
        );
        uint256 postWithdrawGoldPrice = mct.getRedeemPrice(
            mct.encodeCurrency(address(mockGold), GOLD_TOKEN_ID, true)
        );

        assertLt(
            postWithdrawUsdtPrice,
            postDepositUsdtPrice,
            "USDT price should decrease after withdrawal"
        );
        assertLt(
            postWithdrawGoldPrice,
            postDepositGoldPrice,
            "GOLD price should decrease after withdrawal"
        );

        vm.stopPrank();
    }

    // Balance Limit Tests
    function testWithdrawNearContractBalance() public {
        // First deposit
        vm.startPrank(user1);
        mockUsdt.approve(address(mct), 1000e18);
        mockGold.setApprovalForAll(address(mct), true);
        address[] memory currencies = new address[](2);
        currencies[0] = address(mockUsdt);
        currencies[1] = address(mockGold);

        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 0;
        tokenIds[1] = GOLD_TOKEN_ID;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 100e18;
        amounts[1] = 1;
        mct.deposit(currencies, tokenIds, amounts);

        // Try to withdraw slightly more than deposited
        uint256 withdrawAmount = mct.withdraw(
            address(mockUsdt),
            0,
            mct.balanceOf(user1)
        );

        assertEq(
            withdrawAmount,
            100e18,
            "Should only withdraw available balance"
        );
        assertEq(mct.balanceOf(user1), 0, "User should have 0");
        assertEq(
            mockUsdt.balanceOf(address(mct)),
            0,
            "Contract should have 0 USDT"
        );
        assertEq(
            mockGold.balanceOf(address(mct), GOLD_TOKEN_ID),
            1,
            "Contract should have 1 GOLD"
        );
        assertEq(mct.totalSupply(), 0, "Total supply should be 0");
        vm.stopPrank();
    }

    function testWithdrawWithInsufficientContractBalance() public {
        vm.startPrank(user1);

        // First deposit ETH
        address[] memory currencies = new address[](1);
        currencies[0] = INATIVE;

        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 0;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 1 ether;

        uint256 mintAmount = mct.deposit{value: 1 ether}(
            currencies,
            tokenIds,
            amounts
        );

        // Simulate loss of contract balance
        vm.deal(address(mct), 0.5 ether);

        // Try to withdraw full amount
        uint256 withdrawAmount = mct.withdraw(INATIVE, 0, mintAmount);
        assertEq(
            withdrawAmount,
            0.5 ether,
            "Should only withdraw available balance"
        );
        assertEq(mct.balanceOf(user1), 0, "User should have 0");
        vm.stopPrank();
    }

    // ERC1155 Specific Tests
    function testMultipleERC1155TokenIds() public {
        vm.startPrank(user1);
        mockGold.setApprovalForAll(address(mct), true);

        // Mint additional tokens of the existing ID
        mockGold.mint(user1, GOLD_TOKEN_ID, 10);

        // Test depositing multiple times with the same token ID
        address[] memory currencies = new address[](1);
        currencies[0] = address(mockGold);

        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = GOLD_TOKEN_ID;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 2; // Deposit 2 tokens

        uint256 mintAmount = mct.deposit(currencies, tokenIds, amounts);
        assertGt(mintAmount, 0, "Should mint tokens for ERC1155");

        // Check balances
        assertEq(
            mockGold.balanceOf(address(mct), GOLD_TOKEN_ID),
            2,
            "Contract should have 2 tokens"
        );
        assertEq(
            mockGold.balanceOf(user1, GOLD_TOKEN_ID),
            18,
            "User should have 18 tokens left"
        ); // 20 initial - 2 deposited

        // Test withdrawal
        uint256 withdrawAmount = mct.withdraw(
            address(mockGold),
            GOLD_TOKEN_ID,
            mintAmount
        );
        assertGt(withdrawAmount, 0, "Should withdraw tokens");
        assertEq(
            mockGold.balanceOf(address(mct), GOLD_TOKEN_ID),
            0,
            "Contract should have 0 tokens after withdrawal"
        );
        assertEq(
            mockGold.balanceOf(user1, GOLD_TOKEN_ID),
            20,
            "User should have all tokens back"
        );

        vm.stopPrank();
    }

    function testFailInvalidERC1155TokenId() public {
        vm.startPrank(user1);
        mockGold.setApprovalForAll(address(mct), true);

        address[] memory currencies = new address[](1);
        currencies[0] = address(mockGold);

        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 999; // Non-existent token ID

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 1;

        mct.deposit(currencies, tokenIds, amounts);

        vm.stopPrank();
    }

    receive() external payable {}
}
