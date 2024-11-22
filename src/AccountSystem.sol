// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

string constant AccountSystemVersion = "1";
string constant AccountVersion = "1";

contract Account {
    address public player;
    string public constant accountVersion = AccountVersion;

    constructor(address _player) {
        player = _player;
    }
}

contract AccountSystem {
    mapping(address => Account) public accounts;
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
            abi.encodePacked(type(Account).creationCode, abi.encode(player))
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

    function createAccount(address player) public {
        require(
            address(accounts[player]) == address(0),
            "CasinoAcountSystem.createAccount: account already exists"
        );
        Account account = new Account{salt: bytes32(abi.encode(player))}(
            player
        );
        accounts[player] = account;
        emit AccountCreated(address(account), player, accountVersion);
    }
}
