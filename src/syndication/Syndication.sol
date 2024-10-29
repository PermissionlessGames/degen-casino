// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../docs/interfaces/IDegenGambit.sol";
import {ReentrancyGuard} from "../lib/openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./utils/Reciever.sol";

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
    function spinFor() external payable {
        IDegenGambit(degensGambit).spinFor(msg.sender, msg.sender){
            value: msg.value
        };
    }

    function acceptFor() external {
        IDegenGambit(degensGambit).acceptFor(msg.sender);
    }
}
