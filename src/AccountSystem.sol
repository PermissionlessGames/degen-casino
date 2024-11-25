// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IERC20} from "../lib/openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "../lib/openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

string constant AccountSystemVersion = "1";
string constant AccountVersion = "1";

/// @title DegenCasinoAccount
/// @notice Player smart accounts for The Degen Casino.
contract DegenCasinoAccount {
    using SafeERC20 for IERC20;

    address public player;
    string public constant accountVersion = AccountVersion;

    error Unauthorized();

    constructor(address _player) {
        player = _player;
    }

    /// @notice Used to deposit native tokens to the DegenCasinoAccount.
    receive() external payable {}

    /// @notice Used to withdraw native tokens or ERC20 tokens from the DegenCasinoAccount.
    function withdraw(address tokenAddress, uint256 amount) public {
        if (msg.sender != player) {
            revert Unauthorized();
        }

        if (tokenAddress == address(0)) {
            // Native token case
            payable(player).call{value: amount}("");
        } else {
            // ERC20 token case
            IERC20(tokenAddress).transfer(player, amount);
        }
    }

    /// @notice Used to drain native tokens or ERC20 tokens from the DegenCasinoAccount.
    function drain(address tokenAddress) public {
        if (msg.sender != player) {
            revert Unauthorized();
        }

        uint256 amount;

        if (tokenAddress == address(0)) {
            amount = address(this).balance;
            // Native token case
            payable(player).call{value: amount}("");
        } else {
            IERC20 token = IERC20(tokenAddress);
            amount = token.balanceOf(address(this));
            // ERC20 token case
            token.transfer(player, amount);
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
