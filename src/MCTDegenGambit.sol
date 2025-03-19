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

    
    function prizes()
        external
        view
        override
        returns (uint256[] memory prizesAmount, uint256[] memory typeOfPrizes)
    {
        uint256[] memory prizesAmount = new uint256[](7);
        uint256[] memory typeOfPrizes = new uint256[](7);
        prizesAmount = new uint256[](7);
        typeOfPrizes = new uint256[](7);

        uint256 adjustedCostToSpin = calculateAdjustedCostToSpin();

        prizesAmount[0] = MajorGambitPrize;
        typeOfPrizes[0] = 20;
        prizesAmount[1] = MinorGambitPrize;
        typeOfPrizes[1] = 20; //Slot boost payout
        prizesAmount[2] = 50 * adjustedCostToSpin <
            mct.balanceIf(address(this)).balance >> 6
            ? 50 * adjustedCostToSpin
            : mct.balanceIf(address(this)).balance >> 6;
        typeOfPrize[2] = 1;
        prizesAmount[3] = 100 * adjustedCostToSpin <
            mct.balanceIf(address(this)).balance >> 4
            ? 100 * adjustedCostToSpin
            : mct.balanceIf(address(this)).balance >> 4;
        typeOfPrize[3] = 1; //MCT payout
        prizesAmount[4] = mct.balanceIf(address(this)) >> 3;
        typeOfPrize[4] = 1;
        prizesAmount[5] = mct.balanceIf(address(this)) >> 3;
        typeOfPrize[5] = 1;
        prizesAmount[6] = mct.balanceIf(address(this)) >> 1;
        typeOfPrize[6] = 1;
    }

    function payout(
        uint256 left,
        uint256 center,
        uint256 right
    )
        public
        view
        virtual
        returns (uint256 result, uint256 typeOfPrize, uint256 prizeIndex)
    {
        if (left >= 19 || center >= 19 || right >= 19) {
            revert OutcomeOutOfBounds();
        }
        uint256 adjustedCostToSpin = calculateAdjustedCostToSpin();
        //Default 0 for everything else
        result = 0;
        if (left != 0 && right != 0 && center != 0) {
            if (left == right && left != center && left <= 15 && center <= 15) {
                // Minor symbol pair on outside reels with different minor symbol in the center. Case 1
                result = MinorGambitPrize;
                typeOfPrize = 20;
                prizeIndex = 1;
            } else if (left == right && left == center && left <= 15) {
                // 3 of a kind with a minor symbol. Case 2
                result = 50 * adjustedCostToSpin;
                if (result > mct.balanceOf(address(this)) >> 6) {
                    result = mct.balanceOf(address(this)) >> 6;
                }
                typeOfPrize = 1;
                prizeIndex = 2;
            } else if (left == right && center >= 16 && left <= 15) {
                // Minor symbol pair on outside reels with major symbol in the center. Case 3
                result = 100 * adjustedCostToSpin;
                if (result > mct.balanceOf(address(this)) >> 4) {
                    result = mct.balanceOf(address(this)) >> 4;
                }
                typeOfPrize = 1;
                prizeIndex = 3;
            } else if (
                left != right &&
                center != left &&
                center != right &&
                left >= 16 &&
                center >= 16 &&
                right >= 16
            ) {
                // Three distinct major symbols. Case 5
                result = mct.balanceOf(address(this)) >> 3;
                typeOfPrize = 1;
                prizeIndex = 5;
            } else if (
                left == right && left != center && left >= 16 && center >= 16
            ) {
                // Major symbol pair on the outside with a different major symbol in the center. Case 4
                result = mct.balanceOf(address(this)) >> 3;
                typeOfPrize = 1;
                prizeIndex = 4;
            } else if (left == center && center == right && left >= 16) {
                // 3 of a kind with a major symbol. Jackpot! Case 6
                result = mct.balanceOf(address(this)) >> 1;
                typeOfPrize = 1;
                prizeIndex = 6;
            } else if (left > 15 || center > 15 || right > 15) {
                // If at least 1 Major symbol is present
                result = MajorGambitPrize;
                typeOfPrize = 20;
                prizeIndex = 0;
            }
        }
    }

    function calculateAdjustedCostToSpin() public view returns (uint256) {
        address[] memory currencies = new address[](1);
        currencies[0] = baseToken.currency;
        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = baseToken.tokenId;
        uint256[] memory deposits = new uint256[](1);
        deposits[0] = CostToSpin;
        return mct.estimateDepositAmount(currencies, tokenIds, deposits);
    }

    function _transferPrize(
        uint256 prize,
        address player,
        uint256 typeOfPrize
    ) internal override {
        if (typeOfPrize == 1) {
            mct.transfer(player, prize);
        } else if (typeOfPrize == 20) {
            _mint(player, prize);
        } else {
            revert "Invalid prize type";
        }
    }
    
    function version() external pure virtual returns (string memory) {
        return "1.20";
    }
}
