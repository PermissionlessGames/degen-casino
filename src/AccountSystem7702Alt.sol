// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {SignatureChecker} from "../lib/openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import {IERC20} from "../lib/openzeppelin/contracts/token/ERC20/IERC20.sol";

struct ExecutionTerms {
    address feeToken;
    uint256 feeValue;
}

/// @notice A game action to be executed
/// @param target The target contract to execute the action on
/// @param data The encoded function call data to send to the game contract
/// @param value The amount of native tokens to send with the call
/// @param nonce nonce to prevent replay attacks
struct Action {
    address target;
    bytes data;
    uint256 value;
    uint256 nonceOrExpiration;
    ExecutionTerms[] executionTerms;
}

contract AccountSystem7702Alt {
    uint256 public nonce;
    bool public locked;

    error InvalidSignature();
    error ActionExpired();
    error InvalidNonce();
    error InvalidBasisPoints();
    error ReentrancyGuard();

    event ActionExecuted(Action action, address executor);
    event NonceUpdated(uint256 newNonce);

    /// ================================ MODIFIERS ================================
 

    modifier nonReentrant() {
        require(!locked, ReentrancyGuard());
        locked = true;
        _;
        locked = false;
    }

    constructor() {
        nonce = type(uint64).max; // max value block.timestamp can be
    }

    /// ================================ PUBLIC FUNCTIONS ================================
    /// @notice Execute a batch of actions
    /// @param actions The actions to execute
    /// @param signatures The signatures of the actions
    function execute(Action[] memory actions, bytes[] memory signatures) public nonReentrant {
        for (uint256 i = 0; i < actions.length; i++) {
            uint256[] memory initialBalances = batchGetBalances(actions[i].executionTerms);
            _execute(actions[i], signatures[i]);
            _processExecutorTerms(actions[i].executionTerms, initialBalances);
        }
    }

  

    /// ================================ INTERNAL FUNCTIONS ================================
    /// @notice Process the executor terms
    /// @param executionTerms The execution terms
    /// @param initialBalances The initial balances of the tokens
    function _processExecutorTerms(ExecutionTerms[] memory executionTerms, uint256[] memory initialBalances) internal {
        for (uint256 i = 0; i < executionTerms.length; i++) {
            if (executionTerms[i].feeValue == 0) return;
            if (executionTerms[i].feeValue < type(uint16).max) {
                _processExecutorTermsWithBasisPoints(executionTerms[i], initialBalances[i]);
            } else {
                _processExecutorTermsWithAmounts(executionTerms[i]);
            }
        }
    }

    /// @notice Execute an action
    /// @param action The action to execute
    /// @param signature The signature of the action
    function _execute(Action memory action, bytes memory signature) internal {
        bytes32 actionHash = hashAction(action);

        // Should send a nonce or an expiration
        if (action.nonceOrExpiration > type(uint64).max) {
            require(action.nonceOrExpiration == nonce + 1, InvalidNonce());
        } else {
            require(action.nonceOrExpiration >= block.timestamp, ActionExpired());
        }

        bool isValid = SignatureChecker.isValidSignatureNow(
            msg.sender,
            actionHash,
            signature
        );

        require(isValid, InvalidSignature());

        nonce++;
        emit ActionExecuted(action, msg.sender);
        emit NonceUpdated(nonce);
    }

    /// @notice Process the executor terms with basis points
    /// @param executionTerms The execution terms
    /// @param initialBalance The initial balance of the token
    function _processExecutorTermsWithBasisPoints(ExecutionTerms memory executionTerms, uint256 initialBalance) internal {
        uint256 finalBalance = getBalance(executionTerms.feeToken);
        uint256 diff = finalBalance - initialBalance;
            if (diff == 0) return;

        require(executionTerms.feeValue < type(uint16).max, InvalidBasisPoints());
        uint256 executorAmount = (diff * executionTerms.feeValue) / 10000;
        _transfer(executionTerms.feeToken, executorAmount);
    }

    /// @notice Process the executor terms with amounts
    /// @param executionTerms The execution terms
    function _processExecutorTermsWithAmounts(ExecutionTerms memory executionTerms) internal {
        _transfer(executionTerms.feeToken, executionTerms.feeValue);
    }

    /// @notice Transfer a token to the executor
    /// @param token The token to transfer
    /// @param amount The amount to transfer
    function _transfer(address token, uint256 amount) internal {
        if (token == address(0)) {
            payable(msg.sender).transfer(amount);
        } else {
            IERC20(token).transfer(msg.sender, amount);
        }
    }
    /// ================================ GETTERS ================================

    /// @notice Get the balance of a token
    /// @param token The token to get the balance of
    /// @return The balance of the token
    function getBalance(address token) public view returns (uint256) {
        if (token == address(0)) {
            return address(this).balance;
        } else {
            return IERC20(token).balanceOf(address(this));
        }
    }

    /// @notice Computes the EIP712 hash of a game action
    /// @param action The action to hash
    /// @return The EIP712 hash of the action
    function hashAction(Action memory action) public pure returns (bytes32) {
        return  keccak256(
                    abi.encode(
                        keccak256(
                            "Action(address target,bytes data,uint256 value,uint256 nonceOrExpiration,ExecutionTerms[] executionTerms)"
                        ),
                        action.target,
                        keccak256(action.data),
                        action.value,
                        action.nonceOrExpiration,
                        action.executionTerms
                    )
                );
    }

    /// @notice Batch get the balances of multiple tokens
    /// @param executionTerms The execution terms
    /// @return balances The balances of the tokens
    function batchGetBalances(ExecutionTerms[] memory executionTerms) public view returns (uint256[] memory balances) {
        for (uint256 i = 0; i < executionTerms.length; i++) {
            balances[i] = getBalance(executionTerms[i].feeToken);
        }
    }
}