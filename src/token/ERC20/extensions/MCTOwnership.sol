// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IMultipleCurrencyToken.sol";
import "../MultipleCurrencyToken.sol";

abstract contract MCTOwnership is Ownable, MultipleCurrencyToken {
    using PCPricing for PCPricing.PricingData;

    constructor(
        string memory name_,
        string memory symbol_,
        address inative,
        uint256 adjustmentNumerator,
        uint256 adjustmentDenominator,
        CreatePricingDataParams[] memory currencies
    )
        MultipleCurrencyToken(
            name_,
            symbol_,
            inative,
            adjustmentNumerator,
            adjustmentDenominator,
            currencies
        )
        Ownable(msg.sender)
    {}

    function adjustPricingData(
        uint256 _pricingDataIndex,
        uint256 _newPrice
    ) external onlyOwner {
        CreatePricingDataParams memory tokenData = tokens(_pricingDataIndex);
        bytes memory currency = encodeCurrency(
            tokenData.currency,
            tokenData.tokenId,
            tokenData.is1155
        );
        mintPricingData.setCurrencyPrice(currency, _newPrice);
        redeemPricingData.setCurrencyPrice(currency, _newPrice);
    }

    function adjustAdjustmentFactor(
        uint256 _numerator,
        uint256 _denominator
    ) external onlyOwner {
        mintPricingData.setAdjustmentFactor(_numerator, _denominator);
        redeemPricingData.setAdjustmentFactor(_numerator, _denominator);
    }

    function addNewPricingData(
        IMultipleCurrencyToken.CreatePricingDataParams[]
            memory _createPricingDataParams
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
        CreatePricingDataParams memory tokenData = tokens(_pricingDataIndex);
        bytes memory currency = encodeCurrency(
            tokenData.currency,
            tokenData.tokenId,
            tokenData.is1155
        );
        mintPricingData.removeCurrency(currency);
        redeemPricingData.removeCurrency(currency);
    }
}
