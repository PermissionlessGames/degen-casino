// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IERC20} from "../lib/openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "../lib/openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {EIP712} from "../lib/openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {SignatureChecker} from "../lib/openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

string constant AccountSystemVersion = "1";
string constant AccountVersion = "1";

/// @notice Terms for executor compensation
/// @notice Arrays for tokens and their corresponding basis points are zipped together to process executor compensation.
/// They should be the same length.
/// @notice Use address(0) in rewardTokens to signify native token of the chain the account is on.
/// @notice Basis points for a reward token are applied to the difference between DegenCasinoAccount's balances (in that token)
/// at the end and beginning of a game action. If this difference is positive, that number of basis points are deducted from the
/// DegenCasinoAccount and transferred to the executor. If this difference is negative, nothing is transferred to the executor.
struct ExecutorTerms {
    address[] rewardTokens;
    uint16[] basisPoints;
}

/// @notice A game action to be executed
/// @param game The target game contract to execute the action on
/// @param data The encoded function call data to send to the game contract
/// @param value The amount of native tokens to send with the call
/// @param request Monotonically increasing request ID to prevent replay attacks
struct Action {
    address game;
    bytes data;
    uint256 value;
    uint256 request;
}

/// @title DegenCasinoAccount
/// @notice Player smart accounts for The Degen Casino.
contract DegenCasinoAccount is EIP712 {
    using SafeERC20 for IERC20;

    address public player;
    string public constant accountVersion = AccountVersion;
    uint256 public lastRequest;

    error Unauthorized();
    error Unsuccessful();
    error MismatchedArrayLengths();
    error RequestTooLow();
    error InvalidPlayerActionSignature();
    error InvalidPlayerTermsSignature();
    error FailedToSendReward();
    error ActionFailed();

    constructor(address _player) EIP712("DegenCasinoAccount", AccountVersion) {
        player = _player;
    }

    /// @notice Used to deposit native tokens to the DegenCasinoAccount.
    receive() external payable {}

    /// @notice Withdraw multiple different tokens (native or ERC20) from the DegenCasinoAccount in a single transaction.
    function withdraw(
        address[] memory tokenAddresses,
        uint256[] memory amounts
    ) public {
        if (msg.sender != player) {
            revert Unauthorized();
        }

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            if (tokenAddresses[i] == address(0)) {
                // Native token case
                (bool success, ) = payable(player).call{value: amounts[i]}("");
                if (!success) {
                    revert Unsuccessful();
                }
            } else {
                // ERC20 token case
                IERC20(tokenAddresses[i]).transfer(player, amounts[i]);
            }
        }
    }

    /// @notice Used to drain native tokens or ERC20 tokens from the DegenCasinoAccount.
    function drain(address[] memory tokenAddresses) public {
        if (msg.sender != player) {
            revert Unauthorized();
        }

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            uint256 amount;

            if (tokenAddresses[i] == address(0)) {
                amount = address(this).balance;
                // Native token case
                (bool success, ) = payable(player).call{value: amount}("");
                if (!success) {
                    revert Unsuccessful();
                }
            } else {
                // ERC20 token case
                IERC20 token = IERC20(tokenAddresses[i]);
                amount = token.balanceOf(address(this));
                token.transfer(player, amount);
            }
        }
    }

    /// @notice Computes the EIP712 hash of executor terms
    /// @param terms The executor terms to hash
    /// @return The EIP712 hash of the terms
    function executorTermsHash(
        ExecutorTerms memory terms
    ) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "ExecutorTerms(address[] rewardTokens,uint16[] basisPoints)"
                        ),
                        keccak256(abi.encodePacked(terms.rewardTokens)),
                        keccak256(abi.encodePacked(terms.basisPoints))
                    )
                )
            );
    }

    /// @notice Computes the EIP712 hash of a game action
    /// @param action The action to hash
    /// @return The EIP712 hash of the action
    function actionHash(Action memory action) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "Action(address game,bytes data,uint256 value,uint256 request)"
                        ),
                        action.game,
                        keccak256(action.data),
                        action.value,
                        action.request
                    )
                )
            );
    }

    /// @notice Computes the EIP712 hash of a session
    /// @param executor The executor authorized by the player
    /// @param sessionID The session ID
    /// @param expiration The expiration timestamp of the session
    /// @return The EIP712 hash of the session
    function sessionHash(
        address executor,
        uint256 sessionID,
        uint256 expiration
    ) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "Session(address executor,uint256 sessionID,uint256 expiration)"
                        ),
                        executor,
                        sessionID,
                        expiration
                    )
                )
            );
    }

    /// @notice Executes a game action with executor compensation
    /// @dev Verifies signatures, executes the action, and pays the executor based on profit
    /// @param action The game action to execute
    /// @param terms The executor's compensation terms
    /// @param playerActionSignature The player's signature for the action
    /// @param playerTermsSignature The player's signature for the executor terms
    function play(
        Action memory action,
        ExecutorTerms memory terms,
        bytes memory playerActionSignature,
        bytes memory playerTermsSignature
    ) external {
        if (action.request <= lastRequest) {
            revert RequestTooLow();
        }
        if (terms.rewardTokens.length != terms.basisPoints.length) {
            revert MismatchedArrayLengths();
        }

        lastRequest = action.request;

        // Verify signatures
        bytes32 providedActionHash = actionHash(action);
        bytes32 providedTermsHash = executorTermsHash(terms);

        if (
            !SignatureChecker.isValidSignatureNow(
                player,
                providedActionHash,
                playerActionSignature
            )
        ) {
            revert InvalidPlayerActionSignature();
        }
        if (
            !SignatureChecker.isValidSignatureNow(
                player,
                providedTermsHash,
                playerTermsSignature
            )
        ) {
            revert InvalidPlayerTermsSignature();
        }

        // Execute the game action and handle rewards
        _play(action, terms);
    }

    /// @notice Internal function to execute the game action and pay executor rewards
    /// @param action The game action to execute
    /// @param terms The executor's compensation terms
    function _play(Action memory action, ExecutorTerms memory terms) internal {
        // Record starting balances
        uint256[] memory startBalances = new uint256[](
            terms.rewardTokens.length
        );
        for (uint256 i = 0; i < terms.rewardTokens.length; i++) {
            if (terms.rewardTokens[i] == address(0)) {
                startBalances[i] = address(this).balance;
            } else {
                startBalances[i] = IERC20(terms.rewardTokens[i]).balanceOf(
                    address(this)
                );
            }
        }

        // Execute the game action
        (bool success, ) = action.game.call{value: action.value}(action.data);
        if (!success) {
            revert ActionFailed();
        }

        // Calculate and pay executor rewards
        for (uint256 i = 0; i < terms.rewardTokens.length; i++) {
            uint256 endBalance;
            if (terms.rewardTokens[i] == address(0)) {
                endBalance = address(this).balance;
            } else {
                endBalance = IERC20(terms.rewardTokens[i]).balanceOf(
                    address(this)
                );
            }

            // Only pay rewards on profit
            if (endBalance > startBalances[i]) {
                uint256 profit = endBalance - startBalances[i];
                uint256 reward = (profit * terms.basisPoints[i]) / 10000;

                if (terms.rewardTokens[i] == address(0)) {
                    (bool sent, ) = payable(msg.sender).call{value: reward}("");
                    if (!sent) {
                        revert FailedToSendReward();
                    }
                } else {
                    IERC20(terms.rewardTokens[i]).transfer(msg.sender, reward);
                }
            }
        }
    }
}

