// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

// Interface generated by solface: https://github.com/moonstream-to/solface
// solface version: 0.2.3
// Interface ID: 054d9958
interface IDegenGambit {
	// structs

	// events
	event Approval(address owner, address spender, uint256 value);
	event Award(address player, uint256 value);
	event DailyStreak(address player, uint256 day);
	event Spin(address player, bool bonus);
	event Transfer(address from, address to, uint256 value);
	event WeeklyStreak(address player, uint256 week);

	// functions
	// Selector: be59cce3
	function BlocksToAct() external view returns (uint256);
	// Selector: e4a2e5b3
	function CostToRespin() external view returns (uint256);
	// Selector: ab6282c8
	function CostToSpin() external view returns (uint256);
	// Selector: cf71aae2
	function CurrentDailyStreakLength(address ) external view returns (uint256);
	// Selector: 215a57c1
	function CurrentWeeklyStreakLength(address ) external view returns (uint256);
	// Selector: df43230f
	function DailyStreakReward() external view returns (uint256);
	// Selector: 81e61c7f
	function GambitPrize() external view returns (uint256);
	// Selector: 1e3dac95
	function ImprovedCenterReel(uint256 ) external view returns (uint256);
	// Selector: 1b502962
	function ImprovedLeftReel(uint256 ) external view returns (uint256);
	// Selector: d19476a0
	function ImprovedRightReel(uint256 ) external view returns (uint256);
	// Selector: 65d032ea
	function LastSpinBlock(address ) external view returns (uint256);
	// Selector: dd6fc50f
	function LastSpinBoosted(address ) external view returns (bool);
	// Selector: fcb13e26
	function LastStreakDay(address ) external view returns (uint256);
	// Selector: 21c58fba
	function LastStreakWeek(address ) external view returns (uint256);
	// Selector: bd0ebd4b
	function UnmodifiedCenterReel(uint256 ) external view returns (uint256);
	// Selector: 2c932d01
	function UnmodifiedLeftReel(uint256 ) external view returns (uint256);
	// Selector: 39fdf45f
	function UnmodifiedRightReel(uint256 ) external view returns (uint256);
	// Selector: 97c87050
	function WeeklyStreakReward() external view returns (uint256);
	// Selector: 2852b71c
	function accept() external  returns (uint256 left, uint256 center, uint256 right, uint256 remainingEntropy, uint256 prize);
	// Selector: 2c687117
	function acceptFor(address player) external  returns (uint256 left, uint256 center, uint256 right, uint256 remainingEntropy, uint256 prize);
	// Selector: dd62ed3e
	function allowance(address owner, address spender) external view returns (uint256);
	// Selector: 095ea7b3
	function approve(address spender, uint256 value) external  returns (bool);
	// Selector: 70a08231
	function balanceOf(address account) external view returns (uint256);
	// Selector: 313ce567
	function decimals() external pure returns (uint8);
	// Selector: 968a2c9a
	function hasPrize(address player) external view returns (bool toReceive);
	// Selector: 17df75a8
	function inspectEntropy(address degenerate) external view returns (uint256);
	// Selector: eca8b788
	function inspectOutcome(address degenerate) external view returns (uint256 left, uint256 center, uint256 right, uint256 remainingEntropy, uint256 prize, uint256 typeOfPrize);
	// Selector: 06fdde03
	function name() external view returns (string memory);
	// Selector: 090ec510
	function outcome(uint256 entropy, bool boosted) external view returns (uint256 left, uint256 center, uint256 right, uint256 remainingEntropy);
	// Selector: b3dfa13d
	function payout(uint256 left, uint256 center, uint256 right) external view returns (uint256 result, uint256 typeOfPrize);
	// Selector: 11cceaf6
	function prizes() external view returns (uint256[] memory prizesAmount, uint256[] memory typeOfPrize);
	// Selector: 82e82634
	function sampleImprovedCenterReel(uint256 entropy) external view returns (uint256);
	// Selector: bac1d231
	function sampleImprovedLeftReel(uint256 entropy) external view returns (uint256);
	// Selector: a8b530e4
	function sampleImprovedRightReel(uint256 entropy) external view returns (uint256);
	// Selector: 873c1227
	function sampleUnmodifiedCenterReel(uint256 entropy) external view returns (uint256);
	// Selector: fcb9f003
	function sampleUnmodifiedLeftReel(uint256 entropy) external view returns (uint256);
	// Selector: 02de1a7e
	function sampleUnmodifiedRightReel(uint256 entropy) external view returns (uint256);
	// Selector: 6499572f
	function spin(bool boost) external ;
	// Selector: 6f785558
	function spinCost(address degenerate) external view returns (uint256);
	// Selector: 2b10c68b
	function spinFor(address spinPlayer, address streakPlayer, bool boost) external ;
	// Selector: 01ffc9a7
	function supportsInterface(bytes4 interfaceID) external pure returns (bool);
	// Selector: 95d89b41
	function symbol() external view returns (string memory);
	// Selector: 18160ddd
	function totalSupply() external view returns (uint256);
	// Selector: a9059cbb
	function transfer(address to, uint256 value) external  returns (bool);
	// Selector: 23b872dd
	function transferFrom(address from, address to, uint256 value) external  returns (bool);
	// Selector: 54fd4d50
	function version() external pure returns (string memory);

	// errors
	error DeadlineExceeded();
	error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
	error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
	error ERC20InvalidApprover(address approver);
	error ERC20InvalidReceiver(address receiver);
	error ERC20InvalidSender(address sender);
	error ERC20InvalidSpender(address spender);
	error FailedPrizeTransfer();
	error InsufficientValue();
	error OutcomeOutOfBounds();
	error ReentrancyGuardReentrantCall();
	error WaitForTick();
}
