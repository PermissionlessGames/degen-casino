# MockERC1155
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/e51575ec321323c4f0687ab65549f1df9bfb5f4b/src/dev/mock/MockERC1155.sol)

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