/// @title AccountSystem
/// @notice Manages player accounts for The Degen Casino. Can be deployed permissionlessly. Any number of these contracts
/// can be deployed to a chain. There can be multiple independent instances of this contract on a chain.
contract AccountSystem {
    mapping(address => DegenCasinoAccount) public accounts;
    string public constant systemVersion = AccountSystemVersion;
    string public constant accountVersion = AccountVersion;

    event AccountSystemCreated(
        string indexed systemVersion,
        string indexed accountVersion
    );
    event AccountCreated(
        address account,
        address indexed player,
        string indexed accountVersion
    );

    constructor() {
        emit AccountSystemCreated(systemVersion, accountVersion);
    }

    // Modeled off of computeAddress from OpenZeppelin's Create2 contract: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d6c7cee32191850d3635222826985f46996e64fd/contracts/utils/Create2.sol
    // For more details about this calculation, the Foundry docs are a good reference: https://book.getfoundry.sh/tutorials/create2-tutorial
    function calculateAccountAddress(
        address player
    ) public view returns (address result) {
        address deployer = address(this);
        // Hash of the initCode, which is the contract bytecode together with the encoded constructor arguments.
        bytes32 initCodeHash = keccak256(
            abi.encodePacked(
                type(DegenCasinoAccount).creationCode,
                abi.encode(player)
            )
        );

        assembly {
            let ptr := mload(0x40) // Get free memory pointer

            // |                   | ↓ ptr ...  ↓ ptr + 0x0B (start) ...  ↓ ptr + 0x20 ...  ↓ ptr + 0x40 ...   |
            // |-------------------|---------------------------------------------------------------------------|
            // | initCodeHash      |                                                        CCCCCCCCCCCCC...CC |
            // | salt              |                                      BBBBBBBBBBBBB...BB                   |
            // | deployer          | 000000...0000AAAAAAAAAAAAAAAAAAA...AA                                     |
            // | 0xFF              |            FF                                                             |
            // |-------------------|---------------------------------------------------------------------------|
            // | memory            | 000000...00FFAAAAAAAAAAAAAAAAAAA...AABBBBBBBBBBBBB...BBCCCCCCCCCCCCC...CC |
            // | keccak(start, 85) |            ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ |

            mstore(add(ptr, 0x40), initCodeHash)
            mstore(add(ptr, 0x20), player)
            mstore(ptr, deployer) // Right-aligned with 12 preceding garbage bytes
            let start := add(ptr, 0x0b) // The hashed data starts at the final garbage byte which we will set to 0xff
            mstore8(start, 0xff)
            result := keccak256(start, 85)
        }
    }

    /// @notice Creates an account for the given player assuming that one doesn't already exist.
    /// @param player The player for whom the account is being created.
    /// @return account The address of the created account.
    /// @return created A boolean indicating whether the account was created (true) or whether it already existed (false).
    function createAccount(address player) public returns (address, bool) {
        if (address(accounts[player]) != address(0)) {
            return (address(accounts[player]), false);
        }

        DegenCasinoAccount account = new DegenCasinoAccount{
            salt: bytes32(abi.encode(player))
        }(player);
        accounts[player] = account;
        emit AccountCreated(address(account), player, accountVersion);

        return (address(account), true);
    }
}
