// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/distribution/RecurringClaimsDistribution.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("MockToken", "MTK") {
        _mint(msg.sender, 1_000_000 * 10 ** 18);
    }
}

contract RecurringClaimsDistributionTest is Test {
    RecurringClaimsDistribution public distribution;
    MockERC20 public token;
    address public owner;
    address public recipient1;
    address public recipient2;

    function setUp() public {
        distribution = new RecurringClaimsDistribution();
        token = new MockERC20();

        owner = address(this);
        recipient1 = address(0x1);
        recipient2 = address(0x2);
    }

    function testCreateRoundERC20() public {
        uint256 totalTokens = 1000 * 10 ** 18;
        uint256 minInterval = 1 hours;
        uint256 numberOfClaimsRequired = 5;
        address[] memory recipients = new address[](2);
        recipients[0] = recipient1;
        recipients[1] = recipient2;

        token.approve(address(distribution), totalTokens);

        uint256 roundId = distribution.startNewRound(
            address(token),
            recipients,
            minInterval,
            totalTokens,
            numberOfClaimsRequired
        );

        (
            address tokenAddress,
            ,
            ,
            ,
            uint256 remainingTokens,
            ,
            bool isActive,

        ) = distribution.rounds(roundId);

        assertEq(tokenAddress, address(token), "Incorrect token address");
        assertEq(remainingTokens, totalTokens, "Incorrect token allocation");
        assertTrue(isActive, "Round should be active");
    }

    function testCreateRoundNative() public {
        uint256 totalTokens = 10 ether;
        uint256 minInterval = 1 hours;
        uint256 numberOfClaimsRequired = 5;
        address[] memory recipients = new address[](2);
        recipients[0] = recipient1;
        recipients[1] = recipient2;

        uint256 roundId = distribution.startNewRound{value: totalTokens}(
            address(0),
            recipients,
            minInterval,
            totalTokens,
            numberOfClaimsRequired
        );

        (, , , , uint256 remainingTokens, , bool isActive, ) = distribution
            .rounds(roundId);

        assertEq(
            remainingTokens,
            totalTokens,
            "Incorrect native token allocation"
        );
        assertTrue(isActive, "Round should be active");
    }

    function testClaimTokens() public {
        uint256 totalTokens = 1000 * 10 ** 18;
        uint256 minInterval = 1 hours;
        uint256 numberOfClaimsRequired = 5;
        address[] memory recipients = new address[](2);
        recipients[0] = recipient1;
        recipients[1] = recipient2;

        token.approve(address(distribution), totalTokens);
        uint256 roundId = distribution.startNewRound(
            address(token),
            recipients,
            minInterval,
            totalTokens,
            numberOfClaimsRequired
        );

        // Fast-forward time to allow claims
        vm.warp(block.timestamp + minInterval);

        vm.prank(recipient1);
        distribution.claimTokens(roundId, recipient1);

        uint256 amountClaimed = distribution.getAmountClaimed(
            roundId,
            recipient1
        );
        assertGt(amountClaimed, 0, "Recipient should have claimed some tokens");
    }

    function testClaimIntervalRestriction() public {
        uint256 totalTokens = 1000 * 10 ** 18;
        uint256 minInterval = 1 hours;
        uint256 numberOfClaimsRequired = 5;
        address[] memory recipients = new address[](2);
        recipients[0] = recipient1;

        token.approve(address(distribution), totalTokens);
        uint256 roundId = distribution.startNewRound(
            address(token),
            recipients,
            minInterval,
            totalTokens,
            numberOfClaimsRequired
        );

        vm.warp(block.timestamp + minInterval);

        vm.prank(recipient1);
        distribution.claimTokens(roundId, recipient1);

        // Attempt early re-claim (should revert)
        vm.expectRevert("Claim interval not met");
        vm.prank(recipient1);
        distribution.claimTokens(roundId, recipient1);
    }

    function testNonRecipientCannotClaim() public {
        uint256 totalTokens = 1000 * 10 ** 18;
        uint256 minInterval = 1 hours;
        uint256 numberOfClaimsRequired = 5;
        address[] memory recipients = new address[](2);
        recipients[0] = recipient1;

        token.approve(address(distribution), totalTokens);
        uint256 roundId = distribution.startNewRound(
            address(token),
            recipients,
            minInterval,
            totalTokens,
            numberOfClaimsRequired
        );

        vm.warp(block.timestamp + minInterval);

        // Attempt claim from non-recipient (should revert)
        vm.expectRevert("Not a recipient");
        vm.prank(recipient2);
        distribution.claimTokens(roundId, recipient2);
    }

    function testAutoRoundEnding() public {
        uint256 totalTokens = 1000 * 10 ** 18;
        uint256 minInterval = 1 hours;
        uint256 numberOfClaimsRequired = 5;
        address[] memory recipients = new address[](1);
        recipients[0] = recipient1;

        token.approve(address(distribution), totalTokens);
        uint256 roundId = distribution.startNewRound(
            address(token),
            recipients,
            minInterval,
            totalTokens,
            numberOfClaimsRequired
        );

        vm.warp(block.timestamp + minInterval);

        for (uint256 i = 0; i < numberOfClaimsRequired; i++) {
            vm.prank(recipient1);
            distribution.claimTokens(roundId, recipient1);
            vm.warp(block.timestamp + minInterval);
        }

        (, , , , uint256 remainingTokens, , bool isActive, ) = distribution
            .rounds(roundId);
        assertFalse(isActive, "Round should be ended");
        assertEq(remainingTokens, 0, "All tokens should be claimed");
    }
}
