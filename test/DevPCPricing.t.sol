// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {DevPCPricing} from "../src/dev/DevPCPricing.sol";

/// @title Foundry Test for DevPCPricing Contract
/// @author Permissionless Games & ChatGPT
/// @notice Tests key functionalities of the DevPCPricing contract using Foundry framework.
contract DevPCPricingTest is Test {
    DevPCPricing devPCPricing;

    bytes constant ETH = "ETH";
    bytes constant USDT = "USDT";
    bytes constant GOLD = "ERC1155-GOLD";

    uint256 player1PrivateKey = 0x13371;
    address player1 = vm.addr(player1PrivateKey);

    function setUp() public {
        devPCPricing = new DevPCPricing(ETH, 1000, 5, 100);

        // Set initial prices for other currencies
        devPCPricing.setCurrencyPrice(USDT, 100);
        devPCPricing.setCurrencyPrice(GOLD, 500);
    }

    function testInitialPrices() public {
        uint256 ethPrice = devPCPricing.getCurrencyPrice(ETH);
        uint256 usdtPrice = devPCPricing.getCurrencyPrice(USDT);
        uint256 goldPrice = devPCPricing.getCurrencyPrice(GOLD);

        assertEq(ethPrice, 1000, "ETH price should be initialized to 1000");
        assertEq(usdtPrice, 100, "USDT price should be initialized to 100");
        assertEq(goldPrice, 500, "GOLD price should be initialized to 500");
    }

    function testPriceAdjustmentIncrease() public {
        devPCPricing.adjustCurrencyPrice(USDT, true);
        uint256 newUsdtPrice = devPCPricing.getCurrencyPrice(USDT);
        assertEq(newUsdtPrice, 105, "USDT price should increase by 5%");

        devPCPricing.adjustCurrencyPrice(GOLD, true);
        uint256 newGoldPrice = devPCPricing.getCurrencyPrice(GOLD);
        assertEq(newGoldPrice, 525, "GOLD price should increase by 5%");
    }

    function testPriceAdjustmentDecrease() public {
        devPCPricing.adjustCurrencyPrice(USDT, false);
        uint256 newUsdtPrice = devPCPricing.getCurrencyPrice(USDT);
        assertEq(newUsdtPrice, 95, "USDT price should decrease by 5%");

        devPCPricing.adjustCurrencyPrice(GOLD, false);
        uint256 newGoldPrice = devPCPricing.getCurrencyPrice(GOLD);
        assertEq(newGoldPrice, 475, "GOLD price should decrease by 5%");
    }

    function testAdjustAllNonAnchorPrices() public {
        devPCPricing.useAnchorCurrency(false);

        uint256 newUsdtPrice = devPCPricing.getCurrencyPrice(USDT);
        uint256 newGoldPrice = devPCPricing.getCurrencyPrice(GOLD);

        assertEq(newUsdtPrice, 95, "USDT price should decrease by 5%");
        assertEq(newGoldPrice, 475, "GOLD price should decrease by 5%");
    }

    function testGetAllCurrencyPrices() public {
        (bytes[] memory currencies, uint256[] memory prices) = devPCPricing
            .getAllCurrencyPrices();

        assertEq(currencies.length, 2, "Should return two tracked currencies");
        assertEq(prices.length, 2, "Should return prices for two currencies");

        assertEq(currencies[0], USDT, "First currency should be USDT");
        assertEq(currencies[1], GOLD, "Second currency should be GOLD");
        assertEq(prices[0], 100, "First price should be 100");
        assertEq(prices[1], 500, "Second price should be 500");
    }

    function testGetAdjustmentFactors() public {
        (uint256 numerator, uint256 denominator) = devPCPricing
            .getAdjustmentFactor();
        assertEq(numerator, 5, "Adjustment numerator should be 5");
        assertEq(denominator, 100, "Adjustment denominator should be 100");
    }

    function testGetAnchorCurrency() public {
        bytes memory anchorCurrency = devPCPricing.getAnchorCurrency();
        assertEq(anchorCurrency, ETH, "Anchor currency should be ETH");
    }

    function testGetTrackedCurrencies() public {
        bytes[] memory currencies = devPCPricing.getTrackedCurrencies();
        assertEq(currencies.length, 2, "Should have 2 tracked currencies");
        assertEq(currencies[0], USDT, "First tracked currency should be USDT");
        assertEq(currencies[1], GOLD, "Second tracked currency should be GOLD");
    }

    function testGetCurrencyIndex() public {
        uint256 usdtIndex = devPCPricing.getCurrencyIndex(USDT);
        uint256 goldIndex = devPCPricing.getCurrencyIndex(GOLD);
        assertEq(usdtIndex, 0, "USDT should be at index 0");
        assertEq(goldIndex, 1, "GOLD should be at index 1");
    }

    function testCurrencyExists() public {
        assertTrue(devPCPricing.currencyExists(ETH), "ETH should exist");
        assertTrue(devPCPricing.currencyExists(USDT), "USDT should exist");
        assertTrue(devPCPricing.currencyExists(GOLD), "GOLD should exist");
        assertFalse(
            devPCPricing.currencyExists("NONEXISTENT"),
            "Non-existent currency should return false"
        );
    }

    function testRemoveCurrency() public {
        assertTrue(
            devPCPricing.currencyExists(USDT),
            "USDT should exist before removal"
        );
        devPCPricing.removeCurrency(USDT);
        assertFalse(
            devPCPricing.currencyExists(USDT),
            "USDT should not exist after removal"
        );
    }

    function testCannotAdjustAnchorPrice() public {
        vm.expectRevert("Anchor currency cannot be adjusted");
        devPCPricing.adjustCurrencyPrice(ETH, true);

        vm.expectRevert("Anchor currency cannot be adjusted");
        devPCPricing.adjustCurrencyPrice(ETH, false);
    }

    function testCannotResetPriceForAnchorCurrency() public {
        vm.expectRevert("Cannot set price for anchor currency");
        devPCPricing.setCurrencyPrice(ETH, 1500);
    }

    function testNonAnchorCurrencyBottomLimit() public {
        devPCPricing.setCurrencyPrice(USDT, 10);
        devPCPricing.adjustCurrencyPrice(USDT, false);
        uint256 usdtPrice = devPCPricing.getCurrencyPrice(USDT);
        assertEq(usdtPrice, 9, "USDT price should decrease to 9");

        devPCPricing.setCurrencyPrice(USDT, 1);
        devPCPricing.adjustCurrencyPrice(USDT, false);
        usdtPrice = devPCPricing.getCurrencyPrice(USDT);
        assertEq(usdtPrice, 1, "USDT price should stay at 1");

        devPCPricing.adjustCurrencyPrice(USDT, true);
        usdtPrice = devPCPricing.getCurrencyPrice(USDT);
        assertEq(usdtPrice, 2, "USDT price should increase to 2");
    }

    function testCannotSetZeroPrice() public {
        vm.expectRevert("Price must be greater than 0");
        devPCPricing.setCurrencyPrice(USDT, 0);
    }

    function testCannotSetEmptyCurrency() public {
        vm.expectRevert("Currency cannot be empty");
        devPCPricing.setCurrencyPrice("", 100);
    }

    function testCannotRemoveAnchorCurrency() public {
        vm.expectRevert("Cannot remove anchor currency");
        devPCPricing.removeCurrency(ETH);
    }

    function testCannotRemoveNonExistentCurrency() public {
        bytes memory nonExistentCurrency = "NON_EXISTENT";
        vm.expectRevert("Currency not found");
        devPCPricing.removeCurrency(nonExistentCurrency);
    }

    function testCannotAdjustNonExistentCurrency() public {
        bytes memory nonExistentCurrency = "NON_EXISTENT";
        vm.expectRevert("Currency price not set");
        devPCPricing.adjustCurrencyPrice(nonExistentCurrency, true);
    }

    function testSetCurrencyNewPrice() public {
        uint256 usdtPrice = devPCPricing.getCurrencyPrice(USDT);
        assertEq(usdtPrice, 100, "USDT price should be 100");
        devPCPricing.setCurrencyPrice(USDT, 200);
        usdtPrice = devPCPricing.getCurrencyPrice(USDT);
        assertEq(usdtPrice, 200, "USDT price should be 200");
    }

    function testCannotSetInvalidAdjustmentFactor() public {
        DevPCPricing newDevPCPricing;
        vm.expectRevert("Denominator must be greater than 0");
        newDevPCPricing = new DevPCPricing(ETH, 1000, 100, 0);

        vm.expectRevert("Numerator must be greater than 0");
        newDevPCPricing = new DevPCPricing(ETH, 1000, 0, 100);
    }

    function testGetIndexOfNonExistentCurrencyShouldBe0() public {
        bytes memory nonExistentCurrency = "NON_EXISTENT";
        uint256 index = devPCPricing.getCurrencyIndex(nonExistentCurrency);
        assertEq(index, 0, "Index should be 0");
    }

    function testCurrencyExistBothFalseAndTrue() public {
        assertTrue(devPCPricing.currencyExists(ETH), "ETH should exist");
        assertFalse(
            devPCPricing.currencyExists("NON_EXISTENT"),
            "NON_EXISTENT should not exist"
        );
    }
}
