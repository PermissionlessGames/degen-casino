# MockERC1155
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/5e8f008a9d2e5903bd547eedaed31c3efcb6ca7b/src/dev/mock/MockERC1155.sol)

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

