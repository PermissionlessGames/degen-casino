// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IMultipleCurrencyToken} from "../interfaces/IMultipleCurrencyToken.sol";

contract MCTExchangeIntegration {
    IMultipleCurrencyToken public immutable mct;

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
}
