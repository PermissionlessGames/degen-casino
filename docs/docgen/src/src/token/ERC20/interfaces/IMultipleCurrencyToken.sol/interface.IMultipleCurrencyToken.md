# IMultipleCurrencyToken
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/f5c690e811e13fbceddc4a674556bfa12726141f/src/token/ERC20/interfaces/IMultipleCurrencyToken.sol)


## Functions
### tokens


```solidity
function tokens(uint256 index) external view returns (CreatePricingDataParams memory);
```

### encodeCurrency


```solidity
function encodeCurrency(address currency, uint256 tokenId, bool is1155) external pure returns (bytes memory);
```

### getMintPrice


```solidity
function getMintPrice(bytes memory currency) external view returns (uint256);
```

### getRedeemPrice


```solidity
function getRedeemPrice(bytes memory currency) external view returns (uint256);
```

### deposit


```solidity
function deposit(address[] memory currencies, uint256[] memory tokenIds, uint256[] memory amounts)
    external
    payable
    returns (uint256 mintAmount);
```

### withdraw


```solidity
function withdraw(address currency, uint256 tokenId, uint256 amountIn) external returns (uint256 amountOut);
```

### estimateDepositAmount


```solidity
function estimateDepositAmount(address[] memory currencies, uint256[] memory tokenIds, uint256[] memory deposits)
    external
    view
    returns (uint256 amount);
```

### getTokens


```solidity
function getTokens()
    external
    view
    returns (address[] memory currencies, uint256[] memory tokenIds, bool[] memory is1155);
```

### doesCurrencyExist


```solidity
function doesCurrencyExist(address currency, uint256 tokenId, bool is1155) external view returns (bool);
```

## Events
### NewPricingDataAdded

```solidity
event NewPricingDataAdded(CreatePricingDataParams pricingData);
```

## Structs
### CreatePricingDataParams

```solidity
struct CreatePricingDataParams {
    address currency;
    uint256 price;
    bool is1155;
    uint256 tokenId;
}
```

