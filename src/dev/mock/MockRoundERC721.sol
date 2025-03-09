// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.20;

import "../../token/erc721/RoundERC721.sol";
import {StakingPool, Position} from "./data.sol";
import {PositionMetadata} from "./RoundURI.sol";

contract MockRoundERC721 is RoundERC721 {
    address public uri;

    Position public position;
    StakingPool public pool;

    constructor(address _uri) RoundERC721("Mock Round ERC721", "MRE") {
        uri = _uri;

        position = Position({
            poolID: 0,
            amountOrTokenID: 0,
            stakeTimestamp: 0,
            unstakeInitiatedAt: 0
        });

        pool = StakingPool({
            administrator: address(0),
            tokenType: 0,
            tokenAddress: address(0),
            tokenID: 0,
            transferable: false,
            lockupSeconds: 0,
            cooldownSeconds: 0
        });
    }

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) public {
        _burn(tokenId);
    }

    function setRoundId(uint256 _roundId) public {
        roundId = _roundId;
        position.poolID = _roundId;
    }

    function setPosition(Position memory _position) public {
        position = _position;
    }

    function setPool(StakingPool memory _pool) public {
        pool = _pool;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        _requireOwned(tokenId);
        PositionMetadata roundURI = PositionMetadata(uri);
        return roundURI.metadata(tokenId, position, pool);
    }
}
