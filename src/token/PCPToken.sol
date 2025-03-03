// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../libraries/PCPricing.sol";

contract PCPricedToken is ERC20, ReentrancyGuard, ERC1155Holder {
    using SafeERC20 for IERC20;
    using PCPricing for PCPricing.PricingData;

    PCPricing.PricingData private mintPricingData; // Pricing data for minting
    PCPricing.PricingData private redeemPricingData; // Pricing data for redeeming
    address public immutable INATIVE; // Used to identify native deposits
    mapping(address => bool) public tokenIs1155;
    CreatePricingDataParams[] public tokens;

    struct CreatePricingDataParams {
        // Used to create pricing data for tokens
        address currency;
        uint256 price;
        bool is1155;
        uint256 tokenId;
    }

    /// @notice Constructor for PCPricedToken
    /// @param name_ The name of the token
    /// @param symbol_ The symbol of the token
    /// @param inative The address used to identify native deposits (e.g. ETH)
    /// @param adjustmentNumerator The numerator for price adjustment calculations
    /// @param adjustmentDenominator The denominator for price adjustment calculations
    /// @param currencies Array of CreatePricingDataParams containing initial currency/token configurations
    /// @dev The first currency in the array is set as the anchor currency with its price as the anchor price
    /// @dev All other currencies are initialized with their specified prices relative to the anchor
    /// @dev Both mint and redeem pricing data are initialized with the same adjustment factors

    constructor(
        string memory name_,
        string memory symbol_,
        address inative,
        uint256 adjustmentNumerator,
        uint256 adjustmentDenominator,
        CreatePricingDataParams[] memory currencies
    ) ERC20(name_, symbol_) {
        INATIVE = inative;

        uint256 anchorPrice = currencies[0].price;
        bytes memory anchorCurrencyBytes = currencies[0].is1155
            ? abi.encode(currencies[0].currency, currencies[0].tokenId)
            : abi.encode(currencies[0].currency);
        redeemPricingData.setAnchorCurrency(anchorCurrencyBytes, anchorPrice);
        mintPricingData.setAdjustmentFactor(
            adjustmentNumerator,
            adjustmentDenominator
        );
        redeemPricingData.setAdjustmentFactor(
            adjustmentNumerator,
            adjustmentDenominator
        );
        tokens.push(currencies[0]);
        for (uint256 i = 1; i < currencies.length; i++) {
            bytes memory currency;
            if (currencies[i].is1155) {
                currency = abi.encode(
                    currencies[i].currency,
                    currencies[i].tokenId
                );
            } else {
                currency = abi.encode(currencies[i].currency);
            }
            mintPricingData.setCurrencyPrice(currency, currencies[i].price);
            redeemPricingData.setCurrencyPrice(currency, currencies[i].price);
            tokenIs1155[currencies[i].currency] = currencies[i].is1155;
            tokens.push(currencies[i]);
        }
    }

    /// @notice Deposit tokens to mint PCPTokens
    /// @param currencies Array of token addresses to deposit (use INATIVE for native currency)
    /// @param tokenIds Array of token IDs for ERC1155 tokens (ignored for ERC20)
    /// @param amounts Array of amounts to deposit for each token
    /// @return mintAmount The amount of PCPTokens minted
    /// @dev For each token:
    /// @dev - If native currency (ETH), amount must match msg.value
    /// @dev - If ERC1155, transfers specified tokenId and amount
    /// @dev - If ERC20, transfers specified amount
    /// @dev Mints PCPTokens based on deposit value calculated from pricing data
    function deposit(
        address[] memory currencies,
        uint256[] memory tokenIds,
        uint256[] memory amounts
    ) external payable nonReentrant returns (uint256 mintAmount) {
        require(
            currencies.length == amounts.length &&
                tokenIds.length == amounts.length,
            "Mismatched array lengths"
        );

        mintAmount = estimateDepositAmount(currencies, tokenIds, amounts);
        depositTokens(currencies, tokenIds, amounts, msg.sender, msg.value);
        require(mintAmount > 0, "Mint amount too small");

        _mint(msg.sender, mintAmount);
    }

    /// @notice Internal function to handle token deposits
    /// @param currencies Array of token addresses to deposit (use INATIVE for native currency)
    /// @param tokenIds Array of token IDs for ERC1155 tokens (ignored for ERC20)
    /// @param amounts Array of amounts to deposit for each token
    /// @param caller Address initiating the deposit
    /// @param msgValue Native currency value sent with transaction
    function depositTokens(
        address[] memory currencies,
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        address caller,
        uint256 msgValue
    ) internal {
        for (uint256 i; i < currencies.length; i++) {
            require(amounts[i] > 0, "Amount must be greater than 0");
            if (currencies[i] != INATIVE) {
                if (tokenIs1155[currencies[i]]) {
                    IERC1155(currencies[i]).safeTransferFrom(
                        caller,
                        address(this),
                        tokenIds[i],
                        amounts[i],
                        ""
                    );
                } else {
                    IERC20(currencies[i]).safeTransferFrom(
                        caller,
                        address(this),
                        amounts[i]
                    );
                }
            } else {
                require(
                    amounts[i] == msgValue,
                    "Native value does not match amount passed in"
                );
                //Incase of multiple cases of Native being passed in.
                msgValue -= amounts[i];
            }

            if (currencies[i] != tokens[0].currency) {
                mintPricingData.adjustCurrencyPrice(
                    tokens[i].is1155
                        ? abi.encode(tokens[i].currency, tokenIds[i])
                        : abi.encode(tokens[i].currency),
                    true
                );
            } else {
                mintPricingData.adjustAllNonAnchorPrices(false);
            }
        }
    }

    /// @notice Estimate the amount of tokens to be minted based on currency price
    /// @param currencies Array of currency addresses to deposit
    /// @param tokenIds Array of token IDs for ERC1155 tokens (ignored for ERC20)
    /// @param deposits Array of amounts to deposit for each currency
    /// @return amount The estimated amount of tokens to be minted
    function estimateDepositAmount(
        address[] memory currencies,
        uint256[] memory tokenIds,
        uint256[] memory deposits
    ) public view returns (uint256 amount) {
        for (uint256 i = 0; i < currencies.length; i++) {
            bytes memory currency = tokens[i].is1155
                ? abi.encode(tokens[i].currency, tokenIds[i])
                : abi.encode(tokens[i].currency);
            uint256 ratio = mintPricingData.getCurrencyPrice(currency);
            ratio = ratio > redeemPricingData.getCurrencyPrice(currency)
                ? ratio
                : redeemPricingData.getCurrencyPrice(currency);
            uint256 price = (deposits[i] * 1e18) / ratio;
            amount += price;
        }
    }

    /// @notice Withdraw tokens from the contract
    /// @param currency The address of the currency to withdraw
    /// @param tokenId The token ID for ERC1155 tokens (ignored for ERC20)
    /// @param amountIn The amount of PCP tokens to burn
    /// @return amountOut The amount of tokens withdrawn
    /// @dev Burns PCP tokens and returns the underlying assets
    /// @dev If currency is not the anchor currency, its price is decreased
    /// @dev If currency is the anchor currency, all other currency prices are increased
    /// @dev For ERC1155 tokens, uses safeTransferFrom
    /// @dev For ERC20 tokens, uses safeTransfer
    /// @dev For native, uses call
    function withdraw(
        address currency,
        uint256 tokenId,
        uint256 amountIn
    ) external nonReentrant returns (uint256 amountOut) {
        require(amountIn > 0, "Invalid withdraw amount");
        require(balanceOf(msg.sender) >= amountIn, "Insufficient balance");
        amountOut = estimateWithdrawAmount(currency, tokenId, amountIn);
        require(amountOut > 0, "Insufficient balance");
        if (currency != tokens[0].currency) {
            redeemPricingData.adjustCurrencyPrice(
                tokenIs1155[currency]
                    ? abi.encode(currency, tokenId)
                    : abi.encode(currency),
                false
            );
        } else {
            redeemPricingData.adjustAllNonAnchorPrices(true);
        }

        _burn(msg.sender, amountIn);

        if (currency != INATIVE) {
            if (tokenIs1155[currency]) {
                IERC1155(currency).safeTransferFrom(
                    address(this),
                    msg.sender,
                    tokenId,
                    amountOut,
                    ""
                );
            } else {
                IERC20(currency).safeTransfer(msg.sender, amountOut);
            }
        } else {
            address payable _to = payable(msg.sender);
            (bool success, ) = _to.call{value: amountOut}("");
            require(success, "Transfer failed");
        }
    }

    /// @notice Estimate the amount of tokens to be withdrawn based on currency price
    /// @param currency The address of the currency to withdraw
    /// @param tokenId The token ID for ERC1155 tokens (ignored for ERC20)
    /// @param amountIn The amount of PCP tokens to burn
    /// @return amountOut The estimated amount of tokens to be withdrawn
    function estimateWithdrawAmount(
        address currency,
        uint256 tokenId,
        uint256 amountIn
    ) public view returns (uint256 amountOut) {
        bytes memory _currency = tokenIs1155[currency]
            ? abi.encode(currency, tokenId)
            : abi.encode(currency);
        uint256 price = redeemPricingData.getCurrencyPrice(_currency);
        price = price < mintPricingData.getCurrencyPrice(_currency)
            ? price
            : mintPricingData.getCurrencyPrice(_currency);
        amountOut = (amountIn * price) / 1e18;
        if (tokenIs1155[currency]) {
            amountOut = amountOut >
                IERC1155(currency).balanceOf(address(this), tokenId)
                ? IERC1155(currency).balanceOf(address(this), tokenId)
                : amountOut;
        } else {
            amountOut = amountOut > IERC20(currency).balanceOf(address(this))
                ? IERC20(currency).balanceOf(address(this))
                : amountOut;
        }
    }

    /// @notice Get the list of tokens and their properties
    /// @return currencies Array of token addresses
    /// @return tokenIds Array of token IDs
    /// @return is1155 Array of booleans indicating if the token is an ERC1155
    function getTokens()
        external
        view
        returns (address[] memory, uint256[] memory, bool[] memory)
    {
        address[] memory currencies = new address[](tokens.length);
        uint256[] memory tokenIds = new uint256[](tokens.length);
        bool[] memory is1155 = new bool[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            currencies[i] = tokens[i].currency;
            tokenIds[i] = tokens[i].tokenId;
            is1155[i] = tokens[i].is1155;
        }
        return (currencies, tokenIds, is1155);
    }

    /// @notice Get the price ratios for minting and redeeming
    /// @param treasuryTokens Array of token addresses to get price ratios for
    /// @param tokenIds Array of token IDs for ERC1155 tokens (ignored for ERC20)
    /// @return mintPriceRatios Array of mint price ratios
    /// @return redeemPriceRatios Array of redeem price ratios
    function getTokenPriceRatios(
        address[] memory treasuryTokens,
        uint256[] memory tokenIds
    ) external view returns (uint256[] memory, uint256[] memory) {
        uint256[] memory mintPriceRatios = new uint256[](treasuryTokens.length);
        uint256[] memory redeemPriceRatios = new uint256[](
            treasuryTokens.length
        );
        for (uint256 i = 0; i < treasuryTokens.length; i++) {
            mintPriceRatios[i] = mintPricingData.getCurrencyPrice(
                tokenIs1155[treasuryTokens[i]]
                    ? abi.encode(treasuryTokens[i], tokenIds[i])
                    : abi.encode(treasuryTokens[i])
            );
            redeemPriceRatios[i] = redeemPricingData.getCurrencyPrice(
                tokenIs1155[treasuryTokens[i]]
                    ? abi.encode(treasuryTokens[i], tokenIds[i])
                    : abi.encode(treasuryTokens[i])
            );
        }
        return (mintPriceRatios, redeemPriceRatios);
    }
}
