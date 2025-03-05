// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/token/ERC20/MultipleCurrencyToken.sol";
import "../src/token/ERC20/interfaces/IMultipleCurrencyToken.sol";
import "../src/dev/mock/MockERC20.sol";
import "../src/dev/mock/MockERC1155.sol";

contract MultipleCurrencyTokenTest is Test {
    MultipleCurrencyToken private mct;
    MockERC20 private tokenA;
    MockERC1155 private tokenB;
    address private user = address(0x123);
    address private INATIVE = address(0xdead);

    function setUp() public {
        // Deploy mock tokens
        tokenA = new MockERC20("MockTokenA", "TKA");
        tokenB = new MockERC1155("MockTokenB");

        // Configure pricing data
        IMultipleCurrencyToken.CreatePricingDataParams[]
            memory pricingData = new IMultipleCurrencyToken.CreatePricingDataParams[](
                2
            );
        pricingData[0] = IMultipleCurrencyToken.CreatePricingDataParams({
            currency: address(tokenA),
            price: 1 ether, // 1 TKA = 1 MCT Token
            is1155: false,
            tokenId: 0
        });
        pricingData[1] = IMultipleCurrencyToken.CreatePricingDataParams({
            currency: address(tokenB),
            price: 2 ether, // 1 ERC1155 Token = 2 MCT Tokens
            is1155: true,
            tokenId: 1
        });

        // Deploy the MultipleCurrencyToken contract
        mct = new MultipleCurrencyToken(
            "MultipleCurrencyToken",
            "MCT",
            INATIVE,
            1,
            2,
            pricingData
        );

        // Fund user with ERC20 and ERC1155 tokens
        tokenA.mint(user, 100 ether);
        tokenB.mint(user, 1, 50); // Mint 50 of ERC1155 tokenId=1

        // Label addresses in Foundry Debugging
        vm.label(user, "User");
        vm.label(address(tokenA), "MockERC20");
        vm.label(address(tokenB), "MockERC1155");
        vm.label(address(mct), "MultipleCurrencyToken");
    }

    function testDeployment() public view {
        assertEq(mct.name(), "MultipleCurrencyToken");
        assertEq(mct.symbol(), "MCT");
        assertEq(mct.INATIVE(), INATIVE);
    }

    function testDepositERC20() public {
        vm.startPrank(user);
        tokenA.approve(address(mct), 10 ether);

        address[] memory currencies = new address[](1);
        uint256[] memory tokenIds = new uint256[](1);
        uint256[] memory amounts = new uint256[](1);
        currencies[0] = address(tokenA);
        tokenIds[0] = 0;
        amounts[0] = 10 ether;

        uint256 expectedMint = mct.estimateDepositAmount(
            currencies,
            tokenIds,
            amounts
        );
        uint256 balanceBefore = mct.balanceOf(user);

        mct.deposit(currencies, tokenIds, amounts);

        assertEq(mct.balanceOf(user), balanceBefore + expectedMint);
        assertEq(tokenA.balanceOf(user), 90 ether);
        vm.stopPrank();
    }

    function testDepositERC1155() public {
        vm.startPrank(user);
        tokenB.setApprovalForAll(address(mct), true);

        address[] memory currencies = new address[](1);
        uint256[] memory tokenIds = new uint256[](1);
        uint256[] memory amounts = new uint256[](1);
        currencies[0] = address(tokenB);
        tokenIds[0] = 1;
        amounts[0] = 10;

        uint256 expectedMint = mct.estimateDepositAmount(
            currencies,
            tokenIds,
            amounts
        );
        uint256 balanceBefore = mct.balanceOf(user);

        mct.deposit(currencies, tokenIds, amounts);

        assertEq(mct.balanceOf(user), balanceBefore + expectedMint);
        assertEq(tokenB.balanceOf(user, 1), 40);
        vm.stopPrank();
    }

    function testWithdrawERC20() public {
        vm.startPrank(user);
        tokenA.approve(address(mct), 10 ether);

        address[] memory currencies = new address[](1);
        uint256[] memory tokenIds = new uint256[](1);
        uint256[] memory amounts = new uint256[](1);
        currencies[0] = address(tokenA);
        tokenIds[0] = 0;
        amounts[0] = 10 ether;

        mct.deposit(currencies, tokenIds, amounts);
        uint256 amountIn = mct.balanceOf(user);
        uint256 expectedWithdraw = mct.estimateWithdrawAmount(
            address(tokenA),
            0,
            amountIn
        );

        uint256 balanceBefore = tokenA.balanceOf(user);
        mct.withdraw(address(tokenA), 0, amountIn);

        assertEq(tokenA.balanceOf(user), balanceBefore + expectedWithdraw);
        assertEq(mct.balanceOf(user), 0);
        vm.stopPrank();
    }

    function testWithdrawERC1155() public {
        vm.startPrank(user);
        tokenB.setApprovalForAll(address(mct), true);

        address[] memory currencies = new address[](1);
        uint256[] memory tokenIds = new uint256[](1);
        uint256[] memory amounts = new uint256[](1);
        currencies[0] = address(tokenB);
        tokenIds[0] = 1;
        amounts[0] = 10;

        mct.deposit(currencies, tokenIds, amounts);
        uint256 amountIn = mct.balanceOf(user);
        uint256 expectedWithdraw = mct.estimateWithdrawAmount(
            address(tokenB),
            1,
            amountIn
        );

        uint256 balanceBefore = tokenB.balanceOf(user, 1);
        mct.withdraw(address(tokenB), 1, amountIn);

        assertEq(tokenB.balanceOf(user, 1), balanceBefore + expectedWithdraw);
        assertEq(mct.balanceOf(user), 0);
        vm.stopPrank();
    }

    function testGetTokens() public view {
        // Call getTokens()
        (
            address[] memory currencies,
            uint256[] memory tokenIds,
            bool[] memory is1155
        ) = mct.getTokens();

        //Assert that returned arrays match the initialized values
        assertEq(currencies.length, 2);
        assertEq(tokenIds.length, 2);
        assertEq(is1155.length, 2);

        assertEq(currencies[0], address(tokenA));
        assertEq(tokenIds[0], 0);
        assertEq(is1155[0], false);

        assertEq(currencies[1], address(tokenB));
        assertEq(tokenIds[1], 1);
        assertEq(is1155[1], true);
    }

    function testGetTokenPriceRatios() public view {
        // Prepare input arrays
        address[] memory treasuryTokens = new address[](2);
        uint256[] memory tokenIds = new uint256[](2);
        treasuryTokens[0] = address(tokenA);
        tokenIds[0] = 0;
        treasuryTokens[1] = address(tokenB);
        tokenIds[1] = 1;

        // Call getTokenPriceRatios()
        (
            uint256[] memory mintPriceRatios,
            uint256[] memory redeemPriceRatios
        ) = mct.getTokenPriceRatios(treasuryTokens, tokenIds);

        //Assert that mint price ratios match expected values
        assertEq(mintPriceRatios.length, 2);
        assertEq(redeemPriceRatios.length, 2);

        assertEq(mintPriceRatios[0], 1 ether);
        assertEq(redeemPriceRatios[0], 1 ether);

        assertEq(mintPriceRatios[1], 2 ether);
        assertEq(redeemPriceRatios[1], 2 ether);
    }
}
