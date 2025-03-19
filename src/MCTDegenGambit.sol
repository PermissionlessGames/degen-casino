// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {DegenGambit} from "./DegenGambit.sol";
import {MCTExchangeIntegration} from "./token/ERC20/utils/MCTExchangeIntegration.sol";

contract MCTDegenGambit is DegenGambit, MCTExchangeIntegration {
    MCTTokens public tokenToPlay;
    address public immutable INATIVE;

    constructor(
        address _mct,
        uint256 blocksToAct,
        uint256 costToSpin,
        uint256 costToRespin,
        MCTTokens memory _tokenToPlay,
        address _INATIVE
    )
        MCTExchangeIntegration(_mct)
        DegenGambit(blocksToAct, costToSpin, costToRespin)
    {
        tokenToPlay.currency = _tokenToPlay.currency;
        tokenToPlay.tokenId = _tokenToPlay.tokenId;
        tokenToPlay.is1155 = _tokenToPlay.is1155;

        INATIVE = _INATIVE;
    }

    function spin(bool boost) public payable override {
        uint256 costToSpin = nativePayments(msg.value);
        _spin(msg.sender, msg.sender, boost, costToSpin);
    }

    function spinFor(
        address spinPlayer,
        address streakPlayer,
        bool boost
    ) public payable override {
        uint256 costToSpin = nativePayments(msg.value);
        _spin(spinPlayer, streakPlayer, boost, costToSpin);
    }

    function nativePayments(
        uint256 amount
    ) internal returns (uint256 costToSpin) {
        costToSpin = spinCost(msg.sender);
        address[] memory currencies = new address[](1);
        currencies[0] = INATIVE;
        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 0;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        if (INATIVE == tokenToPlay.currency) {
            mct.deposit{value: amounts[0]}(currencies, tokenIds, amounts);
            costToSpin = amounts[0];
        } else {
            MCTTokens memory nonBaseToken;
            nonBaseToken.currency = INATIVE;
            nonBaseToken.tokenId = 0;
            nonBaseToken.is1155 = false;
            (
                uint256 nonBaseTokenAmount,
                uint256 estimatedMCTAmountOut,
                bool exists
            ) = estimatePaymentOfNonBaseCurrency(
                    tokenToPlay,
                    nonBaseToken,
                    costToSpin
                );
            require(exists, "Token to play does not exist");
            require(nonBaseTokenAmount <= amounts[0], "Insufficient balance");
            uint256 balance = mct.balanceOf(address(this));
            mct.deposit{value: amounts[0]}(currencies, tokenIds, amounts);
            require(
                mct.balanceOf(address(this)) >= balance + estimatedMCTAmountOut,
                "Deposit failed"
            );
        }
    }
}
