// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "../lib/openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ReentrancyGuard} from "../lib/openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title DegenGambit
/// @notice This is the game contract for Degen's Gambit, a permissionless slot machine game.
/// @notice Degen's Gambit comes with a streak mechanic. Players get an ERC20 GAMBIT token every time
/// they extend their streak. They can spend a GAMBIT token to spin with improved odds of winning.
contract DegenGambit is ERC20, ReentrancyGuard {
    // Cumulative mass functions for probability distributions. Total mass for each distribution is 2^30 = 1073741824.
    // These values were generated by the game design notebook. If you know, you know.

    /// Cumulative mass function for the UnmodifiedLeftReel
    uint256[19] public UnmodifiedLeftReel = [
        0 + 24970744, // 0 - 0 (null)
        24970744 + 99882960, // 1 - Gold star (minor)
        124853704 + 49941480, // 2 - Diamonds (suit) (minor)
        174795184 + 49941480, // 3 - Clubs (suit) (minor)
        224736664 + 99882960, // 4 - Spades (suit) (minor)
        324619624 + 49941480, // 5 - Hearts (suit) (minor)
        374561104 + 49941480, // 6 - Diamond (gem) (minor)
        424502584 + 99882960, // 7 - Banana (minor)
        524385544 + 49941480, // 8 - Cherry (minor)
        574327024 + 49941480, // 9 - Pineapple (minor)
        624268504 + 99882960, // 10 - Orange (minor)
        724151464 + 49941480, // 11 - Apple (minor)
        774092944 + 49941480, // 12 - Bell (minor)
        824034424 + 99882960, // 13 - Gold coin (minor)
        923917384 + 49941480, // 14 - Crescent moon (minor)
        973858864 + 49941480, // 15 - Full moon (minor)
        1023800344 + 24970740, // 16 - Gold 7 (major)
        1048771084 + 12485370, // 17 - Red 7 (major)
        1061256454 + 12485370 // 18 - Diamond 7 (major)
    ];

    /// Cumulative mass function for the UnmodifiedCenterReel
    uint256[19] public UnmodifiedCenterReel = [
        0 + 24970744, // 0 - 0 (null)
        24970744 + 49941480, // 1 - Gold star (minor)
        74912224 + 99882960, // 2 - Diamonds (suit) (minor)
        174795184 + 49941480, // 3 - Clubs (suit) (minor)
        224736664 + 49941480, // 4 - Spades (suit) (minor)
        274678144 + 99882960, // 5 - Hearts (suit) (minor)
        374561104 + 49941480, // 6 - Diamond (gem) (minor)
        424502584 + 49941480, // 7 - Banana (minor)
        474444064 + 99882960, // 8 - Cherry (minor)
        574327024 + 49941480, // 9 - Pineapple (minor)
        624268504 + 49941480, // 10 - Orange (minor)
        674209984 + 99882960, // 11 - Apple (minor)
        774092944 + 49941480, // 12 - Bell (minor)
        824034424 + 49941480, // 13 - Gold coin (minor)
        873975904 + 99882960, // 14 - Crescent moon (minor)
        973858864 + 49941480, // 15 - Full moon (minor)
        1023800344 + 12485370, // 16 - Gold 7 (major)
        1036285714 + 24970740, // 17 - Red 7 (major)
        1061256454 + 12485370 // 18 - Diamond 7 (major)
    ];

    /// Cumulative mass function for the UnmodifiedCenterReel
    uint256[19] public UnmodifiedRightReel = [
        0 + 24970744, // 0 - 0 (null)
        24970744 + 49941480, // 1 - Gold star (minor)
        74912224 + 49941480, // 2 - Diamonds (suit) (minor)
        124853704 + 99882960, // 3 - Clubs (suit) (minor)
        224736664 + 49941480, // 4 - Spades (suit) (minor)
        274678144 + 49941480, // 5 - Hearts (suit) (minor)
        324619624 + 99882960, // 6 - Diamond (gem) (minor)
        424502584 + 49941480, // 7 - Banana (minor)
        474444064 + 49941480, // 8 - Cherry (minor)
        524385544 + 99882960, // 9 - Pineapple (minor)
        624268504 + 49941480, // 10 - Orange (minor)
        674209984 + 49941480, // 11 - Apple (minor)
        724151464 + 99882960, // 12 - Bell (minor)
        824034424 + 49941480, // 13 - Gold coin (minor)
        873975904 + 49941480, // 14 - Crescent moon (minor)
        923917384 + 99882960, // 15 - Full moon (minor)
        1023800344 + 12485370, // 16 - Gold 7 (major)
        1036285714 + 12485370, // 17 - Red 7 (major)
        1048771084 + 24970740 // 18 - Diamond 7 (major)
    ];

    /// Cumulative mass function for the ImprovedLeftReel
    uint256[19] public ImprovedLeftReel = [
        0 + 2526414, // 0 - 0 (null)
        2526414 + 102068183, // 1 - Gold star (minor)
        104594597 + 51034067, // 2 - Diamonds (suit) (minor)
        155628664 + 51034067, // 3 - Clubs (suit) (minor)
        206662731 + 102068183, // 4 - Spades (suit) (minor)
        308730914 + 51034067, // 5 - Hearts (suit) (minor)
        359764981 + 51034067, // 6 - Diamond (gem) (minor)
        410799048 + 102068183, // 7 - Banana (minor)
        512867231 + 51034067, // 8 - Cherry (minor)
        563901298 + 51034067, // 9 - Pineapple (minor)
        614935365 + 102068183, // 10 - Orange (minor)
        717003548 + 51034067, // 11 - Apple (minor)
        768037615 + 51034067, // 12 - Bell (minor)
        819071682 + 102068183, // 13 - Gold coin (minor)
        921139865 + 51034067, // 14 - Crescent moon (minor)
        972173932 + 51034067, // 15 - Full moon (minor)
        1023207999 + 25266913, // 16 - Gold 7 (major)
        1048474912 + 12633456, // 17 - Red 7 (major)
        1061108368 + 12633456 // 18 - Diamond 7 (major)
    ];

    /// Cumulative mass function for the ImprovedCenterReel
    uint256[19] public ImprovedCenterReel = [
        0 + 2526414, // 0 - 0 (null)
        2526414 + 51034067, // 1 - Gold star (minor)
        53560481 + 102068183, // 2 - Diamonds (suit) (minor)
        155628664 + 51034067, // 3 - Clubs (suit) (minor)
        206662731 + 51034067, // 4 - Spades (suit) (minor)
        257696798 + 102068183, // 5 - Hearts (suit) (minor)
        359764981 + 51034067, // 6 - Diamond (gem) (minor)
        410799048 + 51034067, // 7 - Banana (minor)
        461833115 + 102068183, // 8 - Cherry (minor)
        563901298 + 51034067, // 9 - Pineapple (minor)
        614935365 + 51034067, // 10 - Orange (minor)
        665969432 + 102068183, // 11 - Apple (minor)
        768037615 + 51034067, // 12 - Bell (minor)
        819071682 + 51034067, // 13 - Gold coin (minor)
        870105749 + 102068183, // 14 - Crescent moon (minor)
        972173932 + 51034067, // 15 - Full moon (minor)
        1023207999 + 12633456, // 16 - Gold 7 (major)
        1035841455 + 25266913, // 17 - Red 7 (major)
        1061108368 + 12633456 // 18 - Diamond 7 (major)
    ];

    /// Cumulative mass function for the ImprovedCenterReel
    uint256[19] public ImprovedRightReel = [
        0 + 2526414, // 0 - 0 (null)
        2526414 + 51034067, // 1 - Gold star (minor)
        53560481 + 51034067, // 2 - Diamonds (suit) (minor)
        104594548 + 102068183, // 3 - Clubs (suit) (minor)
        206662731 + 51034067, // 4 - Spades (suit) (minor)
        257696798 + 51034067, // 5 - Hearts (suit) (minor)
        308730865 + 102068183, // 6 - Diamond (gem) (minor)
        410799048 + 51034067, // 7 - Banana (minor)
        461833115 + 51034067, // 8 - Cherry (minor)
        512867182 + 102068183, // 9 - Pineapple (minor)
        614935365 + 51034067, // 10 - Orange (minor)
        665969432 + 51034067, // 11 - Apple (minor)
        717003499 + 102068183, // 12 - Bell (minor)
        819071682 + 51034067, // 13 - Gold coin (minor)
        870105749 + 51034067, // 14 - Crescent moon (minor)
        921139816 + 102068183, // 15 - Full moon (minor)
        1023207999 + 12633456, // 16 - Gold 7 (major)
        1035841455 + 12633456, // 17 - Red 7 (major)
        1048474911 + 25266913 // 18 - Diamond 7 (major)
    ];

    /// How many blocks a player has to act (respin/accept).
    uint256 public BlocksToAct;

    /// The block number of the last spin/respin by each player.
    mapping(address => uint256) public LastSpinBlock;

    /// Whether or not the last spin for a given player is a boosted spin.
    mapping(address => bool) public LastSpinBoosted;

    /// Cost (finest denomination of native token on the chain) to roll.
    uint256 public CostToSpin;

    /// Cost (finest denomination of native token on the chain) to reroll.
    uint256 public CostToRespin;

    // TODO(zomglings): Add streak mechanic.

    /// Fired when a player spins (and respins).
    event Spin(address indexed player, bool indexed bonus);
    /// Fired when a player accepts the outcome of a roll.
    event Award(address indexed player, uint256 value);

    /// Signifies that the player is no longer able to act because too many blocks elapsed since their
    /// last action.
    error DeadlineExceeded();
    /// This error is raised to signify that the player needs to wait for at least one more block to elapse.
    error WaitForTick();
    /// Signifies that the player has not provided enough value to perform the action.
    error InsufficientValue();

    function supportsInterface(bytes4 interfaceID) public pure returns (bool) {
        return
            interfaceID == 0x01ffc9a7 || // ERC-165 support (i.e. `bytes4(keccak256('supportsInterface(bytes4)'))`).
            interfaceID == 0x36372b07; // ERC20 support -- all methods on OpenZeppelin IERC20 excluding "name", "symbol", and "decimals".
    }

    /// In addition to the game mechanics, DegensGambit is also an ERC20 contract in which the ERC20
    /// tokens represent bonus spins. The symbol for this contract is GAMBIT.
    constructor(
        uint256 blocksToAct,
        uint256 costToSpin,
        uint256 costToRespin
    ) ERC20("Degen's Gambit", "GAMBIT") {
        BlocksToAct = blocksToAct;
        CostToSpin = costToSpin;
        CostToRespin = costToRespin;
    }

    /// Allows the contract to receive the native token on its blockchain.
    receive() external payable {}

    /// The GAMBIT token (representing bonus rolls on the Degen's Gambit slot machine) has 0 decimals.
    function decimals() public pure override returns (uint8) {
        return 0;
    }

    function _enforceTick(address degenerate) internal view {
        if (block.number <= LastSpinBlock[degenerate]) {
            revert WaitForTick();
        }
    }

    function _enforceDeadline(address degenerate) internal view {
        if (block.number > LastSpinBlock[degenerate] + BlocksToAct) {
            revert DeadlineExceeded();
        }
    }
}