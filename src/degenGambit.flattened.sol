// SPDX-License-Identifier: MIT
pragma solidity <0.9.0 >=0.4.21 ^0.8.13 ^0.8.20;

// lib/openzeppelin/contracts/interfaces/draft-IERC6093.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}

// lib/openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// lib/openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// lib/openzeppelin/contracts/utils/ReentrancyGuard.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

// src/ArbSys.sol

/**
 * This code was adapted from the OffchainLabs/nitor-contracts repository: https://github.com/OffchainLabs/nitro-contracts.
 * Specifically, the ArbSys contract at commit 2ba206505edd15ad1e177392c454e89479959ca5:
 * https://github.com/OffchainLabs/nitro-contracts/blob/7396313311ab17cb30e2eef27cccf96f0a9e8f7f/src/precompiles/ArbSys.sol
 *
 * Installing it as a foundry dependency had two issues:
 * 1. Default tag did not support Solidity ^0.8.13.
 * 2. The submodule is huge and we only need this interface.
 *
 * To make it easier to mock, we have only retained the `arbBlockNumber` method. This is the only method we currently use in our games.
 */

/**
 * @title Precompiled contract that exists in every Arbitrum chain at address(100), 0x0000000000000000000000000000000000000064. Exposes a variety of system-level functionality.
 */
interface ArbSys {
    /**
     * @notice Get Arbitrum block number (distinct from L1 block number; Arbitrum genesis block has block number 0)
     * @return block number as int
     */
    function arbBlockNumber() external view returns (uint);

    /**
     * @notice Get Arbitrum block hash (reverts unless currentBlockNum-256 <= arbBlockNum < currentBlockNum)
     * @return block hash
     */
    function arbBlockHash(uint256 arbBlockNum) external view returns (bytes32);
}

// lib/openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// lib/openzeppelin/contracts/token/ERC20/ERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}

// src/DegenGambit.sol

