// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/libraries/Bitmask.sol";

contract BitmaskWrapper {
    using Bitmask for uint256;

    function encodeBitmask(
        uint256[] memory numbers
    ) external pure returns (uint256) {
        return Bitmask.encodeBitmask(numbers);
    }

    function decodeBitmask(
        uint256 bitmask,
        uint256 maxNumber
    ) external pure returns (uint256[] memory) {
        return Bitmask.decodeBitmask(bitmask, maxNumber);
    }

    function countMatchingBits(
        uint256 bitmask1,
        uint256 bitmask2,
        uint256 maxRange
    ) external pure returns (uint256) {
        return Bitmask.countMatchingBits(bitmask1, bitmask2, maxRange);
    }

    function countMatchingBitsInRange(
        uint256 bitmask1,
        uint256 bitmask2,
        uint256 from,
        uint256 to
    ) external pure returns (uint256) {
        return Bitmask.countMatchingBitsInRange(bitmask1, bitmask2, from, to);
    }

    function decodeBitmaskInRange(
        uint256 bitmask,
        uint256 from,
        uint256 to
    ) external pure returns (uint256[] memory) {
        return Bitmask.decodeBitmaskInRange(bitmask, from, to);
    }
}

contract BitmaskTest is Test {
    BitmaskWrapper public wrapper;

    function setUp() public {
        wrapper = new BitmaskWrapper();
    }

    function testEncode() public view {
        uint256[] memory numbers = new uint256[](3);
        numbers[0] = 0;
        numbers[1] = 3;
        numbers[2] = 5;

        uint256 expectedBitmask = (1 << 0) | (1 << 3) | (1 << 5);
        uint256 actualBitmask = wrapper.encodeBitmask(numbers);

        assertEq(
            actualBitmask,
            expectedBitmask,
            "Bitmask encoding is incorrect"
        );
    }

    function testEncodeShouldRevertWhenBitsAreLargerThen255() public {
        uint256[] memory numbers = new uint256[](1);
        numbers[0] = 256;
        vm.expectRevert(
            abi.encodeWithSelector(Bitmask.NumberOutOfRange.selector, 256)
        );
        wrapper.encodeBitmask(numbers);
    }

    function testEncode256BitsAndDecode() public view {
        uint256[] memory numbers = new uint256[](256);
        for (uint256 i = 0; i < 256; i++) {
            numbers[i] = i;
            assertEq(numbers[i], i, "Number is incorrect");
        }
        uint256 bitmask = wrapper.encodeBitmask(numbers);
        uint256[] memory decodedNumbers = wrapper.decodeBitmask(bitmask, 255);
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
        vm.expectRevert(
            abi.encodeWithSelector(Bitmask.MaxNumberExceedsLimit.selector, 256)
        );
        wrapper.decodeBitmask(bitmask1, 256);
    }

    function testShouldRevertWhenMaxNumberIsLargerThan255CountMatchingBits()
        public
    {
        uint256 bitmask1 = (1 << 25);
        vm.expectRevert(
            abi.encodeWithSelector(Bitmask.RangeExceedsLimit.selector, 256)
        );
        wrapper.countMatchingBits(bitmask1, bitmask1, 256);
    }

    function testDecode() public view {
        uint256 bitmask = (1 << 1) | (1 << 3) | (1 << 4); // Expect [1, 3, 4]
        uint256 maxNumber = 5;

        uint256[] memory decodedNumbers = wrapper.decodeBitmask(
            bitmask,
            maxNumber
        );

        assertEq(decodedNumbers.length, 3, "Decoded array length is incorrect");
        assertEq(decodedNumbers[0], 1, "First decoded number is incorrect");
        assertEq(decodedNumbers[1], 3, "Second decoded number is incorrect");
        assertEq(decodedNumbers[2], 4, "Third decoded number is incorrect");
    }

    function testCountMatchingBits() public view {
        uint256 bitmask1 = (1 << 1) | (1 << 3) | (1 << 5); // [1, 3, 5]
        uint256 bitmask2 = (1 << 1) | (1 << 5) | (1 << 7); // [1, 5, 7]

        uint256 expectedMatches = 2; // Matches at positions 1 and 5
        uint256 actualMatches = wrapper.countMatchingBits(
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

    function testCountMatchingBitsWithZero() public view {
        uint256 bitmask1 = 0; // Empty bitmask
        uint256 bitmask2 = (1 << 1) | (1 << 3) | (1 << 5); // [1, 3, 5]

        uint256 expectedMatches = 0; // No matches since bitmask1 is empty
        uint256 actualMatches = wrapper.countMatchingBits(
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

    function testCountMatchingBitsInRange() public view {
        uint256 bitmask1 = (1 << 1) | (1 << 3) | (1 << 5); // [1, 3, 5]
        uint256 bitmask2 = (1 << 1) | (1 << 5) | (1 << 7); // [1, 5, 7]

        // Test matching bits in range [1, 5]
        uint256 expectedMatches = 2; // Matches at positions 1 and 5
        uint256 actualMatches = wrapper.countMatchingBitsInRange(
            bitmask1,
            bitmask2,
            1,
            5
        );
        assertEq(
            actualMatches,
            expectedMatches,
            "Matching bits count in range [1,5] is incorrect"
        );

        // Test matching bits in range [3, 7]
        expectedMatches = 1; // Only match at position 5
        actualMatches = wrapper.countMatchingBitsInRange(
            bitmask1,
            bitmask2,
            3,
            7
        );
        assertEq(
            actualMatches,
            expectedMatches,
            "Matching bits count in range [3,7] is incorrect"
        );
    }

    function testCountMatchingBitsInRangeWithZero() public view {
        uint256 bitmask1 = 0; // Empty bitmask
        uint256 bitmask2 = (1 << 1) | (1 << 3) | (1 << 5); // [1, 3, 5]

        uint256 expectedMatches = 0; // No matches since bitmask1 is empty
        uint256 actualMatches = wrapper.countMatchingBitsInRange(
            bitmask1,
            bitmask2,
            1,
            5
        );

        assertEq(
            actualMatches,
            expectedMatches,
            "Matching bits count in range is incorrect"
        );
    }

    function testCountMatchingBitsInRangeShouldRevertWhenFromIsLargerThanTo()
        public
    {
        uint256 bitmask1 = (1 << 1) | (1 << 3) | (1 << 5);
        uint256 bitmask2 = (1 << 1) | (1 << 5) | (1 << 7);

        vm.expectRevert(
            abi.encodeWithSelector(
                Bitmask.LowerBitGreaterThanUpperBit.selector,
                5,
                3
            )
        );
        wrapper.countMatchingBitsInRange(bitmask1, bitmask2, 5, 3);
    }

    function testCountMatchingBitsInRangeShouldRevertWhenToExceeds255() public {
        uint256 bitmask1 = (1 << 1) | (1 << 3) | (1 << 5);
        uint256 bitmask2 = (1 << 1) | (1 << 5) | (1 << 7);

        vm.expectRevert(
            abi.encodeWithSelector(Bitmask.RangeExceedsLimit.selector, 256)
        );
        wrapper.countMatchingBitsInRange(bitmask1, bitmask2, 1, 256);
    }

    function testDecodeBitmaskInRange() public view {
        uint256 bitmask = (1 << 1) | (1 << 3) | (1 << 4) | (1 << 6); // [1, 3, 4, 6]

        // Test decoding in range [1, 4]
        uint256[] memory decodedNumbers = wrapper.decodeBitmaskInRange(
            bitmask,
            1,
            4
        );

        assertEq(decodedNumbers.length, 3, "Decoded array length is incorrect");
        assertEq(decodedNumbers[0], 1, "First decoded number is incorrect");
        assertEq(decodedNumbers[1], 3, "Second decoded number is incorrect");
        assertEq(decodedNumbers[2], 4, "Third decoded number is incorrect");

        // Test decoding in range [4, 6]
        decodedNumbers = wrapper.decodeBitmaskInRange(bitmask, 4, 6);
        assertEq(decodedNumbers.length, 2, "Decoded array length is incorrect");
        assertEq(decodedNumbers[0], 4, "First decoded number is incorrect");
        assertEq(decodedNumbers[1], 6, "Second decoded number is incorrect");
    }

    function testDecodeBitmaskInRangeShouldRevertWhenFromIsLargerThanTo()
        public
    {
        uint256 bitmask = (1 << 1) | (1 << 3) | (1 << 4) | (1 << 6);

        vm.expectRevert(
            abi.encodeWithSelector(
                Bitmask.LowerBitGreaterThanUpperBit.selector,
                5,
                3
            )
        );
        wrapper.decodeBitmaskInRange(bitmask, 5, 3);
    }

    function testDecodeBitmaskInRangeShouldRevertWhenToExceeds255() public {
        uint256 bitmask = (1 << 1) | (1 << 3) | (1 << 4) | (1 << 6);

        vm.expectRevert(
            abi.encodeWithSelector(Bitmask.RangeExceedsLimit.selector, 256)
        );
        wrapper.decodeBitmaskInRange(bitmask, 1, 256);
    }

    function testDecodeBitmaskInRangeWithEmptyRange() public view {
        uint256 bitmask = (1 << 1) | (1 << 3) | (1 << 4) | (1 << 6); // [1, 3, 4, 6]

        uint256[] memory decodedNumbers = wrapper.decodeBitmaskInRange(
            bitmask,
            2,
            2
        );

        assertEq(decodedNumbers.length, 0, "Decoded array should be empty");
    }

    function testDecodeBitmaskInRangeWithNoBitsSet() public view {
        uint256 bitmask = 0; // Empty bitmask

        uint256[] memory decodedNumbers = wrapper.decodeBitmaskInRange(
            bitmask,
            1,
            5
        );

        assertEq(decodedNumbers.length, 0, "Decoded array should be empty");
    }
}
