// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../../libraries/PCPricing.sol";
import "./interfaces/IMultipleCurrencyToken.sol";
import {CreatePricingDataParams, MCTTokens} from "./structs/MCTStructs.sol";

contract MultipleCurrencyToken is ERC20, ReentrancyGuard, ERC1155Holder, IMultipleCurrencyToken {
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

    mapping(bytes => uint256) private _decimals;

    /// @notice Array of token configurations
    CreatePricingDataParams[] private _tokens;

    /// @notice Get the token configuration at a specific index
    /// @param index The index of the token configuration
    /// @return token The token configuration
    function tokens(uint256 index) public view virtual override returns (CreatePricingDataParams memory) {
        require(index < _tokens.length, "Index out of bounds");
        return _tokens[index];
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
            MCTTokens({currency: currencies[0].currency, tokenId: currencies[0].tokenId, is1155: currencies[0].is1155})
        );
        tokenIs1155[currencies[0].currency] = currencies[0].is1155;
        _tokens.push(currencies[0]);

        mintPricingData.setAnchorCurrency(anchorCurrencyBytes, anchorPrice);
        redeemPricingData.setAnchorCurrency(anchorCurrencyBytes, anchorPrice);
        _decimals[anchorCurrencyBytes] = 10 ** currencies[0].decimalCount;
        mintPricingData.setAdjustmentFactor(adjustmentNumerator, adjustmentDenominator);
        redeemPricingData.setAdjustmentFactor(adjustmentNumerator, adjustmentDenominator);

        for (uint256 i = 1; i < currencies.length; i++) {
            addNewPricingData(currencies[i]);
        }
        //Set the batch size for processing large arrays of currencies
        redeemPricingData.setBatchSize(5);
        mintPricingData.setBatchSize(5);
    }

    /// @notice Add new pricing data for a currency
    /// @param _createPricingDataParams The pricing data to add
    function addNewPricingData(CreatePricingDataParams memory _createPricingDataParams) internal virtual {
        MCTTokens memory currency;
        currency.currency = _createPricingDataParams.currency;
        currency.tokenId = _createPricingDataParams.tokenId;
        currency.is1155 = _createPricingDataParams.is1155;
        bytes memory currencyBytes = encodeCurrency(currency);
        mintPricingData.setCurrencyPrice(currencyBytes, _createPricingDataParams.price);
        redeemPricingData.setCurrencyPrice(currencyBytes, _createPricingDataParams.price);
        tokenIs1155[currency.currency] = currency.is1155;
        _tokens.push(_createPricingDataParams);
        _decimals[currencyBytes] = 10 ** _createPricingDataParams.decimalCount;
        emit NewPricingDataAdded(_createPricingDataParams);
    }

    /// @notice Deposit tokens to mint PCPTokens
    /// @param currency The currency to deposit
    /// @param amount The amount to deposit
    /// @return mintAmount The amount of PCPTokens minted
    /// @dev For each token:
    /// @dev - If native currency (ETH), amount must match msg.value
    /// @dev - If ERC1155, transfers specified tokenId and amount
    /// @dev - If ERC20, transfers specified amount
    /// @dev Mints PCPTokens based on deposit value calculated from pricing data
    function deposit(MCTTokens memory currency, uint256 amount)
        external
        payable
        virtual
        override
        nonReentrant
        returns (uint256 mintAmount)
    {
        mintAmount = estimateDepositAmount(currency, amount);
        require(mintAmount > 0, "Mint amount too small");
        {
            uint256 msgValue = msg.value;
            depositTokens(currency, amount, msg.sender, msgValue);
        }

        _mint(msg.sender, mintAmount);
    }

    /// @notice Internal function to handle token deposits
    /// @param currency The currency to deposit
    /// @param amount The amount to deposit
    /// @param caller Address initiating the deposit
    /// @param msgValue Native currency value sent with transaction
    function depositTokens(MCTTokens memory currency, uint256 amount, address caller, uint256 msgValue)
        internal
        virtual
    {
        if (currency.currency != INATIVE) {
            if (currency.is1155) {
                IERC1155(currency.currency).safeTransferFrom(caller, address(this), currency.tokenId, amount, "");
            } else {
                IERC20(currency.currency).safeTransferFrom(caller, address(this), amount);
            }
        } else {
            require(amount == msgValue, "Insufficient native value");
        }

        if (currency.currency != _tokens[0].currency) {
            bytes memory currencyBytes = encodeCurrency(currency);
            mintPricingData.adjustCurrencyPrice(currencyBytes, false);
        } else {
            mintPricingData.adjustAllNonAnchorPrices(true);
        }
    }

    /// @notice Estimate the amount of tokens to be minted based on currency price
    /// @param currency The currency to deposit
    /// @param amount The amount to deposit
    /// @return amount The estimated amount of tokens to be minted
    function estimateDepositAmount(MCTTokens memory currency, uint256 depositAmount)
        public
        view
        virtual
        override
        returns (uint256 amount)
    {
        bytes memory currencyBytes = encodeCurrency(currency);
        uint256 ratio = getMintPrice(currencyBytes);
        amount = (depositAmount * ratio) / _decimals[currencyBytes];
    }

    /// @notice Withdraw tokens from the contract
    /// @param currency The currency to withdraw
    /// @param amountIn The amount of PCP tokens to burn
    /// @return amountOut The amount of tokens withdrawn
    /// @dev Burns PCP tokens and returns the underlying assets
    /// @dev If currency is not the anchor currency, its price is decreased
    /// @dev If currency is the anchor currency, all other currency prices are increased
    /// @dev For ERC1155 tokens, uses safeTransferFrom
    /// @dev For ERC20 tokens, uses safeTransfer
    /// @dev For native, uses call
    function withdraw(MCTTokens memory currency, uint256 amountIn)
        external
        virtual
        override
        nonReentrant
        returns (uint256 amountOut)
    {
        require(amountIn > 0, "Invalid withdraw amount");
        require(balanceOf(msg.sender) >= amountIn, "Insufficient balance");
        amountOut = estimateWithdrawAmount(currency, amountIn);
        require(amountOut > 0, "Insufficient balance");
        if (currency.currency != _tokens[0].currency) {
            bytes memory currencyBytes = encodeCurrency(currency);
            redeemPricingData.adjustCurrencyPrice(currencyBytes, true);
        } else {
            redeemPricingData.adjustAllNonAnchorPrices(false);
        }

        _burn(msg.sender, amountIn);

        if (currency.currency != INATIVE) {
            if (currency.is1155) {
                IERC1155(currency.currency).safeTransferFrom(address(this), msg.sender, currency.tokenId, amountOut, "");
            } else {
                IERC20(currency.currency).safeTransfer(msg.sender, amountOut);
            }
        } else {
            address payable _to = payable(msg.sender);
            (bool success,) = _to.call{value: amountOut}("");
            require(success, "Transfer failed");
        }
    }

    /// @notice Estimate the amount of tokens to be withdrawn based on currency price
    /// @param currency The currency to withdraw
    /// @param amountIn The amount of PCP tokens to burn
    /// @return amountOut The estimated amount of tokens to be withdrawn
    function estimateWithdrawAmount(MCTTokens memory currency, uint256 amountIn)
        public
        view
        virtual
        returns (uint256 amountOut)
    {
        bytes memory _currency = encodeCurrency(currency);
        uint256 price = getRedeemPrice(_currency);
        amountOut = (amountIn * _decimals[_currency]) / price;
        if (currency.currency == INATIVE) {
            amountOut = amountOut > address(this).balance ? address(this).balance : amountOut;
        } else if (currency.is1155) {
            amountOut = amountOut > IERC1155(currency.currency).balanceOf(address(this), currency.tokenId)
                ? IERC1155(currency.currency).balanceOf(address(this), currency.tokenId)
                : amountOut;
        } else {
            amountOut = amountOut > IERC20(currency.currency).balanceOf(address(this))
                ? IERC20(currency.currency).balanceOf(address(this))
                : amountOut;
        }
    }

    /// @notice Get the list of tokens and their properties
    /// @return currencies Array of token addresses
    /// @return tokenIds Array of token IDs
    /// @return is1155 Array of booleans indicating if the token is an ERC1155
    function getTokens() external view virtual override returns (address[] memory, uint256[] memory, bool[] memory) {
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
    /// @param currencies Array of token addresses to get price ratios for
    /// @return mintPriceRatios Array of mint price ratios
    /// @return redeemPriceRatios Array of redeem price ratios
    function getTokenPriceRatios(MCTTokens[] memory currencies)
        external
        view
        virtual
        returns (uint256[] memory, uint256[] memory)
    {
        uint256[] memory mintPriceRatios = new uint256[](currencies.length);
        uint256[] memory redeemPriceRatios = new uint256[](currencies.length);

        for (uint256 i = 0; i < currencies.length; i++) {
            bytes memory currencyBytes = encodeCurrency(currencies[i]);
            mintPriceRatios[i] = getMintPrice(currencyBytes);
            redeemPriceRatios[i] = getRedeemPrice(currencyBytes);
        }
        return (mintPriceRatios, redeemPriceRatios);
    }

    /// @notice Encode a currency into a bytes array
    /// @param currency The currency to encode
    /// @return currencyBytes The encoded currency
    function encodeCurrency(MCTTokens memory currency) public pure virtual override returns (bytes memory) {
        return abi.encodePacked(currency.currency, currency.tokenId, currency.is1155);
    }

    /// @notice Get the mint price for a currency
    /// @param currency The encoded currency
    /// @return price The mint price
    function getMintPrice(bytes memory currency) public view virtual override returns (uint256) {
        return mintPricingData.getCurrencyPrice(currency) < redeemPricingData.getCurrencyPrice(currency)
            ? mintPricingData.getCurrencyPrice(currency)
            : redeemPricingData.getCurrencyPrice(currency);
    }

    /// @notice Get the redeem price for a currency
    /// @param currency The encoded currency
    /// @return price The redeem price
    function getRedeemPrice(bytes memory currency) public view virtual returns (uint256) {
        return redeemPricingData.getCurrencyPrice(currency) > mintPricingData.getCurrencyPrice(currency)
            ? redeemPricingData.getCurrencyPrice(currency)
            : mintPricingData.getCurrencyPrice(currency);
    }

    /// @notice Check if a currency exists
    /// @param currency The currency to check
    /// @return exists Boolean indicating if the currency exists
    function doesCurrencyExist(MCTTokens memory currency) public view virtual override returns (bool) {
        return mintPricingData.currencyExists(encodeCurrency(currency));
    }

    /// @notice Get the amount needed to mint a currency
    /// @param requestingAmount The amount of MCT tokens to mint
    /// @param currency The currency wanting to deposit
    /// @return amount The amount needed of treasury tokens to mint
    function amountNeededToMint(uint256 requestingAmount, MCTTokens memory currency)
        public
        view
        virtual
        override
        returns (uint256, bool)
    {
        bytes memory _currency = encodeCurrency(currency);
        if (mintPricingData.currencyExists(_currency)) {
            uint256 price = getMintPrice(_currency);
            return ((requestingAmount * _decimals[_currency]) / price, true);
        } else {
            return (0, false);
        }
    }

    /// @notice Get the amount wanted to redeem a currency
    /// @param requestingAmount The amount of treasury tokens to redeem
    /// @param currency The currency wanting to redeem
    /// @return amount The amount needed to redeem requested amount
    /// @return exists Boolean indicating if the currency exists
    function amountWantedToRedeem(uint256 requestingAmount, MCTTokens memory currency)
        public
        view
        virtual
        override
        returns (uint256, bool)
    {
        bytes memory _currency = encodeCurrency(currency);
        if (
            redeemPricingData.currencyExists(_currency)
                && requestingAmount <= IERC20(currency.currency).balanceOf(address(this))
        ) {
            uint256 price = getRedeemPrice(_currency);
            uint256 amount = (requestingAmount * price) / _decimals[_currency];
            return (amount, true);
        } else {
            return (0, false);
        }
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IMultipleCurrencyToken).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @notice Receive function to allow contract to receive native currency
    receive() external payable {}
}
