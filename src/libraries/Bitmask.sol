// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library Bitmask {
    /**
     * @notice Encodes an array of numbers into a single bitmask.
     */
    function encode(
        uint256[] memory numbers
    ) internal pure returns (uint256 bitmask) {
        for (uint256 i = 0; i < numbers.length; i++) {
            require(numbers[i] >= 0, "Number out of range");
            bitmask |= (1 << (numbers[i]));
        }
    }

    /**
     * @notice Decodes a bitmask into an array of numbers.
     */
    function decode(
        uint256 bitmask,
        uint256 maxNumber
    ) internal pure returns (uint256[] memory numbers) {
        uint256 count;
        for (uint256 i = 0; i < maxNumber; i++) {
            if ((bitmask & (1 << i)) != 0) {
                count++;
            }
        }

        numbers = new uint256[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < maxNumber; i++) {
            if ((bitmask & (1 << i)) != 0) {
                numbers[index++] = i;
            }
        }
    }

    /**
     * @notice Counts the number of matching bits between two bitmasks.
     */
    function countMatchingBits(
        uint256 bitmask1,
        uint256 bitmask2,
        uint256 maxRange
    ) internal pure returns (uint256) {
        require(maxRange <= 255, "Range exceeds limit"); // Ensure max range is within 255

        uint256 count = 0;
        uint256 diff = bitmask1 & bitmask2; // Identify matching bits

        for (uint8 i = 0; i < maxRange && diff > 0; i++) {
            count += diff & 1; // Count the bit if it's set
            diff >>= 1; // Shift right to check the next bit
        }

        return count;
    }
}
