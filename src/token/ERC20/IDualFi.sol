// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IDualFi {
    function deposit(uint256 value) external payable returns (uint256 amount);

    function withdraw(
        uint256 amountIn,
        bool wantNative
    ) external returns (uint256 amount);

    function swapNativeForToken() external payable returns (uint256 amount);

    function swapTokenForNative(
        uint256 amountIn
    ) external returns (uint256 amount);

    function calculateDistributeAmount(
        uint256 erc20Value,
        uint256 nativeValue
    ) external view returns (uint256 amount);

    function calculateWithdrawAmount(
        uint256 amountIn,
        bool wantNative
    ) external view returns (uint256 amount);

    function basis() external view returns (uint256);

    function trimValue() external view returns (uint256);

    function initialNativeRatio() external view returns (uint256);

    function initialERC20Ratio() external view returns (uint256);

    function token() external view returns (address);

    function dead() external view returns (address);
}
