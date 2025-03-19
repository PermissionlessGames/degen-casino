// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IMultipleCurrencyToken} from "../interfaces/IMultipleCurrencyToken.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MCTExchangeIntegration {
    IMultipleCurrencyToken public immutable mct;

    using SafeERC20 for IERC20;

    struct MCTTokens {
        address currency;
        uint256 tokenId;
        bool is1155;
    }

    constructor(address _mct) {
        mct = IMultipleCurrencyToken(_mct);
    }

    /// @notice Estimates the amount of non-base currency needed to be deposited to get a certain amount of MCT
    /// @param baseToken The base token to be used for the deposit estimation
    /// @param nonBaseToken The non-base token to be used for the deposit and to receive the amount of MCT
    /// @param baseAmountRequired The amount of base token required
    /// @return The amount of non-base token needed to be deposited and a boolean indicating if the currency exists
    function estimatePaymentOfNonBaseCurrency(
        MCTTokens memory baseToken,
        MCTTokens memory nonBaseToken,
        uint256 baseAmountRequired
    ) public view virtual returns (uint256, uint256, bool) {
        address[] memory currencies = new address[](1);
        currencies[0] = baseToken.currency;
        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = baseToken.tokenId;
        uint256[] memory deposits = new uint256[](1);
        deposits[0] = baseAmountRequired;
        //Gets the estimated amount of MCT to be minted with baseAmountRequired and baseToken
        uint256 estimatedMCTAmountOut = mct.estimateDepositAmount(
            currencies,
            tokenIds,
            deposits
        );

        //Estiamte the amount of nonBaseToken needed to be deposited to get estimatedMCTAmountOut
        (uint256 nonBaseTokenAmount, bool exists) = mct.amountNeededToMint(
            estimatedMCTAmountOut,
            nonBaseToken.currency,
            nonBaseToken.tokenId,
            nonBaseToken.is1155
        );

        return (nonBaseTokenAmount, estimatedMCTAmountOut, exists);
    }

    function estimatePayoutForMCTUse(
        MCTTokens memory baseToken,
        uint256 baseAmountRequired
    ) public view returns (uint256) {
        address[] memory currencies = new address[](1);
        currencies[0] = baseToken.currency;
        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = baseToken.tokenId;
        uint256[] memory deposits = new uint256[](1);
        deposits[0] = baseAmountRequired;
        //Gets the estimated amount of MCT to be minted with baseAmountRequired and baseToken
        uint256 estimatedMCTAmountOut = mct.estimateDepositAmount(
            currencies,
            tokenIds,
            deposits
        );
        return estimatedMCTAmountOut;
    }

    function deposit1155(
        address currency,
        uint256 tokenId,
        uint256 amount,
        address user
    ) internal {
        IERC1155(currency).safeTransferFrom(
            user,
            address(this),
            tokenId,
            amount,
            ""
        );

        IERC1155(currency).setApprovalForAll(address(mct), true);
        address[] memory currencies = new address[](1);
        currencies[0] = currency;
        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = tokenId;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;
        mct.deposit(currencies, tokenIds, amounts);
        IERC1155(currency).setApprovalForAll(address(mct), false);
    }

    function deposit20(
        address currency,
        uint256 amount,
        address user
    ) internal {
        IERC20(currency).safeTransferFrom(user, address(this), amount);
        IERC20(currency).approve(address(mct), amount);
        address[] memory currencies = new address[](1);
        currencies[0] = currency;
        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 0;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;
        mct.deposit(currencies, tokenIds, amounts);
    }

    function useMCTToPay(
        MCTTokens memory baseToken,
        address from,
        address to,
        uint256 baseCost
    ) internal {
        uint256 amount = estimatePayoutForMCTUse(baseToken, baseCost);
        IERC20(address(mct)).safeTransferFrom(from, to, amount);
    }

    receive() external payable virtual {
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
