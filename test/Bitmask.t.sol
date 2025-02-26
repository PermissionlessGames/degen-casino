// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/libraries/Bitmask.sol"; // Adjust the path if necessary

contract BitmaskTest is Test {
    function testEncode() public pure {
        uint256[] memory numbers = new uint256[](3);
        numbers[0] = 0;
        numbers[1] = 3;
        numbers[2] = 5;

        uint256 expectedBitmask = (1 << 0) | (1 << 3) | (1 << 5);
        uint256 actualBitmask = Bitmask.encode(numbers);

        assertEq(
            actualBitmask,
            expectedBitmask,
            "Bitmask encoding is incorrect"
        );
    }

    function testDecode() public pure {
        uint256 bitmask = (1 << 1) | (1 << 3) | (1 << 5); // Expect [1, 3, 5]
        uint256 maxNumber = 5;

        uint256[] memory decodedNumbers = Bitmask.decode(bitmask, maxNumber);

        assertEq(decodedNumbers.length, 3, "Decoded array length is incorrect");
        assertEq(decodedNumbers[0], 1, "First decoded number is incorrect");
        assertEq(decodedNumbers[1], 3, "Second decoded number is incorrect");
        assertEq(decodedNumbers[2], 5, "Third decoded number is incorrect");
    }

    function testCountMatchingBits() public pure {
        uint256 bitmask1 = (1 << 1) | (1 << 3) | (1 << 5); // [1, 3, 5]
        uint256 bitmask2 = (1 << 1) | (1 << 5) | (1 << 7); // [1, 5, 7]

        uint256 expectedMatches = 2; // Matches at positions 1 and 5
        uint256 actualMatches = Bitmask.countMatchingBits(bitmask1, bitmask2);

        assertEq(
            actualMatches,
            expectedMatches,
            "Matching bits count is incorrect"
        );
    }
}
