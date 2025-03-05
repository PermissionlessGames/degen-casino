// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../MultipleCurrencyToken.sol";

abstract contract MCTOwnership is Ownable, MultipleCurrencyToken {
    using PCPricing for PCPricing.PricingData;

    function adjustPricingData(
        uint256 _pricingDataIndex,
        uint256 _newPrice
    ) external onlyOwner {
        bytes memory currency = encodeCurrency(
            tokens[_pricingDataIndex].currency,
            tokens[_pricingDataIndex].tokenId,
            tokens[_pricingDataIndex].is1155
        );
        mintPricingData.setCurrencyPrice(currency, _newPrice);
        redeemPricingData.setCurrencyPrice(currency, _newPrice);
        emit PricingDataAdjusted(
            tokens[_pricingDataIndex].currency,
            tokens[_pricingDataIndex].tokenId,
            tokens[_pricingDataIndex].is1155,
            _newPrice
        );
    }

    function adjustAdjustmentFactor(
        uint256 _numerator,
        uint256 _denominator
    ) external onlyOwner {
        mintPricingData.setAdjustmentFactor(_numerator, _denominator);
        redeemPricingData.setAdjustmentFactor(_numerator, _denominator);
        emit AdjustmentFactorAdjusted(_numerator, _denominator);
    }

    function addNewPricingData(
        CreatePricingDataParams[] memory _createPricingDataParams
    ) external onlyOwner {
        for (uint256 i = 0; i < _createPricingDataParams.length; i++) {
            require(
                _createPricingDataParams[i].currency != address(0),
                "Currency cannot be 0 address"
            );
            require(
                _createPricingDataParams[i].price > 0,
                "Price must be greater than 0"
            );
            require(
                !mintPricingData.currencyExists(
                    encodeCurrency(
                        _createPricingDataParams[i].currency,
                        _createPricingDataParams[i].tokenId,
                        _createPricingDataParams[i].is1155
                    )
                ),
                "Currency already exists"
            );

            addNewPricingData(_createPricingDataParams[i]);
        }
    }

    function removePricingData(uint256 _pricingDataIndex) external onlyOwner {
        bytes memory currency = encodeCurrency(
            tokens[_pricingDataIndex].currency,
            tokens[_pricingDataIndex].tokenId,
            tokens[_pricingDataIndex].is1155
        );
        mintPricingData.removeCurrency(currency);
        redeemPricingData.removeCurrency(currency);
    }
}
