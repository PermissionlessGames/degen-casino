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
        mct.deposit{value: msg.value}(currencies, tokenIds, amounts);
    }
}
