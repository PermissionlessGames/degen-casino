// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../lib/openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../../lib/openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../../lib/openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract DualFi is ERC20, ReentrancyGuard {
    using SafeERC20 for IERC20;
    address public immutable token;
    uint256 public immutable basis;
    address public dead = address(0xdead);
    uint256 public immutable initialNativeRatio;
    uint256 public immutable initialERC20Ratio;
    uint256 public immutable trimValue;

    constructor(
        string memory _name,
        string memory _symbol,
        address tokenA,
        uint256 initialAmount0Token,
        uint256 initialAmountNative,
        uint256 _basis,
        uint256 _trimValue
    ) ERC20(_name, _symbol) {
        token = tokenA;
        require(_basis > 1, "Basis needs to be greater than 1");
        basis = _basis;
        trimValue = _trimValue;
        initialERC20Ratio = initialAmount0Token;
        initialNativeRatio = initialAmountNative;
    }

    function deposit(
        uint256 value
    ) external payable nonReentrant returns (uint256 amount) {
        uint256 nativeValue = msg.value;
        amount = calculateDistributeAmount(value, nativeValue);
        if (value > 0) {
            IERC20(token).safeTransferFrom(msg.sender, address(this), value);
        }
        __mint(msg.sender, amount);
        _trackTrim();
        return amount;
    }

    function calculateDistributeAmount(
        uint256 erc20Value,
        uint256 nativeValue
    ) public view returns (uint256 amount) {
        uint256 halfSupply = totalSupply() / 2;

        if (address(this).balance > nativeValue) {
            amount = (halfSupply * nativeValue) / address(this).balance;
        } else {
            amount = initialNativeRatio * nativeValue;
        }

        if (IERC20(token).balanceOf(address(this)) > 0) {
            amount +=
                (halfSupply * erc20Value) /
                IERC20(token).balanceOf(address(this));
        } else {
            amount += initialERC20Ratio * erc20Value;
        }

        amount = (amount / basis) * (basis - 1);
    }

    function withdraw(
        uint256 amountIn,
        bool wantNative
    ) external nonReentrant returns (uint256 amount) {
        _burn(msg.sender, amountIn);

        amount = calculateWithdrawAmount(amountIn, wantNative);

        if (wantNative) {
            (bool success, ) = msg.sender.call{value: amount}("");
            require(success, "Native transfer failed");
        } else {
            IERC20(token).safeTransfer(msg.sender, amount);
        }
    }

    function calculateWithdrawAmount(
        uint256 amountIn,
        bool wantNative
    ) public view returns (uint256 amount) {
        uint256 halfSupply = totalSupply() / 2;
        if (halfSupply == 0) {
            amount = 0;
        } else {
            if (wantNative) {
                amount = (address(this).balance * amountIn) / halfSupply;
                //Ensure amount is not greater than balance
                amount = amount > address(this).balance
                    ? address(this).balance
                    : amount;
            } else {
                amount =
                    (IERC20(token).balanceOf(address(this)) * amountIn) /
                    halfSupply;
                //ensure amount is not greater than balance
                amount = amount > IERC20(token).balanceOf(address(this))
                    ? IERC20(token).balanceOf(address(this))
                    : amount;
            }
            amount = (amount / basis) * (basis - 1);
        }
    }

    function _trackTrim() internal {
        if (balanceOf(dead) >= trimValue) {
            _burn(dead, trimValue / 2);
        }
    }

    function internalSwap(
        uint256 amountIn,
        bool wantNative
    ) internal returns (uint256 amount) {
        __mint(address(this), amountIn);
        amount = calculateWithdrawAmount(amountIn, wantNative);
        _burn(address(this), balanceOf(address(this)));
    }

    function swapNativeForToken()
        external
        payable
        nonReentrant
        returns (uint256 amount)
    {
        amount = calculateDistributeAmount(0, msg.value);
        amount = internalSwap(amount, false);
        IERC20(token).safeTransfer(msg.sender, amount);
        _trackTrim();
    }

    function swapTokenForNative(
        uint256 amountIn
    ) external nonReentrant returns (uint256 amount) {
        IERC20(token).safeTransferFrom(msg.sender, address(this), amountIn);
        amount = calculateDistributeAmount(amountIn, 0);
        amount = internalSwap(amount, true);
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Native transfer failed");
        _trackTrim();
    }

    function __mint(address to, uint256 amount) internal {
        _mint(to, amount);
        _mint(dead, amount / (basis - 1));
    }
}
