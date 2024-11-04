// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IERC20} from "../../../lib/openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Receiver {
    event NewOwner(address _owner);

    address public owner;
    address immutable launcher;
    address immutable _erc20;

    modifier onlyOwner() {
        require(
            owner == msg.sender || msg.sender == launcher,
            "Only Owner can call"
        );
        _;
    }

    function setOwner(address newOwner) external onlyOwner {
        owner = newOwner;
        emit NewOwner(newOwner);
    }

    constructor(address erc20, address _owner) {
        owner = _owner;
        launcher = msg.sender;
        _erc20 = erc20;
    }

    /// Allows the contract to receive the native token on its blockchain.
    receive() external payable {}

    function handleRewards(
        address prizeReceiver,
        address otherReceiver
    )
        external
        virtual
        onlyOwner
        returns (uint256 amountPrize, uint256 amountOther)
    {
        amountPrize = _nativeTransfer(prizeReceiver);
        amountOther = _erc20Transfer(otherReceiver);
    }

    function _nativeTransfer(address to) internal returns (uint256 amount) {
        amount = address(this).balance;
        payable(to).transfer(amount);
    }

    function _erc20Transfer(address to) internal returns (uint256 amount) {
        amount = IERC20(_erc20).balanceOf(address(this));
        if (amount > 0) {
            IERC20(_erc20).transfer(to, amount);
        }
    }
}
