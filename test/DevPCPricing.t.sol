// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";
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
        // Deploy DevPCPricing with an anchor currency (ETH = 1000), 5% adjustment factor
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

    function testUseAnchorCurrencyReducesAllNonAnchorPrices() public {
        devPCPricing.useAnchorCurrency();

        uint256 newUsdtPrice = devPCPricing.getCurrencyPrice(USDT);
        uint256 newGoldPrice = devPCPricing.getCurrencyPrice(GOLD);

        assertEq(newUsdtPrice, 95, "USDT price should decrease by 5%");
        assertEq(
            newGoldPrice,
            475,
            "GOLD price should decrease by 5% when using anchor currency"
        );
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

    function testIncreaseUSDT2TimesAndDecreaseOnce() public {
        devPCPricing.adjustCurrencyPrice(USDT, true);
        devPCPricing.adjustCurrencyPrice(USDT, true);
        uint256 newUsdtPrice = devPCPricing.getCurrencyPrice(USDT);

        assertEq(
            newUsdtPrice,
            110,
            "USDT price should increase by 100 * (1+.05)^2"
        );
        devPCPricing.adjustCurrencyPrice(USDT, false);
        newUsdtPrice = devPCPricing.getCurrencyPrice(USDT);
        assertEq(newUsdtPrice, 105, "USDT price should decrease to 105");
    }

    function testSetCurrencyPriceAfterInitialSet() public {
        // Reset USDT price
        devPCPricing.setCurrencyPrice(USDT, 187);
        uint256 newUsdtPrice = devPCPricing.getCurrencyPrice(USDT);
        assertEq(newUsdtPrice, 187, "USDT price should decrease to 187");
    }

    /// @notice Ensure the anchor currency remains fixed
    function testAnchorCurrencyDoesNotChange() public {
        uint256 ethPriceBefore = devPCPricing.getCurrencyPrice(ETH);
        devPCPricing.useAnchorCurrency(); // Trigger reduction for non-anchor currencies
        uint256 ethPriceAfter = devPCPricing.getCurrencyPrice(ETH);

        assertEq(
            ethPriceBefore,
            ethPriceAfter,
            "ETH price should remain unchanged"
        );
    }

    function testCannotAdjustAnchorPrice() public {
        uint256 ethPriceBefore = devPCPricing.getCurrencyPrice(ETH);
        vm.startPrank(player1);
        vm.expectRevert("Anchor currency cannot be adjusted");
        devPCPricing.adjustCurrencyPrice(ETH, true); // Trigger reduction for non-anchor currencies
        vm.stopPrank();
        vm.startPrank(player1);
        vm.expectRevert("Anchor currency cannot be adjusted");
        devPCPricing.adjustCurrencyPrice(ETH, false); // Trigger reduction for non-anchor currencies
        vm.stopPrank();

        uint256 ethPriceAfter = devPCPricing.getCurrencyPrice(ETH);
        assertEq(
            ethPriceBefore,
            ethPriceAfter,
            "ETH price should remain unchanged"
        );
    }

    function testCannotResetPriceForAnchorCurrency() public {
        uint256 ethPriceBefore = devPCPricing.getCurrencyPrice(ETH);
        vm.startPrank(player1);
        vm.expectRevert("Cannot set price for anchor currency");
        devPCPricing.setCurrencyPrice(ETH, 1500); // Trigger reduction for non-anchor currencies
        uint256 ethPriceAfter = devPCPricing.getCurrencyPrice(ETH);
        vm.stopPrank();
        assertEq(
            ethPriceBefore,
            ethPriceAfter,
            "ETH price should remain unchanged"
        );
    }

    function testNonAnchorCurrencyBottomLimit() public {
        devPCPricing.setCurrencyPrice(USDT, 10);
        devPCPricing.adjustCurrencyPrice(USDT, false);
        uint256 usdtPrice = devPCPricing.getCurrencyPrice(USDT);
        assertEq(
            usdtPrice,
            9,
            "USDT price should decrease to 9 from 10, minium decrease is by 1"
        );
        devPCPricing.setCurrencyPrice(USDT, 1);
        devPCPricing.adjustCurrencyPrice(USDT, false);
        usdtPrice = devPCPricing.getCurrencyPrice(USDT);
        assertEq(usdtPrice, 1, "USDT price should stay at 1");

        devPCPricing.adjustCurrencyPrice(USDT, true);
        usdtPrice = devPCPricing.getCurrencyPrice(USDT);
        assertEq(usdtPrice, 2, "USDT price should increase by 1 to 2");

        devPCPricing.setCurrencyPrice(USDT, 39);
        devPCPricing.adjustCurrencyPrice(USDT, true);
        usdtPrice = devPCPricing.getCurrencyPrice(USDT);
        assertEq(usdtPrice, 40, "USDT price should increase by 1 to 40");
        devPCPricing.adjustCurrencyPrice(USDT, true);
        usdtPrice = devPCPricing.getCurrencyPrice(USDT);
        assertEq(usdtPrice, 42, "USDT price should increase by 2 to 42");
    }
}
