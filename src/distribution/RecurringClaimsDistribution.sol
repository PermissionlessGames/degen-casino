// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract RecurringClaimsDistribution is ReentrancyGuard {
    struct DistributionRound {
        address token; // ERC20 token address or zero for native asset
        uint256 numberOfClaimsRequired;
        uint256 totalTokens; // Total amount of tokens available for the round
        uint256 minClaimInterval;
        uint256 remainingTokens; // Tokens left for distribution
        uint256 totalPerEntryPerClaim; // Tokens a recipient is expected for a single entry
        bool isActive;
        address[] uniqueRecipients; // List of unique recipients
        mapping(address => uint256) recipientEntries; // Number of times a recipient appears
        uint256 totalEntries; // Sum of all recipient entries
    }

    mapping(uint256 => DistributionRound) public rounds;
    mapping(uint256 => mapping(address => uint256)) public lastClaimed; // Round => recipient => last claim time
    mapping(uint256 => mapping(address => uint256)) public amountClaimed; // Round => recipient => claimed amount

    uint256 public nextRoundId;

    event RoundStarted(
        uint256 indexed roundId,
        address indexed creator,
        address token,
        uint256 totalTokens,
        uint256 minClaimInterval
    );
    event RoundEnded(uint256 indexed roundId);
    event TokensClaimed(
        uint256 indexed roundId,
        address indexed recipient,
        uint256 amount,
        bool isERC20
    );
    event ClaimIntervalUpdated(uint256 indexed roundId, uint256 interval);

    modifier roundActive(uint256 roundId) {
        require(rounds[roundId].isActive, "Round is not active");
        _;
    }

    /**
     * @notice Creates a new distribution round with a fixed token supply and recipient list.
     * @param token The ERC20 token address (zero address for native asset).
     * @param recipients The list of recipients for this round (can include duplicates).
     * @param minClaimInterval Minimum time between claims for this round.
     * @param totalTokens The fixed number of tokens to distribute.
     */
    function startNewRound(
        address token,
        address[] calldata recipients,
        uint256 minClaimInterval,
        uint256 totalTokens,
        uint256 numberOfClaimsRequired
    ) external payable nonReentrant returns (uint256 roundId) {
        require(recipients.length > 0, "Must provide recipients");
        require(minClaimInterval > 0, "Interval must be greater than zero");
        require(
            (msg.value > 0 && token == address(0)) ||
                (token != address(0) && totalTokens > 0),
            "Must provide native or ERC20 tokens"
        );
        require(numberOfClaimsRequired > 0, "Must Be greater than 0");

        // Pull ERC20 tokens immediately if a token is provided
        if (token != address(0)) {
            uint256 balanceBefore = IERC20(token).balanceOf(address(this));
            IERC20(token).transferFrom(msg.sender, address(this), totalTokens);
            require(
                balanceBefore + totalTokens ==
                    IERC20(token).balanceOf(address(this)),
                "Distribution: Tokens did not transfer"
            );
        }

        roundId = nextRoundId++;
        DistributionRound storage round = rounds[roundId];

        round.token = token;
        round.totalTokens = totalTokens;
        round.remainingTokens = totalTokens;
        round.minClaimInterval = minClaimInterval;
        round.totalPerEntryPerClaim =
            totalTokens /
            (recipients.length * numberOfClaimsRequired);
        round.isActive = true;
        round.numberOfClaimsRequired = numberOfClaimsRequired;

        // Process recipient entries (handles duplicates correctly)
        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];

            if (round.recipientEntries[recipient] == 0) {
                round.uniqueRecipients.push(recipient); // Add to unique list
            }

            round.recipientEntries[recipient]++; // Track the number of times they appear
            round.totalEntries++; // Increase total number of entries
        }

        emit RoundStarted(
            roundId,
            msg.sender,
            token,
            totalTokens,
            minClaimInterval
        );
    }

    /**
     * @notice Automatically ends a round if tokens are fully distributed.
     * @param roundId The round ID to check.
     */
    function _endRoundIfNeeded(uint256 roundId) internal {
        if (rounds[roundId].remainingTokens == 0) {
            rounds[roundId].isActive = false;
            emit RoundEnded(roundId);
        }
    }

    /**
     * @notice Allows individual recipients to claim their allocated tokens or allows others to do it for them.
     * @param roundId The round from which to claim tokens.
     * @param recipeint The individual who is claiming
     */
    function claimTokens(
        uint256 roundId,
        address recipeint
    ) external nonReentrant roundActive(roundId) {
        DistributionRound storage round = rounds[roundId];

        require(round.recipientEntries[recipeint] > 0, "Not a recipient");
        require(round.remainingTokens > 0, "No tokens left to claim");
        require(
            block.timestamp >=
                lastClaimed[roundId][recipeint] + round.minClaimInterval,
            "Claim interval not met"
        );
        require(
            amountClaimed[roundId][recipeint] <
                round.totalPerEntryPerClaim * round.numberOfClaimsRequired,
            "Distribuition: No tokens left to claim"
        );

        uint256 recipientEntries = round.recipientEntries[recipeint];
        uint256 amountToSend = round.totalPerEntryPerClaim * recipientEntries;

        // Prevent over-distribution
        if (amountToSend > round.remainingTokens) {
            amountToSend = round.remainingTokens;
        }
        //Prevents over-distribution for the individual
        if (
            amountToSend + amountClaimed[roundId][recipeint] >
            round.totalPerEntryPerClaim * round.numberOfClaimsRequired
        ) {
            amountToSend =
                (round.totalPerEntryPerClaim * round.numberOfClaimsRequired) -
                amountClaimed[roundId][recipeint];
        }
        // **Update Claim Status & Remaining Tokens**
        lastClaimed[roundId][recipeint] = block.timestamp;
        round.remainingTokens -= amountToSend;
        amountClaimed[roundId][recipeint] += amountToSend;

        if (round.token == address(0)) {
            (bool success, ) = recipeint.call{value: amountToSend}("");
            require(success, "Native transfer failed");
        } else {
            IERC20(round.token).transfer(recipeint, amountToSend);
        }

        emit TokensClaimed(
            roundId,
            recipeint,
            amountToSend,
            round.token != address(0)
        );

        // Check if the round should be ended
        _endRoundIfNeeded(roundId);
    }

    /**
     * @notice Returns the recipients of a given round.
     * @param roundId The round ID.
     */
    function getRecipients(
        uint256 roundId
    ) external view returns (address[] memory) {
        return rounds[roundId].uniqueRecipients;
    }

    /**
     * @notice Returns the number of times a recipient was included in a round.
     * @param roundId The round ID.
     * @param recipient The recipient's address.
     */
    function getRecipientEntries(
        uint256 roundId,
        address recipient
    ) external view returns (uint256) {
        return rounds[roundId].recipientEntries[recipient];
    }

    /**
     * @notice Returns the amount claimed by a recipient in a round.
     * @param roundId The round ID.
     * @param recipient The recipient's address.
     */
    function getAmountClaimed(
        uint256 roundId,
        address recipient
    ) external view returns (uint256) {
        return amountClaimed[roundId][recipient];
    }
}
