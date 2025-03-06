# MockERC1155
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/92c3c13d3e6a66ec5e6832bad4bf33e9ff24b4f2/src/dev/mock/MockERC1155.sol)

**Inherits:**
ERC1155


## State Variables
### tokenSupply

```solidity
mapping(uint256 => uint256) public tokenSupply;
```


## Functions
### constructor


```solidity
constructor(string memory uri_) ERC1155(uri_);
```

### mint


```solidity
function mint(address to, uint256 tokenId, uint256 amount) external;
```

