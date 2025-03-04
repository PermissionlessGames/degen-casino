// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../PCPToken.sol";

abstract contract PCPTOwnership is Ownable, PCPToken {
    function setPCPToken(address _pcToken) external onlyOwner {
        pcToken = PCPToken(_pcToken);
    }

    event PricingDataRemoved(
        address indexed currency,
        uint256 indexed tokenId,
        bool is1155
    );

    event PricingDataAdjusted(
        address indexed currency,
        uint256 indexed tokenId,
        bool is1155,
        uint256 newPrice
    );

    event AdjustmentFactorAdjusted(uint256 numerator, uint256 denominator);

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

        emit PricingDataRemoved(
            tokens[_pricingDataIndex].currency,
            tokens[_pricingDataIndex].tokenId,
            tokens[_pricingDataIndex].is1155
        );
    }

    function adjustPricingData(
        uint256 _pricingDataIndex,
        uint256 _newPrice
    ) external onlyOwner {
        bytes memory currency = encodeCurrency(
            tokens[_pricingDataIndex].currency,
            tokens[_pricingDataIndex].tokenId,
            tokens[_pricingDataIndex].is1155
        );
        mintPricingData.adjustPrice(currency, _newPrice);
        redeemPricingData.adjustPrice(currency, _newPrice);
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
        mintPricingData.adjustAdjustmentFactor(_numerator, _denominator);
        redeemPricingData.adjustAdjustmentFactor(_numerator, _denominator);
        emit AdjustmentFactorAdjusted(_numerator, _denominator);
    }
}
