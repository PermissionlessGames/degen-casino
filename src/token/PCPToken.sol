// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../libraries/PCPricing.sol";

contract PCPricedToken is ERC20, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using PCPricing for PCPricing.PricingData;

    PCPricing.PricingData private pricingData;
    address public immutable INATIVE; // Used to identify native deposits
    address[] public tokens; // Tokens that can be deposited

    constructor(
        string memory name_,
        string memory symbol_,
        address anchorCurrency,
        uint256 anchorPrice,
        address inative,
        uint256 adjustmentNumerator,
        uint256 adjustmentDenominator,
        address[] memory currencies,
        uint256[] memory prices
    ) ERC20(name_, symbol_) {
        INATIVE = inative;
        pricingData.setAnchorCurrency(abi.encode(anchorCurrency), anchorPrice);
        pricingData.setAdjustmentFactor(
            adjustmentNumerator,
            adjustmentDenominator
        );

        require(currencies.length == prices.length, "Mismatched array lengths");
        tokens.push(anchorCurrency);
        for (uint256 i = 0; i < currencies.length; i++) {
            pricingData.setCurrencyPrice(abi.encode(currencies[i]), prices[i]);
            tokens.push(currencies[i]);
        }
    }

    /// @notice Deposit and mint based on currency price
    function deposit(
        address[] memory currencies,
        uint256[] memory amounts
    ) external payable nonReentrant returns (uint256 mintAmount) {
        require(
            currencies.length == amounts.length,
            "Mismatched array lengths"
        );

        mintAmount = estimateDepositAmount(currencies, amounts);
        depositTokens(currencies, amounts, msg.sender, msg.value);
        require(mintAmount > 0, "Mint amount too small");

        _mint(msg.sender, mintAmount);
    }

    function depositTokens(
        address[] memory currencies,
        uint256[] memory amounts,
        address caller,
        uint256 msgValue
    ) internal {
        for (uint256 i; i < currencies.length; i++) {
            require(amounts[i] > 0, "Amount must be greater than 0");
            if (currencies[i] != INATIVE) {
                IERC20(currencies[i]).safeTransferFrom(
                    caller,
                    address(this),
                    amounts[i]
                );
            } else {
                require(
                    amounts[i] == msgValue,
                    "Native value does not match amount passed in"
                );
                //Incase of multiple cases of Native being passed in.
                msgValue -= amounts[i];
            }
            if (currencies[i] != tokens[0]) {
                pricingData.adjustCurrencyPrice(
                    abi.encode(currencies[i]),
                    true
                );
            } else {
                pricingData.adjustAllNonAnchorPrices(false);
            }
        }
    }

    function estimateDepositAmount(
        address[] memory currencies,
        uint256[] memory deposits
    ) public view returns (uint256 amount) {
        for (uint i = 0; i < currencies.length; i++) {
            uint256 price = pricingData.getCurrencyPrice(
                abi.encode(currencies[i])
            );
            amount += (deposits[i] * 1e18) / price;
        }
    }

    /// @notice Withdraw and burn tokens based on currency price
    function withdraw(
        address currency,
        uint256 amountIn
    ) external nonReentrant returns (uint256 amountOut) {
        require(amountIn > 0, "Invalid withdraw amount");
        require(balanceOf(msg.sender) >= amountIn, "Insufficient balance");
        amountOut = estimateWithdrawAmount(currency, amountIn);
        if (currency != tokens[0]) {
            pricingData.adjustCurrencyPrice(abi.encode(currency), false);
        } else {
            pricingData.adjustAllNonAnchorPrices(true);
        }

        _burn(msg.sender, amountIn);

        if (currency != INATIVE) {
            IERC20(currency).safeTransfer(msg.sender, amountOut);
        } else {
            payable(msg.sender).transfer(amountOut);
        }
    }

    function estimateWithdrawAmount(
        address currency,
        uint256 amountIn
    ) public view returns (uint256 amountOut) {
        uint256 price = pricingData.getCurrencyPrice(abi.encode(currency));
        amountOut = (amountIn * price) / 1e18;
    }

    function getTokens() external view returns (address[] memory) {
        return tokens;
    }

    function getTokenPriceRatio(address token) external view returns (uint256) {
        return pricingData.getCurrencyPrice(abi.encode(token));
    }

    function getTokenPriceRatios(
        address[] memory treasuryTokens
    ) external view returns (uint256[] memory) {
        uint256[] memory priceRatios = new uint256[](treasuryTokens.length);
        for (uint256 i = 0; i < treasuryTokens.length; i++) {
            priceRatios[i] = pricingData.getCurrencyPrice(
                abi.encode(treasuryTokens[i])
            );
        }
        return priceRatios;
    }
}
