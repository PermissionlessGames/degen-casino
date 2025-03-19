// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {DegenGambit} from "./DegenGambit.sol";
import {MCTExchangeIntegration} from "./token/ERC20/utils/MCTExchangeIntegration.sol";

contract MCTDegenGambit is DegenGambit, MCTExchangeIntegration {
    MCTTokens public baseToken;

    constructor(
        address _mct,
        uint256 blocksToAct,
        uint256 costToSpin,
        uint256 costToRespin,
        MCTTokens memory _baseToken
    )
        MCTExchangeIntegration(_mct)
        DegenGambit(blocksToAct, costToSpin, costToRespin)
    {
        baseToken.currency = _baseToken.currency;
        baseToken.tokenId = _baseToken.tokenId;
        baseToken.is1155 = _baseToken.is1155;
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

    function spinForMCTTokens(
        MCTTokens memory tokenToPlay,
        address spinPlayer,
        address streakPlayer,
        bool boost
    ) public payable {
        uint256 costToSpin;
        if (tokenToPlay.currency == mct.INATIVE()) {
            costToSpin = nativePayments(msg.value);
        } else if (tokenToPlay.currency == address(mct)) {
            costToSpin = spinCost(spinPlayer);
            useMCTToPay(baseToken, msg.sender, address(this), costToSpin);
        } else {
            costToSpin = paymentOfNonNativeCurrency(
                tokenToPlay,
                msg.sender,
                spinPlayer
            );
        }

        _spin(spinPlayer, streakPlayer, boost, costToSpin);
    }

    function nativePayments(
        uint256 amount
    ) internal returns (uint256 costToSpin) {
        costToSpin = spinCost(msg.sender);
        address[] memory currencies = new address[](1);
        currencies[0] = mct.INATIVE();
        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 0;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        if (mct.INATIVE() == baseToken.currency) {
            mct.deposit{value: amounts[0]}(currencies, tokenIds, amounts);
            costToSpin = amounts[0];
        } else {
            MCTTokens memory nonBaseToken;
            nonBaseToken.currency = mct.INATIVE();
            nonBaseToken.tokenId = 0;
            nonBaseToken.is1155 = false;
            (
                uint256 nonBaseTokenAmount,
                uint256 estimatedMCTAmountOut,
                bool exists
            ) = estimatePaymentOfNonBaseCurrency(
                    baseToken,
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

    function paymentOfNonNativeCurrency(
        MCTTokens memory tokenToPlay,
        address caller,
        address player
    ) internal returns (uint256 costToSpin) {
        costToSpin = spinCost(player);
        uint256 amount;
        uint256 estimatedMCTAmountOut = 0;

        if (tokenToPlay.currency == baseToken.currency) {
            //not set estimatedMCTAmountOut because it's not needed for base token
            amount = costToSpin;
        } else {
            (
                uint256 amountInRequired,
                uint256 estimateMCTAmountOut,
                bool exists
            ) = estimatePaymentOfNonBaseCurrency(
                    baseToken,
                    tokenToPlay,
                    costToSpin
                );
            amount = amountInRequired;
            estimatedMCTAmountOut = estimateMCTAmountOut;
            require(amount > 0, "Amount in required is not greater than 0");
            require(exists, "Token to play does not exist");
            require(
                estimatedMCTAmountOut > 0,
                "Estimated MCT amount out is not greater than 0"
            );
        }
        uint256 balance = mct.balanceOf(address(this));
        if (tokenToPlay.is1155) {
            deposit1155(
                tokenToPlay.currency,
                tokenToPlay.tokenId,
                amount,
                caller
            );
        } else {
            deposit20(tokenToPlay.currency, amount, caller);
        }
        require(
            mct.balanceOf(address(this)) >= balance + estimatedMCTAmountOut,
            "Deposit failed"
        );
    }

    receive() external payable override(DegenGambit, MCTExchangeIntegration) {
        address[] memory currencies = new address[](1);
        currencies[0] = mct.INATIVE();
        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 0;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = msg.value;
        mct.deposit{value: amounts[0]}(currencies, tokenIds, amounts);
    }
}
