// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/token/DualFi.sol";
import "../src/token/IDualFi.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("Mock Token", "MTK") {
        _mint(msg.sender, 1_000_000 * 10 ** 18);
    }
}

contract DualFiTest is Test {
    DualFi public dualFi;
    MockERC20 public token;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        user2 = address(0x2);

        token = new MockERC20();
        dualFi = new DualFi(
            "DualFi Token",
            "DFI",
            address(token),
            100e18, // initialERC20Ratio
            10 ether, // initialNativeRatio
            100, // basis
            50e18 // trimValue
        );

        // Mint and approve tokens for user1 and user2
        token.transfer(user1, 1000e18);
        token.transfer(user2, 1000e18);
        vm.prank(user1);
        token.approve(address(dualFi), 1000e18);
        vm.prank(user2);
        token.approve(address(dualFi), 1000e18);
    }

    function testCalculateDistributeAmount() public view {
        uint256 amount = dualFi.calculateDistributeAmount(0, 1 ether);
        assertGt(amount, 0, "Should Estimate amount to receive");
        amount = dualFi.calculateDistributeAmount(500e18, 0);
        assertGt(amount, 0, "Should Estimate amount to receive");
        amount = dualFi.calculateDistributeAmount(500e18, 1 ether);
        assertGt(amount, 0, "Should Estimate amount to receive");
    }

    function testDepositNative() public {
        uint256 estimatedAmount = dualFi.calculateDistributeAmount(0, 1 ether);
        vm.deal(user1, 10 ether);
        vm.prank(user1);
        uint256 receivedAmount = dualFi.deposit{value: 1 ether}(0);
        assertEq(
            estimatedAmount,
            receivedAmount,
            "Estimated Amount should equal amount received"
        );
    }

    function testDepositERC20() public {
        uint256 estimatedAmount = dualFi.calculateDistributeAmount(500e18, 0);
        assertGt(token.balanceOf(user1), 0, "User1 should have a balance");
        vm.prank(user1);
        IERC20(address(token)).approve(address(dualFi), 500e18);
        vm.prank(user1);
        uint256 receivedAmount = dualFi.deposit{value: 0}(500e18);
        assertEq(
            estimatedAmount,
            receivedAmount,
            "Estimated Amount should equal amount received"
        );
    }
}
