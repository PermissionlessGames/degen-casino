// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IMultipleCurrencyToken.sol";
import "../MultipleCurrencyToken.sol";

abstract contract MCTOwnership is Ownable, MultipleCurrencyToken {
    using PCPricing for PCPricing.PricingData;

    /// @notice Constructor for the MCTOwnership contract
    /// @param name_ The name of the token
    /// @param symbol_ The symbol of the token
    /// @param inative The address of the native currency
    /// @param adjustmentNumerator The numerator of the adjustment factor
    /// @param adjustmentDenominator The denominator of the adjustment factor
    /// @param currencies The currencies to add to the token
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

    /// @notice Adjust the pricing data for a currency
    /// @param _pricingDataIndex The index of the pricing data to adjust
    /// @param _newPrice The new price of the currency
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

    /// @notice Adjust the adjustment factor for the token
    /// @param _numerator The numerator of the adjustment factor
    /// @param _denominator The denominator of the adjustment factor
    function adjustAdjustmentFactor(
        uint256 _numerator,
        uint256 _denominator
    ) external onlyOwner {
        mintPricingData.setAdjustmentFactor(_numerator, _denominator);
        redeemPricingData.setAdjustmentFactor(_numerator, _denominator);
    }

    /// @notice Add new pricing data for a currency
    /// @param _createPricingDataParams The pricing data to add
    function addNewPricingData(
        IMultipleCurrencyToken.CreatePricingDataParams[]
            memory _createPricingDataParams
    ) external onlyOwner {
        require(
            _createPricingDataParams.length > 0,
            "Pricing data array cannot be empty"
        );
        for (uint256 i = 0; i < _createPricingDataParams.length; i++) {
            require(
                _createPricingDataParams[i].currency != address(0),
                "Currency cannot be 0 address"
            );
            require(
                _createPricingDataParams[i].price > 0,
                "Price must be greater than 0"
            );
            bytes memory currency = encodeCurrency(
                _createPricingDataParams[i].currency,
                _createPricingDataParams[i].tokenId,
                _createPricingDataParams[i].is1155
            );
            bool exists = mintPricingData.currencyExists(currency);
            require(!exists, "Currency already exists");

            addNewPricingData(_createPricingDataParams[i]);
        }
    }

    /// @notice Remove pricing data for a currency
    /// @param _pricingDataIndex The index of the pricing data to remove
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
