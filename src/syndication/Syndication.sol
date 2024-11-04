// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// import "../../docs/interfaces/IDegenGambit.sol";
import {ReentrancyGuard} from "../../lib/openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./utils/Receiver.sol";

//TODO: Everything
//OOP: Approach allow for different rake methods or access control
// -ERC20/ERC721/ERC1155 access control i.e. must hold/stake system
// -Rake % of play/prize to developer
contract Syndication is ReentrancyGuard {
    address public immutable degensGambit;

    constructor(address degenGambitGame) {
        degensGambit = degenGambitGame;
    }

    //Default example of
    function spinFor(bool boost) external payable {
        //IDegenGambit(degensGambit).spinFor{value: msg.value}(
        //  msg.sender,
        // msg.sender,
        // boost
        //);
    }

    function acceptFor() external {
        //IDegenGambit(degensGambit).acceptFor(msg.sender);
    }
}
