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
        uint256 actualBitmask = Bitmask.encodeBitmask(numbers);

        assertEq(
            actualBitmask,
            expectedBitmask,
            "Bitmask encoding is incorrect"
        );
    }

    function testEncodeShouldRevertWhenBitsAreLargerThen255() public {
        //test 255 should pass
        uint256[] memory numbers = new uint256[](1);
        numbers[0] = 255;
        uint256 bitmask = Bitmask.encodeBitmask(numbers);
        assertEq(bitmask, (1 << numbers[0]));
        uint256[] memory decodedNumbers = Bitmask.decodeBitmask(bitmask, 255);
        assertEq(
            decodedNumbers.length,
            1,
            "Bitmask: Decoded array length is incorrect"
        );
        assertEq(
            decodedNumbers[0],
            255,
            "Bitmask: Decoded number is incorrect"
        );
        //test 256 should revert
        numbers[0] = 256;
        vm.expectRevert("Bitmask: Number out of range");
        bitmask = Bitmask.encodeBitmask(numbers);
    }

    function testEncode256BitsAndDecode() public pure {
        uint256[] memory numbers = new uint256[](256);
        for (uint256 i = 0; i < 256; i++) {
            numbers[i] = i;
            assertEq(numbers[i], i, "Number is incorrect");
        }
        uint256 bitmask = Bitmask.encodeBitmask(numbers);
        uint256[] memory decodedNumbers = Bitmask.decodeBitmask(bitmask, 255);
        assertEq(
            decodedNumbers.length,
            numbers.length,
            "Decoded array length is incorrect"
        );
        for (uint256 i = 0; i < decodedNumbers.length; i++) {
            assertEq(decodedNumbers[i], i, "Decoded number is incorrect");
            assertEq(numbers[i], decodedNumbers[i], "Number is incorrect");
        }
    }

    function testShouldRevertWhenMaxNumberIsLargerThan255() public {
        uint256 bitmask1 = (1 << 25);
        vm.expectRevert("Bitmask: Max number exceeds limit");
        Bitmask.decodeBitmask(bitmask1, 256);

        uint256 bitmask2 = (1 << 24);
        vm.expectRevert("Bitmask: Range exceeds limit");
        Bitmask.countMatchingBits(bitmask1, bitmask2, 256);
    }

    function testDecode() public pure {
        uint256 bitmask = (1 << 1) | (1 << 3) | (1 << 4); // Expect [1, 3, 4]
        uint256 maxNumber = 5;

        uint256[] memory decodedNumbers = Bitmask.decodeBitmask(
            bitmask,
            maxNumber
        );

        assertEq(decodedNumbers.length, 3, "Decoded array length is incorrect");
        assertEq(decodedNumbers[0], 1, "First decoded number is incorrect");
        assertEq(decodedNumbers[1], 3, "Second decoded number is incorrect");
        assertEq(decodedNumbers[2], 4, "Third decoded number is incorrect");
    }

    function testCountMatchingBits() public pure {
        uint256 bitmask1 = (1 << 1) | (1 << 3) | (1 << 5); // [1, 3, 5]
        uint256 bitmask2 = (1 << 1) | (1 << 5) | (1 << 7); // [1, 5, 7]

        uint256 expectedMatches = 2; // Matches at positions 1 and 5
        uint256 actualMatches = Bitmask.countMatchingBits(
            bitmask1,
            bitmask2,
            8
        );

        assertEq(
            actualMatches,
            expectedMatches,
            "Matching bits count is incorrect"
        );
    }

    function testCountMatchingBitsWithZero() public pure {
        uint256 bitmask1 = 0; // Empty bitmask
        uint256 bitmask2 = (1 << 1) | (1 << 3) | (1 << 5); // [1, 3, 5]

        uint256 expectedMatches = 0; // No matches since bitmask1 is empty
        uint256 actualMatches = Bitmask.countMatchingBits(
            bitmask1,
            bitmask2,
            8
        );

        assertEq(
            actualMatches,
            expectedMatches,
            "Matching bits count is incorrect"
        );
    }
}
