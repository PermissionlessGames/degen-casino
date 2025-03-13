// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {MCTOwnership} from "../src/token/ERC20/extensions/MCTOwnership.sol";
import {IMultipleCurrencyToken} from "../src/token/ERC20/interfaces/IMultipleCurrencyToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {MockERC20} from "../src/dev/mock/MockERC20.sol";
import {MockERC1155} from "../src/dev/mock/MockERC1155.sol";

contract TestMCTOwnership is MCTOwnership {
    constructor(
        string memory name_,
        string memory symbol_,
        address inative,
        uint256 adjustmentNumerator,
        uint256 adjustmentDenominator,
        CreatePricingDataParams[] memory currencies
    )
        MCTOwnership(
            name_,
            symbol_,
            inative,
            adjustmentNumerator,
            adjustmentDenominator,
            currencies
        )
    {}
}

contract MCTOwnershipTest is Test {
    TestMCTOwnership mct;
    MockERC20 mockUsdt;
    MockERC20 mockUsdc;
    MockERC1155 mockGold;

    address constant INATIVE = address(0x1);
    uint256 constant GOLD_TOKEN_ID = 1;

    address owner;
    address user1;
    address user2;

    function setUp() public {
        // Deploy mock tokens
        mockUsdt = new MockERC20("USDT", "USDT");
        mockUsdc = new MockERC20("USDC", "USDC");
        mockGold = new MockERC1155("URI");

        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        vm.startPrank(owner);

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
        mct = new TestMCTOwnership(
            "Multiple Currency Token",
            "MCT",
            INATIVE,
            5, // 5% adjustment
            100,
            initialCurrencies
        );

        vm.stopPrank();
    }

    // Ownership Tests
    function testOwnership() public view {
        assertEq(mct.owner(), owner);
        assertNotEq(mct.owner(), user1);
    }

    function testRevertNonOwnerAdjustPricingData() public {
        vm.startPrank(user1);
        vm.expectRevert("Ownable: caller is not the owner");
        mct.adjustPricingData(0, 2e18);
        vm.stopPrank();
    }

    function testRevertNonOwnerAdjustAdjustmentFactor() public {
        vm.startPrank(user1);
        vm.expectRevert("Ownable: caller is not the owner");
        mct.adjustAdjustmentFactor(10, 100);
        vm.stopPrank();
    }

    function testRevertNonOwnerAddNewPricingData() public {
        vm.startPrank(user1);
        vm.expectRevert("Ownable: caller is not the owner");
        IMultipleCurrencyToken.CreatePricingDataParams[]
            memory newCurrencies = new IMultipleCurrencyToken.CreatePricingDataParams[](
                1
            );
        mct.addNewPricingData(newCurrencies);
        vm.stopPrank();
    }

    function testRevertNonOwnerRemovePricingData() public {
        vm.startPrank(user1);
        vm.expectRevert("Ownable: caller is not the owner");
        mct.removePricingData(0);
        vm.stopPrank();
    }

    // Pricing Data Adjustment Tests
    function testAdjustPricingData() public {
        vm.startPrank(owner);
        uint256 newPrice = 2e6;
        mct.adjustPricingData(1, newPrice); // Adjust USDT price instead of anchor

        bytes memory currency = mct.encodeCurrency(address(mockUsdt), 0, false);
        assertEq(mct.getMintPrice(currency), newPrice);
        assertEq(mct.getRedeemPrice(currency), newPrice);
        vm.stopPrank();
    }

    function testRevertAdjustAnchorCurrency() public {
        vm.startPrank(owner);
        vm.expectRevert("Cannot adjust anchor currency");
        mct.adjustPricingData(0, 2e18); // Should fail when trying to adjust anchor currency
        vm.stopPrank();
    }

    function testAdjustAdjustmentFactor() public {
        vm.startPrank(owner);
        uint256 newNumerator = 10;
        uint256 newDenominator = 100;
        mct.adjustAdjustmentFactor(newNumerator, newDenominator);

        // Test the effect by making a deposit and checking price adjustment
        vm.stopPrank();
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

        // Price should increase by 10%
        assertEq(newPrice, (initialPrice * 110) / 100);
        vm.stopPrank();
    }

    // Add New Pricing Data Tests
    function testAddNewPricingData() public {
        vm.startPrank(owner);
        MockERC20 newToken = new MockERC20("NEW", "NEW");

        IMultipleCurrencyToken.CreatePricingDataParams[]
            memory newCurrencies = new IMultipleCurrencyToken.CreatePricingDataParams[](
                1
            );
        newCurrencies[0] = IMultipleCurrencyToken.CreatePricingDataParams({
            currency: address(newToken),
            price: 1e18,
            is1155: false,
            tokenId: 0
        });

        mct.addNewPricingData(newCurrencies);

        assertTrue(
            mct.doesCurrencyExist(address(newToken), 0, false),
            "New currency should exist"
        );
        vm.stopPrank();
    }

    function testRevertAddExistingCurrency() public {
        vm.startPrank(owner);
        IMultipleCurrencyToken.CreatePricingDataParams[]
            memory newCurrencies = new IMultipleCurrencyToken.CreatePricingDataParams[](
                1
            );
        newCurrencies[0] = IMultipleCurrencyToken.CreatePricingDataParams({
            currency: INATIVE,
            price: 1e18,
            is1155: false,
            tokenId: 0
        });

        vm.expectRevert("Currency already exists");
        mct.addNewPricingData(newCurrencies);
        vm.stopPrank();
    }

    function testRevertAddZeroAddressCurrency() public {
        vm.startPrank(owner);
        IMultipleCurrencyToken.CreatePricingDataParams[]
            memory newCurrencies = new IMultipleCurrencyToken.CreatePricingDataParams[](
                1
            );
        newCurrencies[0] = IMultipleCurrencyToken.CreatePricingDataParams({
            currency: address(0),
            price: 1e18,
            is1155: false,
            tokenId: 0
        });
        vm.expectRevert("Invalid currency address");
        mct.addNewPricingData(newCurrencies);
        vm.stopPrank();
    }

    function testRevertAddZeroPriceCurrency() public {
        vm.startPrank(owner);
        MockERC20 newToken = new MockERC20("NEW", "NEW");
        IMultipleCurrencyToken.CreatePricingDataParams[]
            memory newCurrencies = new IMultipleCurrencyToken.CreatePricingDataParams[](
                1
            );
        newCurrencies[0] = IMultipleCurrencyToken.CreatePricingDataParams({
            currency: address(newToken),
            price: 0,
            is1155: false,
            tokenId: 0
        });
        vm.expectRevert("Invalid price");
        mct.addNewPricingData(newCurrencies);
        vm.stopPrank();
    }

    // Remove Pricing Data Tests
    function testRemovePricingData() public {
        vm.startPrank(owner);
        mct.removePricingData(1); // Remove USDT

        assertFalse(
            mct.doesCurrencyExist(address(mockUsdt), 0, false),
            "USDT should not exist after removal"
        );
        vm.stopPrank();
    }

    function testRemovePricingDataAndVerifyDeposit() public {
        vm.startPrank(owner);
        mct.removePricingData(1); // Remove USDT
        vm.stopPrank();

        vm.startPrank(user1);
        mockUsdt.approve(address(mct), 1000e18);

        address[] memory currencies = new address[](1);
        currencies[0] = address(mockUsdt);
        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 0;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 100e18;

        vm.expectRevert("Currency does not exist"); // Should revert as currency no longer exists
        mct.deposit(currencies, tokenIds, amounts);
        vm.stopPrank();
    }

    // Additional Ownership Tests
    function testTransferOwnership() public {
        vm.startPrank(owner);
        mct.transferOwnership(user1);
        vm.stopPrank();

        assertEq(mct.owner(), user1);
        //
        // Test that old owner can't call owner functions
        vm.startPrank(owner);
        vm.expectRevert();
        mct.adjustPricingData(1, 2e6);
        vm.stopPrank();

        // Test that new owner can call owner functions
        vm.startPrank(user1);
        mct.adjustPricingData(1, 2e6);
        vm.stopPrank();
    }

    function testRevertTransferToZeroAddress() public {
        vm.startPrank(owner);
        vm.expectRevert("Ownable: new owner is the zero address");
        mct.transferOwnership(address(0));
        vm.stopPrank();
    }

    // Additional Pricing Data Tests
    function testAdjustERC1155PricingData() public {
        vm.startPrank(owner);
        uint256 newPrice = 1e18;
        mct.adjustPricingData(3, newPrice); // Adjust GOLD price

        bytes memory currency = mct.encodeCurrency(
            address(mockGold),
            GOLD_TOKEN_ID,
            true
        );
        assertEq(mct.getMintPrice(currency), newPrice);
        assertEq(mct.getRedeemPrice(currency), newPrice);
        vm.stopPrank();
    }

    function testRevertRemoveAnchorCurrency() public {
        vm.startPrank(owner);
        vm.expectRevert("Cannot remove anchor currency");
        mct.removePricingData(0); // Should fail when trying to remove anchor currency
        vm.stopPrank();
    }

    // Adjustment Factor Tests
    function testRevertAdjustmentFactorZeroDenominator() public {
        vm.startPrank(owner);
        vm.expectRevert("Invalid denominator");
        mct.adjustAdjustmentFactor(5, 0);
        vm.stopPrank();
    }

    function testRevertAdjustmentFactorNumeratorLargerThanDenominator() public {
        vm.startPrank(owner);
        vm.expectRevert("Invalid numerator");
        mct.adjustAdjustmentFactor(101, 100); // More than 100% adjustment
        vm.stopPrank();
    }

    // Multiple Currency Operations
    function testRemoveMultipleCurrencies() public {
        vm.startPrank(owner);

        // Remove USDT and USDC
        mct.removePricingData(2); // Remove USDC first (to avoid index shifting issues)
        mct.removePricingData(1); // Remove USDT

        // Verify both are removed
        assertFalse(
            mct.doesCurrencyExist(address(mockUsdt), 0, false),
            "USDT should not exist"
        );
        assertFalse(
            mct.doesCurrencyExist(address(mockUsdc), 0, false),
            "USDC should not exist"
        );

        // Verify remaining currencies still exist
        assertTrue(
            mct.doesCurrencyExist(INATIVE, 0, false),
            "INATIVE should still exist"
        );
        assertTrue(
            mct.doesCurrencyExist(address(mockGold), GOLD_TOKEN_ID, true),
            "GOLD should still exist"
        );

        vm.stopPrank();
    }

    function testRevertRemoveInvalidIndex() public {
        vm.startPrank(owner);
        vm.expectRevert("Invalid index");
        mct.removePricingData(99); // Invalid index
        vm.stopPrank();
    }

    // Event Tests
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function testOwnershipTransferredEvent() public {
        vm.startPrank(owner);
        vm.expectEmit(true, true, false, false);
        emit OwnershipTransferred(owner, user1);
        mct.transferOwnership(user1);
        vm.stopPrank();
    }

    function testAddNewPricingDataEvent() public {
        vm.startPrank(owner);
        MockERC20 newToken = new MockERC20("NEW", "NEW");

        IMultipleCurrencyToken.CreatePricingDataParams[]
            memory newCurrencies = new IMultipleCurrencyToken.CreatePricingDataParams[](
                1
            );
        newCurrencies[0] = IMultipleCurrencyToken.CreatePricingDataParams({
            currency: address(newToken),
            price: 1e18,
            is1155: false,
            tokenId: 0
        });

        mct.addNewPricingData(newCurrencies);
        bool exists = mct.doesCurrencyExist(address(newToken), 0, false);
        assertTrue(exists, "New currency should exist");

        vm.stopPrank();
    }

    // Additional Edge Cases
    function testRevertAddEmptyPricingDataArray() public {
        vm.startPrank(owner);
        IMultipleCurrencyToken.CreatePricingDataParams[]
            memory newCurrencies = new IMultipleCurrencyToken.CreatePricingDataParams[](
                0
            );
        mct.addNewPricingData(newCurrencies);
        vm.stopPrank();
    }

    function testRevertAdjustPricingDataInvalidIndex() public {
        vm.startPrank(owner);
        vm.expectRevert("Invalid index");
        mct.adjustPricingData(99, 1e18); // Invalid index
        vm.stopPrank();
    }

    receive() external payable {}
}