/// @title DegenGambit
/// @notice This is the game contract for Degen's Gambit, a permissionless slot machine game.
/// @notice Degen's Gambit comes with a streak mechanic. Players get an ERC20 GAMBIT token every time
/// they extend their streak. They can spend a GAMBIT token to spin with improved odds of winning.
/// @dev This ocntract depends on the ArbSys precompile that comes on Arbitrum Nitro chains to provide the current block number.
/// For more details: https://docs.arbitrum.io/build-decentralized-apps/arbitrum-vs-ethereum/block-numbers-and-time
contract DegenGambit is ERC20, ReentrancyGuard {
    uint256 private constant BITS_30 = 0x3FFFFFFF;
    uint256 private constant SECONDS_PER_DAY = 60 * 60 * 24;

    /// The GAMBIT reward for daily streaks.
    uint256 public constant DailyStreakReward = 1;

    /// The GAMBIT reward for weekly streaks.
    uint256 public constant WeeklyStreakReward = 5;

    // Cumulative mass functions for probability distributions. Total mass for each distribution is 2^30 = 1073741824.
    // These values were generated by the game design notebook. If you know, you know.

    /// Cumulative mass function for the UnmodifiedLeftReel
    uint256[19] public UnmodifiedLeftReel = [
        0 + 24970744, // 0 - 0 (null)
        24970744 + 99882960, // 1 - Gold star (minor)
        124853704 + 49941480, // 2 - Diamonds (suit) (minor)
        174795184 + 49941480, // 3 - Clubs (suit) (minor)
        224736664 + 99882960, // 4 - Spades (suit) (minor)
        324619624 + 49941480, // 5 - Hearts (suit) (minor)
        374561104 + 49941480, // 6 - Diamond (gem) (minor)
        424502584 + 99882960, // 7 - Banana (minor)
        524385544 + 49941480, // 8 - Cherry (minor)
        574327024 + 49941480, // 9 - Pineapple (minor)
        624268504 + 99882960, // 10 - Orange (minor)
        724151464 + 49941480, // 11 - Apple (minor)
        774092944 + 49941480, // 12 - Bell (minor)
        824034424 + 99882960, // 13 - Gold coin (minor)
        923917384 + 49941480, // 14 - Crescent moon (minor)
        973858864 + 49941480, // 15 - Full moon (minor)
        1023800344 + 24970740, // 16 - Gold 7 (major)
        1048771084 + 12485370, // 17 - Red 7 (major)
        1061256454 + 12485370 // 18 - Diamond 7 (major)
    ];

    /// Cumulative mass function for the UnmodifiedCenterReel
    uint256[19] public UnmodifiedCenterReel = [
        0 + 24970744, // 0 - 0 (null)
        24970744 + 49941480, // 1 - Gold star (minor)
        74912224 + 99882960, // 2 - Diamonds (suit) (minor)
        174795184 + 49941480, // 3 - Clubs (suit) (minor)
        224736664 + 49941480, // 4 - Spades (suit) (minor)
        274678144 + 99882960, // 5 - Hearts (suit) (minor)
        374561104 + 49941480, // 6 - Diamond (gem) (minor)
        424502584 + 49941480, // 7 - Banana (minor)
        474444064 + 99882960, // 8 - Cherry (minor)
        574327024 + 49941480, // 9 - Pineapple (minor)
        624268504 + 49941480, // 10 - Orange (minor)
        674209984 + 99882960, // 11 - Apple (minor)
        774092944 + 49941480, // 12 - Bell (minor)
        824034424 + 49941480, // 13 - Gold coin (minor)
        873975904 + 99882960, // 14 - Crescent moon (minor)
        973858864 + 49941480, // 15 - Full moon (minor)
        1023800344 + 12485370, // 16 - Gold 7 (major)
        1036285714 + 24970740, // 17 - Red 7 (major)
        1061256454 + 12485370 // 18 - Diamond 7 (major)
    ];

    /// Cumulative mass function for the UnmodifiedCenterReel
    uint256[19] public UnmodifiedRightReel = [
        0 + 24970744, // 0 - 0 (null)
        24970744 + 49941480, // 1 - Gold star (minor)
        74912224 + 49941480, // 2 - Diamonds (suit) (minor)
        124853704 + 99882960, // 3 - Clubs (suit) (minor)
        224736664 + 49941480, // 4 - Spades (suit) (minor)
        274678144 + 49941480, // 5 - Hearts (suit) (minor)
        324619624 + 99882960, // 6 - Diamond (gem) (minor)
        424502584 + 49941480, // 7 - Banana (minor)
        474444064 + 49941480, // 8 - Cherry (minor)
        524385544 + 99882960, // 9 - Pineapple (minor)
        624268504 + 49941480, // 10 - Orange (minor)
        674209984 + 49941480, // 11 - Apple (minor)
        724151464 + 99882960, // 12 - Bell (minor)
        824034424 + 49941480, // 13 - Gold coin (minor)
        873975904 + 49941480, // 14 - Crescent moon (minor)
        923917384 + 99882960, // 15 - Full moon (minor)
        1023800344 + 12485370, // 16 - Gold 7 (major)
        1036285714 + 12485370, // 17 - Red 7 (major)
        1048771084 + 24970740 // 18 - Diamond 7 (major)
    ];

    /// Cumulative mass function for the ImprovedLeftReel
    uint256[19] public ImprovedLeftReel = [
        0 + 2526414, // 0 - 0 (null)
        2526414 + 102068183, // 1 - Gold star (minor)
        104594597 + 51034067, // 2 - Diamonds (suit) (minor)
        155628664 + 51034067, // 3 - Clubs (suit) (minor)
        206662731 + 102068183, // 4 - Spades (suit) (minor)
        308730914 + 51034067, // 5 - Hearts (suit) (minor)
        359764981 + 51034067, // 6 - Diamond (gem) (minor)
        410799048 + 102068183, // 7 - Banana (minor)
        512867231 + 51034067, // 8 - Cherry (minor)
        563901298 + 51034067, // 9 - Pineapple (minor)
        614935365 + 102068183, // 10 - Orange (minor)
        717003548 + 51034067, // 11 - Apple (minor)
        768037615 + 51034067, // 12 - Bell (minor)
        819071682 + 102068183, // 13 - Gold coin (minor)
        921139865 + 51034067, // 14 - Crescent moon (minor)
        972173932 + 51034067, // 15 - Full moon (minor)
        1023207999 + 25266913, // 16 - Gold 7 (major)
        1048474912 + 12633456, // 17 - Red 7 (major)
        1061108368 + 12633456 // 18 - Diamond 7 (major)
    ];

    /// Cumulative mass function for the ImprovedCenterReel
    uint256[19] public ImprovedCenterReel = [
        0 + 2526414, // 0 - 0 (null)
        2526414 + 51034067, // 1 - Gold star (minor)
        53560481 + 102068183, // 2 - Diamonds (suit) (minor)
        155628664 + 51034067, // 3 - Clubs (suit) (minor)
        206662731 + 51034067, // 4 - Spades (suit) (minor)
        257696798 + 102068183, // 5 - Hearts (suit) (minor)
        359764981 + 51034067, // 6 - Diamond (gem) (minor)
        410799048 + 51034067, // 7 - Banana (minor)
        461833115 + 102068183, // 8 - Cherry (minor)
        563901298 + 51034067, // 9 - Pineapple (minor)
        614935365 + 51034067, // 10 - Orange (minor)
        665969432 + 102068183, // 11 - Apple (minor)
        768037615 + 51034067, // 12 - Bell (minor)
        819071682 + 51034067, // 13 - Gold coin (minor)
        870105749 + 102068183, // 14 - Crescent moon (minor)
        972173932 + 51034067, // 15 - Full moon (minor)
        1023207999 + 12633456, // 16 - Gold 7 (major)
        1035841455 + 25266913, // 17 - Red 7 (major)
        1061108368 + 12633456 // 18 - Diamond 7 (major)
    ];

    /// Cumulative mass function for the ImprovedCenterReel
    uint256[19] public ImprovedRightReel = [
        0 + 2526414, // 0 - 0 (null)
        2526414 + 51034067, // 1 - Gold star (minor)
        53560481 + 51034067, // 2 - Diamonds (suit) (minor)
        104594548 + 102068183, // 3 - Clubs (suit) (minor)
        206662731 + 51034067, // 4 - Spades (suit) (minor)
        257696798 + 51034067, // 5 - Hearts (suit) (minor)
        308730865 + 102068183, // 6 - Diamond (gem) (minor)
        410799048 + 51034067, // 7 - Banana (minor)
        461833115 + 51034067, // 8 - Cherry (minor)
        512867182 + 102068183, // 9 - Pineapple (minor)
        614935365 + 51034067, // 10 - Orange (minor)
        665969432 + 51034067, // 11 - Apple (minor)
        717003499 + 102068183, // 12 - Bell (minor)
        819071682 + 51034067, // 13 - Gold coin (minor)
        870105749 + 51034067, // 14 - Crescent moon (minor)
        921139816 + 102068183, // 15 - Full moon (minor)
        1023207999 + 12633456, // 16 - Gold 7 (major)
        1035841455 + 12633456, // 17 - Red 7 (major)
        1048474911 + 25266913 // 18 - Diamond 7 (major)
    ];

    /// How many blocks a player has to act (respin/accept).
    uint256 public BlocksToAct;

    /// The block number of the last spin/respin by each player.
    mapping(address => uint256) public LastSpinBlock;

    /// Whether or not the last spin for a given player is a boosted spin.
    mapping(address => bool) public LastSpinBoosted;

    /// Cost (finest denomination of native token on the chain) to roll.
    uint256 public CostToSpin;

    /// Cost (finest denomination of native token on the chain) to reroll.
    uint256 public CostToRespin;

    /// Day on which the last in-streak spin was made by a given player. This is for daily streaks.
    mapping(address => uint256) public LastStreakDay;

    /// Week on which the last in-streak spin was made by a given player. This is for weekly streaks.
    mapping(address => uint256) public LastStreakWeek;

    /// Fired when a player spins (and respins).
    event Spin(address indexed player, bool indexed bonus);
    /// Fired when a player accepts the outcome of a roll.
    event Award(address indexed player, uint256 value);
    /// Fired when a player continues a daily streak.
    event DailyStreak(address indexed player, uint256 day);
    /// Fired when a player continues a weekly streak.
    event WeeklyStreak(address indexed player, uint256 week);

    /// Signifies that the player is no longer able to act because too many blocks elapsed since their
    /// last action.
    error DeadlineExceeded();
    /// This error is raised to signify that the player needs to wait for at least one more block to elapse.
    error WaitForTick();
    /// Signifies that the player has not provided enough value to perform the action.
    error InsufficientValue();
    /// Signifies that a reel outcome is out of bounds.
    error OutcomeOutOfBounds();

    function supportsInterface(bytes4 interfaceID) public pure returns (bool) {
        return
            interfaceID == 0x01ffc9a7 || // ERC-165 support (i.e. `bytes4(keccak256('supportsInterface(bytes4)'))`).
            interfaceID == 0x36372b07; // ERC20 support -- all methods on OpenZeppelin IERC20 excluding "name", "symbol", and "decimals".
    }

    /// In addition to the game mechanics, DegensGambit is also an ERC20 contract in which the ERC20
    /// tokens represent bonus spins. The symbol for this contract is GAMBIT.
    constructor(
        uint256 blocksToAct,
        uint256 costToSpin,
        uint256 costToRespin
    ) ERC20("Degen's Gambit", "GAMBIT") {
        BlocksToAct = blocksToAct;
        CostToSpin = costToSpin;
        CostToRespin = costToRespin;
    }

    /// Allows the contract to receive the native token on its blockchain.
    receive() external payable {}

    /// The GAMBIT token (representing bonus rolls on the Degen's Gambit slot machine) has 0 decimals.
    function decimals() public pure override returns (uint8) {
        return 0;
    }

    function _blockNumber() internal view returns (uint256) {
        return ArbSys(address(100)).arbBlockNumber();
    }

    function _blockhash(uint256 number) internal view returns (bytes32) {
        return ArbSys(address(100)).arbBlockHash(number);
    }

    function _enforceTick(address degenerate) internal view {
        if (_blockNumber() <= LastSpinBlock[degenerate]) {
            revert WaitForTick();
        }
    }

    function _enforceDeadline(address degenerate) internal view {
        if (_blockNumber() > LastSpinBlock[degenerate] + BlocksToAct) {
            revert DeadlineExceeded();
        }
    }

    function _entropy(
        address degenerate
    ) internal view virtual returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encode(
                        _blockhash(LastSpinBlock[degenerate]),
                        degenerate
                    )
                )
            );
    }

    /// sampleUnmodifiedLeftReel samples the outcome from UnmodifiedLeftReel specified by the given entropy
    function sampleUnmodifiedLeftReel(
        uint256 entropy
    ) public view returns (uint256) {
        uint256 sample = (entropy >> 60) & BITS_30;
        if (sample < UnmodifiedLeftReel[0]) {
            return 0;
        } else if (sample < UnmodifiedLeftReel[1]) {
            return 1;
        } else if (sample < UnmodifiedLeftReel[2]) {
            return 2;
        } else if (sample < UnmodifiedLeftReel[3]) {
            return 3;
        } else if (sample < UnmodifiedLeftReel[4]) {
            return 4;
        } else if (sample < UnmodifiedLeftReel[5]) {
            return 5;
        } else if (sample < UnmodifiedLeftReel[6]) {
            return 6;
        } else if (sample < UnmodifiedLeftReel[7]) {
            return 7;
        } else if (sample < UnmodifiedLeftReel[8]) {
            return 8;
        } else if (sample < UnmodifiedLeftReel[9]) {
            return 9;
        } else if (sample < UnmodifiedLeftReel[10]) {
            return 10;
        } else if (sample < UnmodifiedLeftReel[11]) {
            return 11;
        } else if (sample < UnmodifiedLeftReel[12]) {
            return 12;
        } else if (sample < UnmodifiedLeftReel[13]) {
            return 13;
        } else if (sample < UnmodifiedLeftReel[14]) {
            return 14;
        } else if (sample < UnmodifiedLeftReel[15]) {
            return 15;
        } else if (sample < UnmodifiedLeftReel[16]) {
            return 16;
        } else if (sample < UnmodifiedLeftReel[17]) {
            return 17;
        }
        return 18;
    }

    /// sampleUnmodifiedCenterReel samples the outcome from UnmodifiedCenterReel specified by the given entropy
    function sampleUnmodifiedCenterReel(
        uint256 entropy
    ) public view returns (uint256) {
        uint256 sample = (entropy >> 30) & BITS_30;
        if (sample < UnmodifiedCenterReel[0]) {
            return 0;
        } else if (sample < UnmodifiedCenterReel[1]) {
            return 1;
        } else if (sample < UnmodifiedCenterReel[2]) {
            return 2;
        } else if (sample < UnmodifiedCenterReel[3]) {
            return 3;
        } else if (sample < UnmodifiedCenterReel[4]) {
            return 4;
        } else if (sample < UnmodifiedCenterReel[5]) {
            return 5;
        } else if (sample < UnmodifiedCenterReel[6]) {
            return 6;
        } else if (sample < UnmodifiedCenterReel[7]) {
            return 7;
        } else if (sample < UnmodifiedCenterReel[8]) {
            return 8;
        } else if (sample < UnmodifiedCenterReel[9]) {
            return 9;
        } else if (sample < UnmodifiedCenterReel[10]) {
            return 10;
        } else if (sample < UnmodifiedCenterReel[11]) {
            return 11;
        } else if (sample < UnmodifiedCenterReel[12]) {
            return 12;
        } else if (sample < UnmodifiedCenterReel[13]) {
            return 13;
        } else if (sample < UnmodifiedCenterReel[14]) {
            return 14;
        } else if (sample < UnmodifiedCenterReel[15]) {
            return 15;
        } else if (sample < UnmodifiedCenterReel[16]) {
            return 16;
        } else if (sample < UnmodifiedCenterReel[17]) {
            return 17;
        }
        return 18;
    }

    /// sampleUnmodifiedRightReel samples the outcome from UnmodifiedRightReel specified by the given entropy
    function sampleUnmodifiedRightReel(
        uint256 entropy
    ) public view returns (uint256) {
        uint256 sample = entropy & BITS_30;
        if (sample < UnmodifiedRightReel[0]) {
            return 0;
        } else if (sample < UnmodifiedRightReel[1]) {
            return 1;
        } else if (sample < UnmodifiedRightReel[2]) {
            return 2;
        } else if (sample < UnmodifiedRightReel[3]) {
            return 3;
        } else if (sample < UnmodifiedRightReel[4]) {
            return 4;
        } else if (sample < UnmodifiedRightReel[5]) {
            return 5;
        } else if (sample < UnmodifiedRightReel[6]) {
            return 6;
        } else if (sample < UnmodifiedRightReel[7]) {
            return 7;
        } else if (sample < UnmodifiedRightReel[8]) {
            return 8;
        } else if (sample < UnmodifiedRightReel[9]) {
            return 9;
        } else if (sample < UnmodifiedRightReel[10]) {
            return 10;
        } else if (sample < UnmodifiedRightReel[11]) {
            return 11;
        } else if (sample < UnmodifiedRightReel[12]) {
            return 12;
        } else if (sample < UnmodifiedRightReel[13]) {
            return 13;
        } else if (sample < UnmodifiedRightReel[14]) {
            return 14;
        } else if (sample < UnmodifiedRightReel[15]) {
            return 15;
        } else if (sample < UnmodifiedRightReel[16]) {
            return 16;
        } else if (sample < UnmodifiedRightReel[17]) {
            return 17;
        }
        return 18;
    }

    /// sampleImprovedLeftReel samples the outcome from ImprovedLeftReel specified by the given entropy
    function sampleImprovedLeftReel(
        uint256 entropy
    ) public view returns (uint256) {
        uint256 sample = (entropy >> 60) & BITS_30;
        if (sample < ImprovedLeftReel[0]) {
            return 0;
        } else if (sample < ImprovedLeftReel[1]) {
            return 1;
        } else if (sample < ImprovedLeftReel[2]) {
            return 2;
        } else if (sample < ImprovedLeftReel[3]) {
            return 3;
        } else if (sample < ImprovedLeftReel[4]) {
            return 4;
        } else if (sample < ImprovedLeftReel[5]) {
            return 5;
        } else if (sample < ImprovedLeftReel[6]) {
            return 6;
        } else if (sample < ImprovedLeftReel[7]) {
            return 7;
        } else if (sample < ImprovedLeftReel[8]) {
            return 8;
        } else if (sample < ImprovedLeftReel[9]) {
            return 9;
        } else if (sample < ImprovedLeftReel[10]) {
            return 10;
        } else if (sample < ImprovedLeftReel[11]) {
            return 11;
        } else if (sample < ImprovedLeftReel[12]) {
            return 12;
        } else if (sample < ImprovedLeftReel[13]) {
            return 13;
        } else if (sample < ImprovedLeftReel[14]) {
            return 14;
        } else if (sample < ImprovedLeftReel[15]) {
            return 15;
        } else if (sample < ImprovedLeftReel[16]) {
            return 16;
        } else if (sample < ImprovedLeftReel[17]) {
            return 17;
        }
        return 18;
    }

    /// sampleImprovedCenterReel samples the outcome from ImprovedCenterReel specified by the given entropy
    function sampleImprovedCenterReel(
        uint256 entropy
    ) public view returns (uint256) {
        uint256 sample = (entropy >> 30) & BITS_30;
        if (sample < ImprovedCenterReel[0]) {
            return 0;
        } else if (sample < ImprovedCenterReel[1]) {
            return 1;
        } else if (sample < ImprovedCenterReel[2]) {
            return 2;
        } else if (sample < ImprovedCenterReel[3]) {
            return 3;
        } else if (sample < ImprovedCenterReel[4]) {
            return 4;
        } else if (sample < ImprovedCenterReel[5]) {
            return 5;
        } else if (sample < ImprovedCenterReel[6]) {
            return 6;
        } else if (sample < ImprovedCenterReel[7]) {
            return 7;
        } else if (sample < ImprovedCenterReel[8]) {
            return 8;
        } else if (sample < ImprovedCenterReel[9]) {
            return 9;
        } else if (sample < ImprovedCenterReel[10]) {
            return 10;
        } else if (sample < ImprovedCenterReel[11]) {
            return 11;
        } else if (sample < ImprovedCenterReel[12]) {
            return 12;
        } else if (sample < ImprovedCenterReel[13]) {
            return 13;
        } else if (sample < ImprovedCenterReel[14]) {
            return 14;
        } else if (sample < ImprovedCenterReel[15]) {
            return 15;
        } else if (sample < ImprovedCenterReel[16]) {
            return 16;
        } else if (sample < ImprovedCenterReel[17]) {
            return 17;
        }
        return 18;
    }

    /// sampleImprovedRightReel samples the outcome from ImprovedRightReel specified by the given entropy
    function sampleImprovedRightReel(
        uint256 entropy
    ) public view returns (uint256) {
        uint256 sample = entropy & BITS_30;
        if (sample < ImprovedRightReel[0]) {
            return 0;
        } else if (sample < ImprovedRightReel[1]) {
            return 1;
        } else if (sample < ImprovedRightReel[2]) {
            return 2;
        } else if (sample < ImprovedRightReel[3]) {
            return 3;
        } else if (sample < ImprovedRightReel[4]) {
            return 4;
        } else if (sample < ImprovedRightReel[5]) {
            return 5;
        } else if (sample < ImprovedRightReel[6]) {
            return 6;
        } else if (sample < ImprovedRightReel[7]) {
            return 7;
        } else if (sample < ImprovedRightReel[8]) {
            return 8;
        } else if (sample < ImprovedRightReel[9]) {
            return 9;
        } else if (sample < ImprovedRightReel[10]) {
            return 10;
        } else if (sample < ImprovedRightReel[11]) {
            return 11;
        } else if (sample < ImprovedRightReel[12]) {
            return 12;
        } else if (sample < ImprovedRightReel[13]) {
            return 13;
        } else if (sample < ImprovedRightReel[14]) {
            return 14;
        } else if (sample < ImprovedRightReel[15]) {
            return 15;
        } else if (sample < ImprovedRightReel[16]) {
            return 16;
        } else if (sample < ImprovedRightReel[17]) {
            return 17;
        }
        return 18;
    }

    /// Returns the final symbols on the left, center, and right reels respectively for a spin with
    /// the given entropy. The unused entropy is also returned for use by game clients.
    /// @param entropy The entropy created by the spin.
    /// @param boosted Whether or not the spin was boosted.
    function outcome(
        uint256 entropy,
        bool boosted
    )
        public
        view
        returns (
            uint256 left,
            uint256 center,
            uint256 right,
            uint256 remainingEntropy
        )
    {
        if (boosted) {
            left = sampleImprovedLeftReel(entropy);
            center = sampleImprovedCenterReel(entropy);
            right = sampleImprovedRightReel(entropy);
        } else {
            left = sampleUnmodifiedLeftReel(entropy);
            center = sampleUnmodifiedCenterReel(entropy);
            right = sampleUnmodifiedRightReel(entropy);
        }

        remainingEntropy = entropy >> 90;
    }

    /// Payout function for symbol combinations.
    function payout(
        uint256 left,
        uint256 center,
        uint256 right
    ) public view returns (uint256 result) {
        if (left >= 19 || center >= 19 || right >= 19) {
            revert OutcomeOutOfBounds();
        }
        //Default 0 for everything else
        result = 0;
        if (left != 0 && right != 0 && center != 0) {
            if (left == right && left == center && left <= 15) {
                // 3 of a kind with a minor symbol. Case 1
                result = 50 * CostToSpin;
                if (result > address(this).balance >> 6) {
                    result = address(this).balance >> 6;
                }
            } else if (left == right && center >= 16 && left <= 15) {
                // Minor symbol pair on outside reels with major symbol in the center. Case 2
                result = 100 * CostToSpin;
                if (result > address(this).balance >> 4) {
                    result = address(this).balance >> 4;
                }
            } else if (
                left != right &&
                center != left &&
                center != right &&
                left >= 16 &&
                center >= 16 &&
                right >= 16
            ) {
                // Three distinct major symbols. Case 3
                result = address(this).balance >> 3;
            } else if (
                left == right && left != center && left >= 16 && center >= 16
            ) {
                // Major symbol pair on the outside with a different major symbol in the center. Case 4
                result = address(this).balance >> 3;
            } else if (left == center && center == right && left >= 16) {
                // 3 of a kind with a major symbol. Jackpot! Case 5
                result = address(this).balance >> 1;
            }
        }
    }

    // Payout Estimate function to easily display current payouts estimate at time of function call
    function prizes() external view returns (uint256[5] memory prizesAmount) {
        prizesAmount[0] = 50 * CostToSpin < address(this).balance >> 6
            ? 50 * CostToSpin
            : address(this).balance >> 6;
        prizesAmount[1] = 100 * CostToSpin < address(this).balance >> 4
            ? 100 * CostToSpin
            : address(this).balance >> 4;
        prizesAmount[2] = address(this).balance >> 3;
        prizesAmount[3] = address(this).balance >> 3;
        prizesAmount[4] = address(this).balance >> 1;
    }

    //This is a simple function for middleware contracts or UI to determine if there is a prize to accept for player
    function hasPrize(address player) external view returns (bool toReceive) {
        toReceive =
            _blockNumber() > LastSpinBlock[player] &&
            _blockNumber() <= LastSpinBlock[player] + BlocksToAct;
        if (toReceive) {
            (uint256 left, uint256 center, uint256 right, ) = outcome(
                _entropy(player),
                LastSpinBoosted[player]
            );
            uint256 prize = payout(left, center, right);
            toReceive = prize > 0;
        }
        return toReceive;
    }

    /// This is the function a player calls to accept the outcome of a spin.
    /// @dev This call can be delegated to a different account.
    /// @param player account claiming a prize.
    function _accept(
        address player
    )
        internal
        returns (
            uint256 left,
            uint256 center,
            uint256 right,
            uint256 remainingEntropy,
            uint256 prize
        )
    {
        _enforceTick(player);
        _enforceDeadline(player);

        (left, center, right, remainingEntropy) = outcome(
            _entropy(player),
            LastSpinBoosted[player]
        );
        prize = payout(left, center, right);
        payable(player).transfer(prize);
        emit Award(player, prize);

        delete LastSpinBoosted[player];
        delete LastSpinBlock[player];
    }

    /// This is the function a player calls to accept the outcome of a spin.
    /// @dev This call cannot be delegated to a different account.
    function accept()
        external
        nonReentrant
        returns (
            uint256 left,
            uint256 center,
            uint256 right,
            uint256 remainingEntropy,
            uint256 prize
        )
    {
        (left, center, right, remainingEntropy, prize) = _accept(msg.sender);
    }

    /// This is the function a player calls to accept the outcome of a spin.
    /// @dev This call can be delegated to a different account.
    /// @param player account claiming a prize.
    function acceptFor(
        address player
    )
        external
        nonReentrant
        returns (
            uint256 left,
            uint256 center,
            uint256 right,
            uint256 remainingEntropy,
            uint256 prize
        )
    {
        (left, center, right, remainingEntropy, prize) = _accept(player);
    }

    function spinCost(address degenerate) public view returns (uint256) {
        if (_blockNumber() <= LastSpinBlock[degenerate] + BlocksToAct) {
            // This means that all degenerates playing in the first BlocksToAct blocks produced on the blockchain
            // get a discount on their early spins.
            return CostToRespin;
        }
        return CostToSpin;
    }

    /// Spin the slot machine.
    /// @notice If the player sends more value than they absolutely need to, the contract simply accepts it into the pot.
    /// @dev  This call can be delegated to a different account.
    /// @param boost Whether or not the player is using a boost, msg.sender is paying the boost
    /// @param spinPlayer account spin is for
    /// @param streakPlayer account streak reward is for
    /// @param value value being sent to contract
    function _spin(
        address spinPlayer,
        address streakPlayer,
        bool boost,
        uint256 value
    ) internal {
        uint256 requiredFee = spinCost(spinPlayer);
        if (value < requiredFee) {
            revert InsufficientValue();
        }

        uint256 currentDay = block.timestamp / SECONDS_PER_DAY;
        if (LastStreakDay[streakPlayer] + 1 == currentDay) {
            _mint(streakPlayer, DailyStreakReward);
            emit DailyStreak(streakPlayer, currentDay);
        }
        LastStreakDay[streakPlayer] = currentDay;

        uint256 currentWeek = currentDay / 7;
        if (LastStreakWeek[streakPlayer] + 1 == currentWeek) {
            _mint(streakPlayer, WeeklyStreakReward);
            emit WeeklyStreak(streakPlayer, currentWeek);
        }
        LastStreakWeek[streakPlayer] = currentWeek;

        if (boost) {
            // Burn an ERC20 token off of this contract from the player's account.
            _burn(msg.sender, 1);
        }

        LastSpinBlock[spinPlayer] = _blockNumber();
        LastSpinBoosted[spinPlayer] = boost;

        emit Spin(spinPlayer, boost);
    }

    /// Spin the slot machine.
    /// @notice If the player sends more value than they absolutely need to, the contract simply accepts it into the pot.
    /// @dev  Assumes msg.sender is player. This call cannot be delegated to a different account.
    /// @param boost Whether or not the player is using a boost, msg.sender is paying the boost
    function spin(bool boost) external payable {
        _spin(msg.sender, msg.sender, boost, msg.value);
    }

    /// Spin the slot machine for the spinPlayer.
    /// @notice If the player sends more value than they absolutely need to, the contract simply accepts it into the pot.
    /// @dev  This call can be delegated to a different account.
    /// @param boost Whether or not the player is using a boost, msg.sender is paying the boost
    /// @param spinPlayer account spin is for
    /// @param streakPlayer account streak reward is for
    function spinFor(
        address spinPlayer,
        address streakPlayer,
        bool boost
    ) external payable {
        _spin(spinPlayer, streakPlayer, boost, msg.value);
    }

    /// inspectEntropy is a view method which allows clients to check the current entropy for a player given only their address.
    /// @dev This is a convenience method so that clients don't have to calculate the entropy given the spin blockhash themselves. It
    /// also enforces that blocks have ticked since the spin as well as the `BlocksToAct` deadline.
    function inspectEntropy(
        address degenerate
    ) external view returns (uint256) {
        _enforceDeadline(degenerate);
        return _entropy(degenerate);
    }

    /// inspectOutcome is a view method which allows clients to check the outcome of a spin for a player given only their address.
    /// @notice This method allows clients to simulate the outcome of a spin in a single RPC call.
    /// @dev The alternative to using this method would be to call `accept` (rather than submitting it as a transaction). This is simply a more
    /// convenient and natural way to simulate the outcome of a spin, which also works on-chain.
    function inspectOutcome(
        address degenerate
    )
        external
        view
        returns (
            uint256 left,
            uint256 center,
            uint256 right,
            uint256 remainingEntropy,
            uint256 prize
        )
    {
        _enforceDeadline(degenerate);
        (left, center, right, remainingEntropy) = outcome(
            _entropy(degenerate),
            LastSpinBoosted[degenerate]
        );

        prize = payout(left, center, right);
    }
}
