// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IMultipleCurrencyToken {
    /// @notice Struct defining the parameters for creating pricing data
    struct CreatePricingDataParams {
        address currency;
        uint256 price;
        bool is1155;
        uint256 tokenId;
    }

    /// @notice Get the token configuration at a specific index
    /// @param index The index of the token configuration
    /// @return token The token configuration
    function tokens(
        uint256 index
    ) external view returns (CreatePricingDataParams memory);

    /// @notice Encode a currency into a bytes array
    /// @param currency The address of the currency
    /// @param tokenId The token ID for ERC1155 tokens (ignored for ERC20)
    /// @param is1155 Boolean indicating if the token is an ERC1155
    /// @return currencyBytes The encoded currency
    function encodeCurrency(
        address currency,
        uint256 tokenId,
        bool is1155
    ) external pure returns (bytes memory);

    /// @notice Get the mint price for a currency
    /// @param currency The encoded currency
    /// @return price The mint price
    function getMintPrice(
        bytes memory currency
    ) external view returns (uint256);

    /// @notice Get the redeem price for a currency
    /// @param currency The encoded currency
    /// @return price The redeem price
    function getRedeemPrice(
        bytes memory currency
    ) external view returns (uint256);

    /// @notice Deposit a currency
    /// @param currencies The addresses of the currencies
    /// @param tokenIds The token IDs
    /// @param amounts The amounts to deposit
    /// @return mintAmount The amount minted
    function deposit(
        address[] memory currencies,
        uint256[] memory tokenIds,
        uint256[] memory amounts
    ) external payable returns (uint256 mintAmount);

    /// @notice Withdraw a currency
    /// @param currency The address of the currency
    /// @param tokenId The token ID for ERC1155 tokens (ignored for ERC20)
    /// @param amountIn The amount to withdraw
    /// @return amountOut The amount withdrawn
    function withdraw(
        address currency,
        uint256 tokenId,
        uint256 amountIn
    ) external returns (uint256 amountOut);

    /// @notice Estimate the deposit amount for a currency
    /// @param currencies The addresses of the currencies
    /// @param tokenIds The token IDs
    /// @param deposits The amounts to deposit
    /// @return amount The estimated deposit amount
    function estimateDepositAmount(
        address[] memory currencies,
        uint256[] memory tokenIds,
        uint256[] memory deposits
    ) external view returns (uint256 amount);

    /// @notice Get the token configurations
    /// @return currencies The addresses of the currencies
    /// @return tokenIds The token IDs
    /// @return is1155 The booleans indicating if the tokens are ERC1155
    function getTokens()
        external
        view
        returns (
            address[] memory currencies,
            uint256[] memory tokenIds,
            bool[] memory is1155
        );

    /// @notice Check if a currency exists
    /// @param currency The address of the currency
    /// @param tokenId The token ID for ERC1155 tokens (ignored for ERC20)
    /// @param is1155 Boolean indicating if the token is an ERC1155
    /// @return exists Boolean indicating if the currency exists
    function doesCurrencyExist(
        address currency,
        uint256 tokenId,
        bool is1155
    ) external view returns (bool);

    /// @notice Get the amount needed to mint a currency
    /// @param requestingAmount The amount of tokens to mint
    /// @param currency The address of the currency
    /// @param tokenId The token ID for ERC1155 tokens (ignored for ERC20)
    /// @param is1155 Boolean indicating if the token is an ERC1155
    /// @return amount The amount needed to mint
    function amountNeededToMint(
        uint256 requestingAmount,
        address currency,
        uint256 tokenId,
        bool is1155
    ) external view returns (uint256, bool);

    /// @notice Event emitted when new pricing data is added
    /// @param pricingData The new pricing data
    event NewPricingDataAdded(CreatePricingDataParams pricingData);
}
