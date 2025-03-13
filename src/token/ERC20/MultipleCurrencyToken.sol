// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../../libraries/PCPricing.sol";
import "./interfaces/IMultipleCurrencyToken.sol";

contract MultipleCurrencyToken is
    ERC20,
    ReentrancyGuard,
    ERC1155Holder,
    IMultipleCurrencyToken
{
    /// @notice SafeERC20 library for ERC20 token operations
    using SafeERC20 for IERC20;
    /// @notice PCPricing library for pricing data operations
    using PCPricing for PCPricing.PricingData;

    /// @notice Pricing data for minting
    PCPricing.PricingData mintPricingData;
    /// @notice Pricing data for redeeming
    PCPricing.PricingData redeemPricingData;
    /// @notice Address used to identify native deposits
    address public immutable INATIVE;
    /// @notice Mapping of token addresses to booleans indicating if they are ERC1155
    mapping(address => bool) public tokenIs1155;
    /// @notice Array of token configurations
    CreatePricingDataParams[] private _tokens;

    /// @notice Get the token configuration at a specific index
    /// @param index The index of the token configuration
    /// @return token The token configuration
    function tokens(
        uint256 index
    ) public view virtual override returns (CreatePricingDataParams memory) {
        require(index < _tokens.length, "Index out of bounds");
        return _tokens[index];
    }

    uint256 _decimals;

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
    /// @dev The decimals of the token are set to the number of decimals of the anchor currency
    /// @dev The token is initialized with the initial pricing data
    constructor(
        string memory name_,
        string memory symbol_,
        address inative,
        uint256 adjustmentNumerator,
        uint256 adjustmentDenominator,
        CreatePricingDataParams[] memory currencies
    ) ERC20(name_, symbol_) {
        INATIVE = inative;
        require(currencies.length > 0, "Must provide at least one currency");
        uint256 anchorPrice = currencies[0].price;
        bytes memory anchorCurrencyBytes = encodeCurrency(
            currencies[0].currency,
            currencies[0].tokenId,
            currencies[0].is1155
        );
        tokenIs1155[currencies[0].currency] = currencies[0].is1155;
        _tokens.push(currencies[0]);

        mintPricingData.setAnchorCurrency(anchorCurrencyBytes, anchorPrice);
        redeemPricingData.setAnchorCurrency(anchorCurrencyBytes, anchorPrice);

        mintPricingData.setAdjustmentFactor(
            adjustmentNumerator,
            adjustmentDenominator
        );
        redeemPricingData.setAdjustmentFactor(
            adjustmentNumerator,
            adjustmentDenominator
        );

        for (uint256 i = 1; i < currencies.length; i++) {
            addNewPricingData(currencies[i]);
        }

        _decimals = 10 ** decimals();
    }

    /// @notice Add new pricing data for a currency
    /// @param _createPricingDataParams The pricing data to add
    function addNewPricingData(
        CreatePricingDataParams memory _createPricingDataParams
    ) internal virtual {
        bytes memory currency = encodeCurrency(
            _createPricingDataParams.currency,
            _createPricingDataParams.tokenId,
            _createPricingDataParams.is1155
        );
        mintPricingData.setCurrencyPrice(
            currency,
            _createPricingDataParams.price
        );
        redeemPricingData.setCurrencyPrice(
            currency,
            _createPricingDataParams.price
        );
        tokenIs1155[
            _createPricingDataParams.currency
        ] = _createPricingDataParams.is1155;
        _tokens.push(_createPricingDataParams);
        emit NewPricingDataAdded(_createPricingDataParams);
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
    ) external payable virtual nonReentrant returns (uint256 mintAmount) {
        require(
            currencies.length == amounts.length &&
                tokenIds.length == amounts.length,
            "Mismatched array lengths"
        );

        mintAmount = estimateDepositAmount(currencies, tokenIds, amounts);
        require(mintAmount > 0, "Mint amount too small");
        {
            uint256 msgValue = msg.value;
            depositTokens(currencies, tokenIds, amounts, msg.sender, msgValue);
        }

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
    ) internal virtual {
        for (uint256 i = 0; i < currencies.length; i++) {
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
                require(amounts[i] == msgValue, "Insufficient native value");
                //Incase of multiple cases of Native being passed in.
                msgValue = 0;
            }

            if (currencies[i] != _tokens[0].currency) {
                bytes memory currency = encodeCurrency(
                    currencies[i],
                    tokenIds[i],
                    tokenIs1155[currencies[i]]
                );
                mintPricingData.adjustCurrencyPrice(currency, true);
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
            bytes memory currency = encodeCurrency(
                currencies[i],
                tokenIds[i],
                tokenIs1155[currencies[i]]
            );
            uint256 ratio = getMintPrice(currency);
            uint256 price = (deposits[i] * _decimals) / ratio;
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
    ) external virtual nonReentrant returns (uint256 amountOut) {
        require(amountIn > 0, "Invalid withdraw amount");
        require(balanceOf(msg.sender) >= amountIn, "Insufficient balance");
        amountOut = estimateWithdrawAmount(currency, tokenId, amountIn);
        require(amountOut > 0, "Insufficient balance");
        if (currency != _tokens[0].currency) {
            redeemPricingData.adjustCurrencyPrice(
                encodeCurrency(currency, tokenId, tokenIs1155[currency]),
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
    ) public view virtual returns (uint256 amountOut) {
        bytes memory _currency = encodeCurrency(
            currency,
            tokenId,
            tokenIs1155[currency]
        );
        uint256 price = getRedeemPrice(_currency);
        amountOut = (amountIn * price) / _decimals;
        if (currency == INATIVE) {
            amountOut = amountOut > address(this).balance
                ? address(this).balance
                : amountOut;
        } else if (tokenIs1155[currency]) {
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
        virtual
        returns (address[] memory, uint256[] memory, bool[] memory)
    {
        address[] memory currencies = new address[](_tokens.length);
        uint256[] memory tokenIds = new uint256[](_tokens.length);
        bool[] memory is1155 = new bool[](_tokens.length);
        for (uint256 i = 0; i < _tokens.length; i++) {
            currencies[i] = _tokens[i].currency;
            tokenIds[i] = _tokens[i].tokenId;
            is1155[i] = _tokens[i].is1155;
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
    ) external view virtual returns (uint256[] memory, uint256[] memory) {
        uint256[] memory mintPriceRatios = new uint256[](treasuryTokens.length);
        uint256[] memory redeemPriceRatios = new uint256[](
            treasuryTokens.length
        );
        require(
            treasuryTokens.length == tokenIds.length,
            "Mismatched array lengths"
        );
        for (uint256 i = 0; i < treasuryTokens.length; i++) {
            bytes memory currency = encodeCurrency(
                treasuryTokens[i],
                tokenIds[i],
                tokenIs1155[treasuryTokens[i]]
            );
            mintPriceRatios[i] = getMintPrice(currency);
            redeemPriceRatios[i] = getRedeemPrice(currency);
        }
        return (mintPriceRatios, redeemPriceRatios);
    }

    /// @notice Encode a currency into a bytes array
    /// @param currency The address of the currency
    /// @param tokenId The token ID for ERC1155 tokens (ignored for ERC20)
    /// @param is1155 Boolean indicating if the token is an ERC1155
    /// @return currencyBytes The encoded currency
    function encodeCurrency(
        address currency,
        uint256 tokenId,
        bool is1155
    ) public pure virtual returns (bytes memory) {
        return abi.encodePacked(currency, tokenId, is1155);
    }

    /// @notice Get the mint price for a currency
    /// @param currency The encoded currency
    /// @return price The mint price
    function getMintPrice(
        bytes memory currency
    ) public view virtual returns (uint256) {
        return
            mintPricingData.getCurrencyPrice(currency) >
                redeemPricingData.getCurrencyPrice(currency)
                ? mintPricingData.getCurrencyPrice(currency)
                : redeemPricingData.getCurrencyPrice(currency);
    }

    /// @notice Get the redeem price for a currency
    /// @param currency The encoded currency
    /// @return price The redeem price
    function getRedeemPrice(
        bytes memory currency
    ) public view virtual returns (uint256) {
        return
            redeemPricingData.getCurrencyPrice(currency) <
                mintPricingData.getCurrencyPrice(currency)
                ? redeemPricingData.getCurrencyPrice(currency)
                : mintPricingData.getCurrencyPrice(currency);
    }

    /// @notice Check if a currency exists
    /// @param currency The address of the currency
    /// @param tokenId The token ID for ERC1155 tokens (ignored for ERC20)
    /// @param is1155 Boolean indicating if the token is an ERC1155
    /// @return exists Boolean indicating if the currency exists
    function doesCurrencyExist(
        address currency,
        uint256 tokenId,
        bool is1155
    ) public view virtual returns (bool) {
        return
            mintPricingData.currencyExists(
                encodeCurrency(currency, tokenId, is1155)
            );
    }

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
    ) public view virtual returns (uint256, bool) {
        bytes memory _currency = encodeCurrency(currency, tokenId, is1155);
        if (mintPricingData.currencyExists(_currency)) {
            uint256 price = getMintPrice(_currency);
            return ((requestingAmount * price) / _decimals, true);
        } else {
            return (0, false);
        }
    }

    /// @notice Get the amount wanted to redeem a currency
    /// @param requestingAmount The amount of tokens to redeem
    /// @param currency The address of the currency
    /// @param tokenId The token ID for ERC1155 tokens (ignored for ERC20)
    /// @param is1155 Boolean indicating if the token is an ERC1155
    /// @return amount The amount needed to redeem requested amount
    /// @return exists Boolean indicating if the currency exists
    function amountWantedToRedeem(
        uint256 requestingAmount,
        address currency,
        uint256 tokenId,
        bool is1155
    ) public view virtual returns (uint256, bool) {
        bytes memory _currency = encodeCurrency(currency, tokenId, is1155);
        if (redeemPricingData.currencyExists(_currency)) {
            uint256 price = getRedeemPrice(_currency);
            return ((requestingAmount * price) / _decimals, true);
        } else {
            return (0, false);
        }
    }

    /// @notice Receive function to allow contract to receive native currency
    receive() external payable {}
}
