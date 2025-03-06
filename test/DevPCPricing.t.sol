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
        (bytes[] memory currencies, uint256[] memory prices) = devPCPricing
            .getAllCurrencyPrices();

        assertEq(currencies.length, 2, "Should return two tracked currencies");
        assertEq(prices.length, 2, "Should return prices for two currencies");

        assertEq(currencies[0], USDT, "First currency should be USDT");
        assertEq(currencies[1], GOLD, "Second currency should be GOLD");
        assertEq(prices[0], 100, "First price should be 100");
        assertEq(prices[1], 500, "Second price should be 500");
    }

    function testGetAdjustmentFactors() public view {
        (uint256 numerator, uint256 denominator) = devPCPricing
            .getAdjustmentFactor();
        assertEq(numerator, 5, "Adjustment numerator should be 5");
        assertEq(denominator, 100, "Adjustment denominator should be 100");
    }

    function testGetAnchorCurrency() public view {
        bytes memory anchorCurrency = devPCPricing.getAnchorCurrency();
        assertEq(anchorCurrency, ETH, "Anchor currency should be ETH");
    }

    function testGetTrackedCurrencies() public view {
        bytes[] memory currencies = devPCPricing.getTrackedCurrencies();
        assertEq(currencies.length, 2, "Should have 2 tracked currencies");
        assertEq(currencies[0], USDT, "First tracked currency should be USDT");
        assertEq(currencies[1], GOLD, "Second tracked currency should be GOLD");
    }

    function testGetCurrencyIndex() public view {
        uint256 usdtIndex = devPCPricing.getCurrencyIndex(USDT);
        uint256 goldIndex = devPCPricing.getCurrencyIndex(GOLD);
        assertEq(usdtIndex, 0, "USDT should be at index 0");
        assertEq(goldIndex, 1, "GOLD should be at index 1");
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
        DevPCPricing newDevPCPricing;
        vm.expectRevert("Denominator must be greater than 0");
        newDevPCPricing = new DevPCPricing(ETH, 1000, 100, 0);

        vm.expectRevert("Numerator must be greater than 0");
        newDevPCPricing = new DevPCPricing(ETH, 1000, 0, 100);
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

        devPCPricing.setCurrencyPrice(USDC, 100);
        devPCPricing.setCurrencyPrice(DAI, 100);
        devPCPricing.setCurrencyPrice(BTC, 30000);

        // Test processing with batch size of 2
        uint256 processed1 = devPCPricing.adjustNonAnchorPricesBatch(false, 2);
        assertEq(processed1, 2, "Should process 2 currencies in first batch");

        // Get state after first batch
        (uint256 lastIndex, uint256 total) = devPCPricing
            .getBatchProcessingState();
        assertEq(total, 5, "Should have 5 total currencies");
        assertEq(lastIndex, 2, "Last processed index should be 2");

        // Process remaining currencies
        uint256 processed2 = devPCPricing.adjustNonAnchorPricesBatch(false, 3);
        assertEq(processed2, 3, "Should process 3 currencies in second batch");

        // Verify the index was reset
        (lastIndex, ) = devPCPricing.getBatchProcessingState();
        assertEq(
            lastIndex,
            0,
            "Index should reset after processing all currencies"
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
        for (uint i = 0; i < 10; i++) {
            bytes memory currency = bytes(
                string.concat("TOKEN", vm.toString(i))
            );
            devPCPricing.setCurrencyPrice(currency, 100);
        }

        // Set batch size to 3
        devPCPricing.setBatchSize(3);

        // Process currencies in multiple calls
        // First batch (processes indices 0-2)
        devPCPricing.useAnchorCurrency(false);
        (uint256 lastIndex, ) = devPCPricing.getBatchProcessingState();
        assertEq(lastIndex, 3, "Last index should be 3 after first batch");

        // Second batch (processes indices 3-5)
        devPCPricing.useAnchorCurrency(false);
        (lastIndex, ) = devPCPricing.getBatchProcessingState();
        assertEq(lastIndex, 6, "Last index should be 6 after second batch");

        // Third batch (processes indices 6-8)
        devPCPricing.useAnchorCurrency(false);
        (lastIndex, ) = devPCPricing.getBatchProcessingState();
        assertEq(lastIndex, 9, "Last index should be 9 after third batch");

        // Fourth batch (processes indices 9-11)
        devPCPricing.useAnchorCurrency(false);
        (lastIndex, ) = devPCPricing.getBatchProcessingState();
        assertEq(lastIndex, 0, "Last index should wrap around to 0");

        // Verify all prices were adjusted (95 = 100 - 5%)
        for (uint i = 0; i < 10; i++) {
            bytes memory currency = bytes(
                string.concat("TOKEN", vm.toString(i))
            );
            assertEq(
                devPCPricing.getCurrencyPrice(currency),
                95,
                "Price should be adjusted"
            );
        }
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
        for (uint i = 0; i < 10; i++) {
            bytes memory currency = bytes(
                string.concat("TOKEN", vm.toString(i))
            );
            devPCPricing.setCurrencyPrice(currency, 100);
        }

        // Set batch size to 3
        devPCPricing.setBatchSize(3);

        // First batch should process first 3 tokens
        devPCPricing.useAnchorCurrency(false);
        (uint256 lastIndex, uint256 total) = devPCPricing
            .getBatchProcessingState();
        assertEq(lastIndex, 3, "Should process first 3 tokens");
        assertEq(
            total,
            12,
            "Should have 12 total currencies (10 + USDT + GOLD)"
        );

        // Verify first batch prices were adjusted
        assertEq(
            devPCPricing.getCurrencyPrice(bytes("TOKEN0")),
            95,
            "TOKEN0 should be adjusted"
        );
        // Second batch should process next 3 tokens
        devPCPricing.useAnchorCurrency(false);
        (lastIndex, ) = devPCPricing.getBatchProcessingState();
        assertEq(lastIndex, 6, "Should process next 3 tokens");

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
        assertEq(
            devPCPricing.getCurrencyPrice(bytes("TOKEN3")),
            95,
            "TOKEN3 should be adjusted"
        );

        devPCPricing.useAnchorCurrency(false);
        (lastIndex, ) = devPCPricing.getBatchProcessingState();
        assertEq(lastIndex, 9, "Should process next 3 tokens");

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
        assertEq(
            devPCPricing.getCurrencyPrice(bytes("TOKEN6")),
            95,
            "TOKEN6 should be adjusted"
        );

        // Process remaining batches
        devPCPricing.useAnchorCurrency(false); // Third batch (9-11)
        // Verify final state
        (lastIndex, ) = devPCPricing.getBatchProcessingState();
        assertEq(lastIndex, 0, "Index should wrap around to 0");
        devPCPricing.useAnchorCurrency(false); // Fourth batch (0-3)
        // Verify final state
        (lastIndex, ) = devPCPricing.getBatchProcessingState();
        assertEq(lastIndex, 3, "Index should wrap around to 3");

        // Verify all remaining prices were adjusted
        for (uint i = 7; i < 10; i++) {
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
            452,
            "GOLD should be adjusted"
        );
    }
}
