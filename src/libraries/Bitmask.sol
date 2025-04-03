// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Bitmask Library
 * @author Permissionless Games
 * @notice This library provides efficient implementations of bitmask functions for use in smart contracts.
 * @dev Encodes and decodes arrays of numbers into and from bitmasks. Also counts the number of matching bits between two bitmasks.
 * @dev MAX RANGE IS 255, since uint256 acts as a bitmask for 256 bit array
 */

library Bitmask {
    /**
     * @notice Encodes an array of numbers into a single bitmask.
     * @dev The numbers must be between 0 and 255.
     * @param numbers The array of numbers to encode.
     * @return bitmask The encoded bitmask.
     */
    function encodeBitmask(
        uint256[] memory numbers
    ) internal pure returns (uint256 bitmask) {
        for (uint256 i = 0; i < numbers.length; i++) {
            require(
                numbers[i] >= 0 && numbers[i] <= 255,
                "Bitmask: Number out of range"
            );
            bitmask |= (1 << (numbers[i]));
        }
    }

    /**
     * @notice Decodes a bitmask into an array of numbers.
     * @dev The max number must be between 0 and 255. Should be the largest number in the array.
     * @param bitmask The bitmask to decode.
     * @param maxNumber The maximum number in the array.
     * @return numbers The decoded array of numbers.
     */
    function decodeBitmask(
        uint256 bitmask,
        uint256 maxNumber
    ) internal pure returns (uint256[] memory numbers) {
        require(maxNumber <= 255, "Bitmask: Max number exceeds limit");
        uint256 count;
        for (uint256 i = 0; i <= maxNumber; i++) {
            if ((bitmask & (1 << i)) != 0) {
                count++;
            }
        }

        numbers = new uint256[](count);
        uint256 index = 0;
        for (uint256 i = 0; i <= maxNumber; i++) {
            if ((bitmask & (1 << i)) != 0) {
                numbers[index++] = i;
            }
        }
    }

    /**
     * @notice Counts the number of matching bits between two bitmasks.
     * @dev The max range must be between 0 and 255.
     * @param bitmask1 The first bitmask.
     * @param bitmask2 The second bitmask.
     * @param maxRange The maximum range to count.
     * @return count The number of matching bits.
     */
    function countMatchingBits(
        uint256 bitmask1,
        uint256 bitmask2,
        uint256 maxRange
    ) internal pure returns (uint256) {
        require(maxRange <= 255, "Bitmask: Range exceeds limit"); // Ensure max range is within 255

        uint256 count = 0;
        uint256 diff = bitmask1 & bitmask2; // Identify matching bits, is a bitmask with only the matching bits

        for (uint8 i = 0; i <= maxRange && diff > 0; i++) {
            count += diff & 1; // Count the bit if it's set
            diff >>= 1; // Shift right to check the next bit
        }

        return count;
    }
}
