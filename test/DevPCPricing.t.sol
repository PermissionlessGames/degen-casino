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
        devPCPricing = new DevPCPricing(ETH, 1000, 5);

        // Set initial prices for other currencies
        devPCPricing.addCurrency(USDT, 100, 5, 100);
        devPCPricing.addCurrency(GOLD, 500, 5, 100);
    }

    function testInitialPrices() public view {
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

    function testGetAllCurrencyPrices() public view {
        bytes[] memory currencies = new bytes[](2);
        currencies[0] = USDT;
        currencies[1] = GOLD;
        uint256[] memory prices = devPCPricing.getCurrencyPrices(currencies);

        assertEq(prices.length, 2, "Should return prices for two currencies");
        assertEq(prices[0], 100, "First price should be 100");
        assertEq(prices[1], 500, "Second price should be 500");
    }

    function testGetAdjustmentFactors() public view {
        (uint256 numerator, uint256 denominator) = devPCPricing
            .getAdjustmentFactor(USDT);
        assertEq(numerator, 5, "Adjustment numerator should be 5");
        assertEq(denominator, 100, "Adjustment denominator should be 100");
    }

    function testGetAnchorCurrency() public view {
        bytes memory anchorCurrency = devPCPricing.getAnchorCurrency();
        assertEq(anchorCurrency, ETH, "Anchor currency should be ETH");
    }

    function testGetTrackedCurrencies() public view {
        uint256 numberOfCurrencies = devPCPricing.getNumberOfCurrencies();
        assertEq(numberOfCurrencies, 3, "Should have 3 tracked currencies");
        bytes[] memory currencies = new bytes[](numberOfCurrencies);
        for (uint256 i = 0; i < numberOfCurrencies; i++) {
            currencies[i] = devPCPricing.getIndexToCurrency(i);
        }
        assertEq(currencies.length, 3, "Should have 3 tracked currencies");
        assertEq(currencies[0], ETH, "First tracked currency should be ETH");
        assertEq(currencies[1], USDT, "Second tracked currency should be USDT");
        assertEq(currencies[2], GOLD, "Third tracked currency should be GOLD");
    }

    function testGetCurrencyIndex() public view {
        uint256 ethIndex = devPCPricing.getCurrencyIndex(ETH);
        uint256 usdtIndex = devPCPricing.getCurrencyIndex(USDT);
        uint256 goldIndex = devPCPricing.getCurrencyIndex(GOLD);
        assertEq(ethIndex, 0, "ETH should be at index 0");
        assertEq(usdtIndex, 1, "USDT should be at index 1");
        assertEq(goldIndex, 2, "GOLD should be at index 2");
    }

    function testCurrencyExists() public view {
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
        vm.expectRevert("Denominator must be greater than 1");
        devPCPricing.setAdjustmentFactor(USDT, 0, 0);

        vm.expectRevert("Numerator must be greater than 0");
        devPCPricing.setAdjustmentFactor(USDT, 0, 100);
    }

    function testGetIndexOfNonExistentCurrencyShouldBe0() public view {
        bytes memory nonExistentCurrency = "NON_EXISTENT";
        uint256 index = devPCPricing.getCurrencyIndex(nonExistentCurrency);
        assertEq(index, 0, "Index should be 0");
    }

    function testCurrencyExistBothFalseAndTrue() public view {
        assertTrue(devPCPricing.currencyExists(ETH), "ETH should exist");
        assertFalse(
            devPCPricing.currencyExists("NON_EXISTENT"),
            "NON_EXISTENT should not exist"
        );
    }

    function testBatchProcessing() public {
        // Add more currencies to test batch processing
        bytes memory USDC = "USDC";
        bytes memory DAI = "DAI";
        bytes memory BTC = "BTC";

        devPCPricing.addCurrency(USDC, 100, 5, 100);
        devPCPricing.addCurrency(DAI, 100, 5, 100);
        devPCPricing.addCurrency(BTC, 30000, 5, 100);

        // Test processing with batch size of 3
        uint256 processed1 = devPCPricing.adjustNonAnchorPricesBatch(false, 3);
        assertEq(processed1, 3, "Should process 3 currencies in first batch");

        // Get state after first batch
        (uint256 nextIndexToProcess, uint256 totalCurrencies) = devPCPricing
            .getBatchProcessingState();
        assertEq(totalCurrencies, 6, "Should have 6 total currencies");
        assertEq(
            nextIndexToProcess,
            3,
            "The next index to process should be 3"
        );

        // Process remaining currencies
        uint256 processed2 = devPCPricing.adjustNonAnchorPricesBatch(false, 3);
        assertEq(processed2, 3, "Should process 3 currencies in second batch");

        // Verify the index was reset
        (nextIndexToProcess, totalCurrencies) = devPCPricing
            .getBatchProcessingState();
        assertEq(
            nextIndexToProcess,
            0,
            "The next index to process should be 0"
        );

        // Verify all prices were adjusted
        assertEq(
            devPCPricing.getCurrencyPrice(USDT),
            95,
            "USDT price should be adjusted"
        );
        assertEq(
            devPCPricing.getCurrencyPrice(GOLD),
            475,
            "GOLD price should be adjusted"
        );
        assertEq(
            devPCPricing.getCurrencyPrice(USDC),
            95,
            "USDC price should be adjusted"
        );
        assertEq(
            devPCPricing.getCurrencyPrice(DAI),
            95,
            "DAI price should be adjusted"
        );
        assertEq(
            devPCPricing.getCurrencyPrice(BTC),
            28500,
            "BTC price should be adjusted"
        );
    }

    function testBatchProcessingWithSmallBatches() public {
        // Add more currencies
        for (uint256 i = 0; i < 10; i++) {
            bytes memory currency = bytes(
                string.concat("TOKEN", vm.toString(i))
            );
            devPCPricing.addCurrency(currency, 100, 5, 100);
        }

        // Set batch size to 3
        devPCPricing.setBatchSize(3);

        // Process currencies in multiple calls
        // First batch (processes indices 0-2)
        // This should process USDT, GOLD and ignore anchor currency ETH
        devPCPricing.useAnchorCurrency(false);
        (uint256 nextIndexToProcess, ) = devPCPricing.getBatchProcessingState();
        assertEq(
            nextIndexToProcess,
            3,
            "The next index to process should be 3 after first batch"
        );

        // Verify prices were adjusted
        assertEq(
            devPCPricing.getCurrencyPrice(USDT),
            95,
            "USDT price should be adjusted"
        );
        assertEq(
            devPCPricing.getCurrencyPrice(GOLD),
            475,
            "GOLD price should be adjusted"
        );

        // Second batch (processes indices 3-5)
        devPCPricing.useAnchorCurrency(false);
        (nextIndexToProcess, ) = devPCPricing.getBatchProcessingState();
        assertEq(
            nextIndexToProcess,
            6,
            "The next index to process should be 6 after second batch"
        );

        // Third batch (processes indices 6-8)
        devPCPricing.useAnchorCurrency(false);
        (nextIndexToProcess, ) = devPCPricing.getBatchProcessingState();
        assertEq(
            nextIndexToProcess,
            9,
            "The next index to process should be 9 after third batch"
        );

        // Fourth batch (processes indices 9-11)
        devPCPricing.useAnchorCurrency(false);
        (nextIndexToProcess, ) = devPCPricing.getBatchProcessingState();
        assertEq(
            nextIndexToProcess,
            12,
            "The next index to process should be 12 after fourth batch"
        );

        // Verify all prices were adjusted (95 = 100 - 5%)
        for (uint256 i = 0; i < 9; i++) {
            bytes memory currency = bytes(
                string.concat("TOKEN", vm.toString(i))
            );
            assertEq(
                devPCPricing.getCurrencyPrice(currency),
                95,
                "Price should be adjusted"
            );
        }

        {
            uint256 i = 9;
            bytes memory currency = bytes(
                string.concat("TOKEN", vm.toString(i))
            );
            assertEq(
                devPCPricing.getCurrencyPrice(currency),
                100,
                "Price should not be adjusted"
            );
        }

        // Verify prices were adjusted
        assertEq(
            devPCPricing.getCurrencyPrice(USDT),
            95,
            "USDT price should be adjusted"
        );
        assertEq(
            devPCPricing.getCurrencyPrice(GOLD),
            475,
            "GOLD price should be adjusted"
        );
    }

    function testSetBatchSize() public {
        devPCPricing.setBatchSize(5);
        assertEq(
            devPCPricing.getBatchSize(),
            5,
            "Batch size should be set to 5"
        );
    }

    function testCannotSetZeroBatchSize() public {
        vm.expectRevert("Batch size must be greater than 0");
        devPCPricing.setBatchSize(0);
    }

    function testAutomaticBatchProcessing() public {
        // Add more currencies to exceed batch size
        for (uint256 i = 0; i < 10; i++) {
            bytes memory currency = bytes(
                string.concat("TOKEN", vm.toString(i))
            );
            devPCPricing.addCurrency(currency, 100, 5, 100);
        }

        // Set batch size to 3
        devPCPricing.setBatchSize(3);

        // First batch should process first 3 tokens
        devPCPricing.useAnchorCurrency(false);
        (uint256 nextIndexToProcess, uint256 totalCurrencies) = devPCPricing
            .getBatchProcessingState();
        assertEq(
            nextIndexToProcess,
            3,
            "The next index to process should be 3 after first batch"
        );
        assertEq(
            totalCurrencies,
            13,
            "Should have 13 total currencies (10 + USDT + GOLD + ETH)"
        );

        // Verify first batch prices were adjusted

        // Second batch should process next 3 tokens
        devPCPricing.useAnchorCurrency(false);

        (nextIndexToProcess, totalCurrencies) = devPCPricing
            .getBatchProcessingState();
        assertEq(
            nextIndexToProcess,
            6,
            "The next index to process should be 6 after second batch"
        );

        assertEq(
            devPCPricing.getCurrencyPrice(bytes("TOKEN0")),
            95,
            "TOKEN0 should be adjusted"
        );

        assertEq(
            devPCPricing.getCurrencyPrice(bytes("TOKEN1")),
            95,
            "TOKEN1 should be adjusted"
        );
        assertEq(
            devPCPricing.getCurrencyPrice(bytes("TOKEN2")),
            95,
            "TOKEN2 should be adjusted"
        );

        // Verify second batch prices were adjusted

        devPCPricing.useAnchorCurrency(false);
        (nextIndexToProcess, totalCurrencies) = devPCPricing
            .getBatchProcessingState();
        assertEq(
            nextIndexToProcess,
            9,
            "The next index to process should be 9 after third batch"
        );

        assertEq(
            devPCPricing.getCurrencyPrice(bytes("TOKEN3")),
            95,
            "TOKEN3 should be adjusted"
        );

        assertEq(
            devPCPricing.getCurrencyPrice(bytes("TOKEN4")),
            95,
            "TOKEN4 should be adjusted"
        );
        assertEq(
            devPCPricing.getCurrencyPrice(bytes("TOKEN5")),
            95,
            "TOKEN5 should be adjusted"
        );

        // Process remaining batches
        devPCPricing.useAnchorCurrency(false); // Third batch (9-11)
        // Verify final state
        (nextIndexToProcess, totalCurrencies) = devPCPricing
            .getBatchProcessingState();
        assertEq(
            nextIndexToProcess,
            12,
            "The next index to process should be 12 after fourth batch"
        );
        devPCPricing.useAnchorCurrency(false); // Fourth batch (0-3)
        // Verify final state
        (nextIndexToProcess, totalCurrencies) = devPCPricing
            .getBatchProcessingState();
        assertEq(
            nextIndexToProcess,
            2,
            "The next index to process should be 2 after fifth batch"
        );

        // Verify all remaining prices were adjusted
        for (uint256 i = 6; i < 10; i++) {
            bytes memory currency = bytes(
                string.concat("TOKEN", vm.toString(i))
            );
            assertEq(
                devPCPricing.getCurrencyPrice(currency),
                95,
                string.concat("TOKEN", vm.toString(i), " should be adjusted")
            );
        }

        // Verify original currencies were also adjusted
        assertEq(
            devPCPricing.getCurrencyPrice(USDT),
            91,
            "USDT should be adjusted"
        );
        assertEq(
            devPCPricing.getCurrencyPrice(GOLD),
            475,
            "GOLD should be adjusted"
        );
    }
}
