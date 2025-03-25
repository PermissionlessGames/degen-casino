// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {CreatePricingDataParams, MCTTokens} from "../structs/MCTStructs.sol";

interface IMultipleCurrencyToken {
    /// @notice Get the token configuration at a specific index
    /// @param index The index of the token configuration
    /// @return token The token configuration
    function tokens(uint256 index) external view returns (CreatePricingDataParams memory);

    /// @notice Get the address of the native token
    /// @return address The address of the native token
    function INATIVE() external view returns (address);

    /// @notice Encode a currency into a bytes array
    /// @param currency The address of the currency
    /// @return currencyBytes The encoded currency
    function encodeCurrency(MCTTokens memory currency) external pure returns (bytes memory);

    /// @notice Get the mint price for a currency
    /// @param currency The encoded currency
    /// @return price The mint price
    function getMintPrice(bytes memory currency) external view returns (uint256);

    /// @notice Get the redeem price for a currency
    /// @param currency The encoded currency
    /// @return price The redeem price
    function getRedeemPrice(bytes memory currency) external view returns (uint256);

    /// @notice Deposit a currency
    /// @param currency The address of the currency
    /// @param amount The amount to deposit
    /// @return mintAmount The amount minted
    function deposit(MCTTokens memory currency, uint256 amount) external payable returns (uint256 mintAmount);

    /// @notice Withdraw a currency
    /// @param currency The address of the currency
    /// @param amountIn The amount to withdraw
    /// @return amountOut The amount withdrawn
    function withdraw(MCTTokens memory currency, uint256 amountIn) external returns (uint256 amountOut);

    /// @notice Estimate the deposit amount for a currency
    /// @param currency The address of the currency
    /// @param depositAmount The amount to deposit
    /// @return amount The estimated deposit amount
    function estimateDepositAmount(MCTTokens memory currency, uint256 depositAmount)
        external
        view
        returns (uint256 amount);

    /// @notice Get the token configurations
    /// @return currencies The addresses of the currencies
    /// @return tokenIds The token IDs
    /// @return is1155 The booleans indicating if the tokens are ERC1155
    function getTokens()
        external
        view
        returns (address[] memory currencies, uint256[] memory tokenIds, bool[] memory is1155);

    /// @notice Check if a currency exists
    /// @param currency The address of the currency
    /// @return exists Boolean indicating if the currency exists
    function doesCurrencyExist(MCTTokens memory currency) external view returns (bool);

    /// @notice Get the amount needed to mint a currency
    /// @param requestingAmount The amount of tokens to mint
    /// @param currency The address of the currency
    /// @return amount The amount needed to mint
    function amountNeededToMint(uint256 requestingAmount, MCTTokens memory currency)
        external
        view
        returns (uint256, bool);

    /// @notice Get the amount wanted to redeem a currency
    /// @param requestingAmount The amount of tokens to redeem
    /// @param currency The address of the currency
    /// @return amount The amount needed to redeem the requested amount
    /// @return exists Boolean indicating if the currency exists
    function amountWantedToRedeem(uint256 requestingAmount, MCTTokens memory currency)
        external
        view
        returns (uint256, bool);

    /// @notice Event emitted when new pricing data is added
    /// @param pricingData The new pricing data
    event NewPricingDataAdded(CreatePricingDataParams pricingData);
}
