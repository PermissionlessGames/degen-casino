# MockERC1155
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/3230342a3988b6f02b8ad28b0ec1006256aaaab6/src/dev/mock/MockERC1155.sol)

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

