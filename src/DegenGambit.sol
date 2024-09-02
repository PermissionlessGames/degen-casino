// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "../lib/openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ReentrancyGuard} from "../lib/openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title DegenGambit
/// @notice This is the game contract for Degen's Gambit, a permissionless slot machine game.
/// @notice Degen's Gambit comes with a streak mechanic. Players get an ERC20 GAMBIT token every time
/// they extend their streak. They can spend a GAMBIT token to spin with improved odds of winning.
contract DegenGambit is ERC20, ReentrancyGuard {
    uint256 private constant BITS_30 = 0x3FFFFFFF;

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
    /// Signifies that a reel outcome is out of bounds.
    error OutcomeOutOfBounds();

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

    function _entropy(
        address degenerate
    ) internal view virtual returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encode(blockhash(LastSpinBlock[degenerate]), degenerate)
                )
            );
    }

    /// sampleUnmodifiedLeftReel samples the outcome from UnmodifiedLeftReel specified by the given entropy
    function sampleUnmodifiedLeftReel(
        uint256 entropy
    ) public view returns (uint256) {
        uint256 sample = (entropy >> 60) & BITS_30;
        if (sample < UnmodifiedLeftReel[0]) {
            return 0;
        } else if (sample < UnmodifiedLeftReel[1]) {
            return 1;
        } else if (sample < UnmodifiedLeftReel[2]) {
            return 2;
        } else if (sample < UnmodifiedLeftReel[3]) {
            return 3;
        } else if (sample < UnmodifiedLeftReel[4]) {
            return 4;
        } else if (sample < UnmodifiedLeftReel[5]) {
            return 5;
        } else if (sample < UnmodifiedLeftReel[6]) {
            return 6;
        } else if (sample < UnmodifiedLeftReel[7]) {
            return 7;
        } else if (sample < UnmodifiedLeftReel[8]) {
            return 8;
        } else if (sample < UnmodifiedLeftReel[9]) {
            return 9;
        } else if (sample < UnmodifiedLeftReel[10]) {
            return 10;
        } else if (sample < UnmodifiedLeftReel[11]) {
            return 11;
        } else if (sample < UnmodifiedLeftReel[12]) {
            return 12;
        } else if (sample < UnmodifiedLeftReel[13]) {
            return 13;
        } else if (sample < UnmodifiedLeftReel[14]) {
            return 14;
        } else if (sample < UnmodifiedLeftReel[15]) {
            return 15;
        } else if (sample < UnmodifiedLeftReel[16]) {
            return 16;
        } else if (sample < UnmodifiedLeftReel[17]) {
            return 17;
        }
        return 18;
    }

    /// sampleUnmodifiedCenterReel samples the outcome from UnmodifiedCenterReel specified by the given entropy
    function sampleUnmodifiedCenterReel(
        uint256 entropy
    ) public view returns (uint256) {
        uint256 sample = (entropy >> 30) & BITS_30;
        if (sample < UnmodifiedCenterReel[0]) {
            return 0;
        } else if (sample < UnmodifiedCenterReel[1]) {
            return 1;
        } else if (sample < UnmodifiedCenterReel[2]) {
            return 2;
        } else if (sample < UnmodifiedCenterReel[3]) {
            return 3;
        } else if (sample < UnmodifiedCenterReel[4]) {
            return 4;
        } else if (sample < UnmodifiedCenterReel[5]) {
            return 5;
        } else if (sample < UnmodifiedCenterReel[6]) {
            return 6;
        } else if (sample < UnmodifiedCenterReel[7]) {
            return 7;
        } else if (sample < UnmodifiedCenterReel[8]) {
            return 8;
        } else if (sample < UnmodifiedCenterReel[9]) {
            return 9;
        } else if (sample < UnmodifiedCenterReel[10]) {
            return 10;
        } else if (sample < UnmodifiedCenterReel[11]) {
            return 11;
        } else if (sample < UnmodifiedCenterReel[12]) {
            return 12;
        } else if (sample < UnmodifiedCenterReel[13]) {
            return 13;
        } else if (sample < UnmodifiedCenterReel[14]) {
            return 14;
        } else if (sample < UnmodifiedCenterReel[15]) {
            return 15;
        } else if (sample < UnmodifiedCenterReel[16]) {
            return 16;
        } else if (sample < UnmodifiedCenterReel[17]) {
            return 17;
        }
        return 18;
    }

    /// sampleUnmodifiedRightReel samples the outcome from UnmodifiedRightReel specified by the given entropy
    function sampleUnmodifiedRightReel(
        uint256 entropy
    ) public view returns (uint256) {
        uint256 sample = entropy & BITS_30;
        if (sample < UnmodifiedRightReel[0]) {
            return 0;
        } else if (sample < UnmodifiedRightReel[1]) {
            return 1;
        } else if (sample < UnmodifiedRightReel[2]) {
            return 2;
        } else if (sample < UnmodifiedRightReel[3]) {
            return 3;
        } else if (sample < UnmodifiedRightReel[4]) {
            return 4;
        } else if (sample < UnmodifiedRightReel[5]) {
            return 5;
        } else if (sample < UnmodifiedRightReel[6]) {
            return 6;
        } else if (sample < UnmodifiedRightReel[7]) {
            return 7;
        } else if (sample < UnmodifiedRightReel[8]) {
            return 8;
        } else if (sample < UnmodifiedRightReel[9]) {
            return 9;
        } else if (sample < UnmodifiedRightReel[10]) {
            return 10;
        } else if (sample < UnmodifiedRightReel[11]) {
            return 11;
        } else if (sample < UnmodifiedRightReel[12]) {
            return 12;
        } else if (sample < UnmodifiedRightReel[13]) {
            return 13;
        } else if (sample < UnmodifiedRightReel[14]) {
            return 14;
        } else if (sample < UnmodifiedRightReel[15]) {
            return 15;
        } else if (sample < UnmodifiedRightReel[16]) {
            return 16;
        } else if (sample < UnmodifiedRightReel[17]) {
            return 17;
        }
        return 18;
    }

    /// sampleImprovedLeftReel samples the outcome from ImprovedLeftReel specified by the given entropy
    function sampleImprovedLeftReel(
        uint256 entropy
    ) public view returns (uint256) {
        uint256 sample = (entropy >> 60) & BITS_30;
        if (sample < ImprovedLeftReel[0]) {
            return 0;
        } else if (sample < ImprovedLeftReel[1]) {
            return 1;
        } else if (sample < ImprovedLeftReel[2]) {
            return 2;
        } else if (sample < ImprovedLeftReel[3]) {
            return 3;
        } else if (sample < ImprovedLeftReel[4]) {
            return 4;
        } else if (sample < ImprovedLeftReel[5]) {
            return 5;
        } else if (sample < ImprovedLeftReel[6]) {
            return 6;
        } else if (sample < ImprovedLeftReel[7]) {
            return 7;
        } else if (sample < ImprovedLeftReel[8]) {
            return 8;
        } else if (sample < ImprovedLeftReel[9]) {
            return 9;
        } else if (sample < ImprovedLeftReel[10]) {
            return 10;
        } else if (sample < ImprovedLeftReel[11]) {
            return 11;
        } else if (sample < ImprovedLeftReel[12]) {
            return 12;
        } else if (sample < ImprovedLeftReel[13]) {
            return 13;
        } else if (sample < ImprovedLeftReel[14]) {
            return 14;
        } else if (sample < ImprovedLeftReel[15]) {
            return 15;
        } else if (sample < ImprovedLeftReel[16]) {
            return 16;
        } else if (sample < ImprovedLeftReel[17]) {
            return 17;
        }
        return 18;
    }

    /// sampleImprovedCenterReel samples the outcome from ImprovedCenterReel specified by the given entropy
    function sampleImprovedCenterReel(
        uint256 entropy
    ) public view returns (uint256) {
        uint256 sample = (entropy >> 30) & BITS_30;
        if (sample < ImprovedCenterReel[0]) {
            return 0;
        } else if (sample < ImprovedCenterReel[1]) {
            return 1;
        } else if (sample < ImprovedCenterReel[2]) {
            return 2;
        } else if (sample < ImprovedCenterReel[3]) {
            return 3;
        } else if (sample < ImprovedCenterReel[4]) {
            return 4;
        } else if (sample < ImprovedCenterReel[5]) {
            return 5;
        } else if (sample < ImprovedCenterReel[6]) {
            return 6;
        } else if (sample < ImprovedCenterReel[7]) {
            return 7;
        } else if (sample < ImprovedCenterReel[8]) {
            return 8;
        } else if (sample < ImprovedCenterReel[9]) {
            return 9;
        } else if (sample < ImprovedCenterReel[10]) {
            return 10;
        } else if (sample < ImprovedCenterReel[11]) {
            return 11;
        } else if (sample < ImprovedCenterReel[12]) {
            return 12;
        } else if (sample < ImprovedCenterReel[13]) {
            return 13;
        } else if (sample < ImprovedCenterReel[14]) {
            return 14;
        } else if (sample < ImprovedCenterReel[15]) {
            return 15;
        } else if (sample < ImprovedCenterReel[16]) {
            return 16;
        } else if (sample < ImprovedCenterReel[17]) {
            return 17;
        }
        return 18;
    }

    /// sampleImprovedRightReel samples the outcome from ImprovedRightReel specified by the given entropy
    function sampleImprovedRightReel(
        uint256 entropy
    ) public view returns (uint256) {
        uint256 sample = entropy & BITS_30;
        if (sample < ImprovedRightReel[0]) {
            return 0;
        } else if (sample < ImprovedRightReel[1]) {
            return 1;
        } else if (sample < ImprovedRightReel[2]) {
            return 2;
        } else if (sample < ImprovedRightReel[3]) {
            return 3;
        } else if (sample < ImprovedRightReel[4]) {
            return 4;
        } else if (sample < ImprovedRightReel[5]) {
            return 5;
        } else if (sample < ImprovedRightReel[6]) {
            return 6;
        } else if (sample < ImprovedRightReel[7]) {
            return 7;
        } else if (sample < ImprovedRightReel[8]) {
            return 8;
        } else if (sample < ImprovedRightReel[9]) {
            return 9;
        } else if (sample < ImprovedRightReel[10]) {
            return 10;
        } else if (sample < ImprovedRightReel[11]) {
            return 11;
        } else if (sample < ImprovedRightReel[12]) {
            return 12;
        } else if (sample < ImprovedRightReel[13]) {
            return 13;
        } else if (sample < ImprovedRightReel[14]) {
            return 14;
        } else if (sample < ImprovedRightReel[15]) {
            return 15;
        } else if (sample < ImprovedRightReel[16]) {
            return 16;
        } else if (sample < ImprovedRightReel[17]) {
            return 17;
        }
        return 18;
    }

    /// Returns the final symbols on the left, center, and right reels respectively for a spin with
    /// the given entropy. The unused entropy is also returned for use by game clients.
    /// @param entropy The entropy created by the spin.
    /// @param boosted Whether or not the spin was boosted.
    function outcome(
        uint256 entropy,
        bool boosted
    )
        public
        view
        returns (
            uint256 left,
            uint256 center,
            uint256 right,
            uint256 remainingEntropy
        )
    {
        if (boosted) {
            left = sampleImprovedLeftReel(entropy);
            center = sampleImprovedCenterReel(entropy);
            right = sampleImprovedRightReel(entropy);
        } else {
            left = sampleUnmodifiedLeftReel(entropy);
            center = sampleUnmodifiedCenterReel(entropy);
            right = sampleUnmodifiedRightReel(entropy);
        }

        remainingEntropy = entropy >> 90;
    }

    /// Payout function for symbol combinations.
    function payout(
        uint256 left,
        uint256 center,
        uint256 right
    ) public view returns (uint256 result) {
        if (left >= 19 || center >= 19 || right >= 19) {
            revert OutcomeOutOfBounds();
        }

        result = 0;

        if (left == center && center == right) {
            // 3 of a kind combos.
            // Note: (null, null, null) does not pay out.
            if (left >= 1 && left <= 15) {
                // 3 of a kind with a minor symbol.
                result = 50 * CostToSpin;
                if (result > address(this).balance >> 6) {
                    result = address(this).balance >> 6;
                }
            } else if (left >= 16) {
                // 3 of a kind with a major symbol. Jackpot!
                result = address(this).balance >> 1;
            }
        } else if (left == right) {
            // Outer pair combos.
            if (left >= 1 && left <= 15 && center >= 16) {
                // Minor symbol pair on outside reels with major symbol in the center.
                result = 100 * CostToSpin;
                if (result > address(this).balance >> 4) {
                    result = address(this).balance >> 4;
                }
            }
            // We handle the case of a minor symbol pair on the outside with a major symbol in the center
            // in the next top-level branch instead together with the case of three distinct major symbols.
        } else if (
            left >= 16 &&
            right >= 16 &&
            center >= 16 &&
            left != center &&
            right != center
        ) {
            // Three distinct major symbols.
            // OR
            // Major symbol pair on the outside with a different major symbol in the center.
            result = address(this).balance >> 3;
        }
    }

    /// This is the function a player calls to accept the outcome of a spin.
    /// @dev msg.sender is assumed to be the player. This call cannot be delegated to a different account.
    function accept()
        external
        nonReentrant
        returns (
            uint256 left,
            uint256 center,
            uint256 right,
            uint256 remainingEntropy
        )
    {
        _enforceTick(msg.sender);
        _enforceDeadline(msg.sender);

        (left, center, right, remainingEntropy) = outcome(
            _entropy(msg.sender),
            LastSpinBoosted[msg.sender]
        );
        uint256 award = payout(left, center, right);
        payable(msg.sender).transfer(award);
        emit Award(msg.sender, award);

        delete LastSpinBoosted[msg.sender];
        delete LastSpinBlock[msg.sender];
    }

    function spinCost(address degenerate) public view returns (uint256) {
        if (block.number <= LastSpinBlock[degenerate] + BlocksToAct) {
            // This means that all degenerates playing in the first BlocksToAct blocks produced on the blockchain
            // get a discount on their early spins.
            return CostToRespin;
        }
        return CostToSpin;
    }

    /// Spin the slot machine.
    /// @notice If the player sends more value than they absolutely need to, the contract simply accepts it into the pot.
    /// @dev msg.sender is assumed to be the player. This call cannot be delegated to a different account.
    /// @param boost Whether or not the player is using a boost.
    function spin(bool boost) external payable {
        uint256 requiredFee = spinCost(msg.sender);
        if (msg.value < requiredFee) {
            revert InsufficientValue();
        }

        if (boost) {
            // Burn an ERC20 token off of this contract from the player's account.
            _burn(msg.sender, 1);
        }

        LastSpinBlock[msg.sender] = block.number;
        delete LastSpinBoosted[msg.sender];

        emit Spin(msg.sender, boost);
    }
}
