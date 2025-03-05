// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/token/ERC20/extensions/MCTOwnership.sol";
import "../src/token/ERC20/interfaces/IMultipleCurrencyToken.sol";
import "../src/dev/mock/MockERC20.sol";
import "../src/dev/mock/MockERC1155.sol";

// Mock implementation of MCTOwnership for testing
contract MockMCTOwnership is MCTOwnership {
    constructor()
        MCTOwnership(
            "Mock MCT",
            "MMCT",
            address(1), // INATIVE address
            1, // adjustmentNumerator
            2, // adjustmentDenominator
            initialPricingData() // Initialize with a single pricing data
        )
    {}

    function initialPricingData()
        internal
        pure
        returns (IMultipleCurrencyToken.CreatePricingDataParams[] memory)
    {
        IMultipleCurrencyToken.CreatePricingDataParams[]
            memory params = new IMultipleCurrencyToken.CreatePricingDataParams[](
                1
            );
        params[0] = IMultipleCurrencyToken.CreatePricingDataParams({
            currency: address(1),
            tokenId: 0,
            is1155: false,
            price: 1e18
        });
        return params;
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract MCTOwnershipTest is Test {
    MockMCTOwnership public mctOwnership;
    IMultipleCurrencyToken public mctInterface;
    MockERC20 public mockERC20;
    MockERC1155 public mockERC1155;
    address public owner;
    address public user;

    event CurrencyAdded(
        address indexed currency,
        uint256 tokenId,
        bool is1155,
        uint256 price
    );

    function setUp() public {
        owner = address(this);
        user = address(0x1);

        mctOwnership = new MockMCTOwnership();
        mctInterface = IMultipleCurrencyToken(address(mctOwnership));
        mockERC20 = new MockERC20("Mock Token", "MTK");
        mockERC1155 = new MockERC1155("Mock 1155");
    }

    function testAddNewPricingData() public {
        IMultipleCurrencyToken.CreatePricingDataParams[]
            memory params = new IMultipleCurrencyToken.CreatePricingDataParams[](
                2
            );

        // Setup ERC20 pricing data
        params[0] = IMultipleCurrencyToken.CreatePricingDataParams({
            currency: address(mockERC20),
            tokenId: 0,
            is1155: false,
            price: 100
        });

        // Setup ERC1155 pricing data
        params[1] = IMultipleCurrencyToken.CreatePricingDataParams({
            currency: address(mockERC1155),
            tokenId: 1,
            is1155: true,
            price: 200
        });

        mctOwnership.addNewPricingData(params);

        // Verify the pricing data was added correctly
        IMultipleCurrencyToken.CreatePricingDataParams
            memory pricingData = mctInterface.tokens(0);
        assertEq(pricingData.currency, address(mockERC20));
        assertEq(pricingData.tokenId, 0);
        assertEq(pricingData.is1155, false);

        pricingData = mctInterface.tokens(1);
        assertEq(pricingData.currency, address(mockERC1155));
        assertEq(pricingData.tokenId, 1);
        assertEq(pricingData.is1155, true);

        // Verify prices are set correctly for both mint and redeem
        bytes memory currencyEncoded = mctInterface.encodeCurrency(
            address(mockERC20),
            0,
            false
        );
        assertEq(mctInterface.getMintPrice(currencyEncoded), 100);
        assertEq(mctInterface.getRedeemPrice(currencyEncoded), 100);

        currencyEncoded = mctInterface.encodeCurrency(
            address(mockERC1155),
            1,
            true
        );
        assertEq(mctInterface.getMintPrice(currencyEncoded), 200);
        assertEq(mctInterface.getRedeemPrice(currencyEncoded), 200);
    }

    function testFailAddExistingPricingData() public {
        IMultipleCurrencyToken.CreatePricingDataParams[]
            memory params = new IMultipleCurrencyToken.CreatePricingDataParams[](
                1
            );
        params[0] = IMultipleCurrencyToken.CreatePricingDataParams({
            currency: address(mockERC20),
            tokenId: 0,
            is1155: false,
            price: 100
        });

        // Add pricing data first time
        mctOwnership.addNewPricingData(params);

        // Try to add same pricing data again - should fail
        vm.expectRevert("Currency already exists");
        mctOwnership.addNewPricingData(params);
    }

    function testFailAddNewPricingDataWithZeroAddress() public {
        IMultipleCurrencyToken.CreatePricingDataParams[]
            memory params = new IMultipleCurrencyToken.CreatePricingDataParams[](
                1
            );
        params[0] = IMultipleCurrencyToken.CreatePricingDataParams({
            currency: address(0),
            tokenId: 0,
            is1155: false,
            price: 100
        });

        vm.expectRevert("Currency cannot be 0 address");
        mctOwnership.addNewPricingData(params);
    }

    function testFailAddNewPricingDataWithZeroPrice() public {
        IMultipleCurrencyToken.CreatePricingDataParams[]
            memory params = new IMultipleCurrencyToken.CreatePricingDataParams[](
                1
            );
        params[0] = IMultipleCurrencyToken.CreatePricingDataParams({
            currency: address(mockERC20),
            tokenId: 0,
            is1155: false,
            price: 0
        });

        vm.expectRevert("Price must be greater than 0");
        mctOwnership.addNewPricingData(params);
    }

    function testAdjustPricingData() public {
        // First add pricing data
        IMultipleCurrencyToken.CreatePricingDataParams[]
            memory params = new IMultipleCurrencyToken.CreatePricingDataParams[](
                1
            );
        params[0] = IMultipleCurrencyToken.CreatePricingDataParams({
            currency: address(mockERC20),
            tokenId: 0,
            is1155: false,
            price: 100
        });
        mctOwnership.addNewPricingData(params);

        // Adjust the price
        mctOwnership.adjustPricingData(0, 200);

        // Verify the price was adjusted for both mint and redeem
        bytes memory currencyEncoded = mctInterface.encodeCurrency(
            address(mockERC20),
            0,
            false
        );
        assertEq(mctInterface.getMintPrice(currencyEncoded), 200);
        assertEq(mctInterface.getRedeemPrice(currencyEncoded), 200);
    }

    function testAdjustAdjustmentFactor() public {
        // Test various adjustment factors
        mctOwnership.adjustAdjustmentFactor(2, 1); // 2:1 ratio

        IMultipleCurrencyToken.CreatePricingDataParams[]
            memory params = new IMultipleCurrencyToken.CreatePricingDataParams[](
                1
            );
        params[0] = IMultipleCurrencyToken.CreatePricingDataParams({
            currency: address(mockERC20),
            tokenId: 0,
            is1155: false,
            price: 100
        });
        mctOwnership.addNewPricingData(params);

        bytes memory currencyEncoded = mctInterface.encodeCurrency(
            address(mockERC20),
            0,
            false
        );
        assertEq(mctInterface.getMintPrice(currencyEncoded), 200); // Should be doubled
        assertEq(mctInterface.getRedeemPrice(currencyEncoded), 200); // Should be doubled
    }

    function testAdjustAdjustmentFactorEdgeCases() public {
        // Test 1:1 ratio
        mctOwnership.adjustAdjustmentFactor(1, 1);

        IMultipleCurrencyToken.CreatePricingDataParams[]
            memory params = new IMultipleCurrencyToken.CreatePricingDataParams[](
                1
            );
        params[0] = IMultipleCurrencyToken.CreatePricingDataParams({
            currency: address(mockERC20),
            tokenId: 0,
            is1155: false,
            price: 100
        });
        mctOwnership.addNewPricingData(params);

        bytes memory currencyEncoded = mctInterface.encodeCurrency(
            address(mockERC20),
            0,
            false
        );
        assertEq(mctInterface.getMintPrice(currencyEncoded), 100); // Should remain same
        assertEq(mctInterface.getRedeemPrice(currencyEncoded), 100);

        // Test large numbers
        mctOwnership.adjustAdjustmentFactor(1000, 1);
        assertEq(mctInterface.getMintPrice(currencyEncoded), 100000);
        assertEq(mctInterface.getRedeemPrice(currencyEncoded), 100000);
    }

    function testRemovePricingData() public {
        // First add pricing data
        IMultipleCurrencyToken.CreatePricingDataParams[]
            memory params = new IMultipleCurrencyToken.CreatePricingDataParams[](
                1
            );
        params[0] = IMultipleCurrencyToken.CreatePricingDataParams({
            currency: address(mockERC20),
            tokenId: 0,
            is1155: false,
            price: 100
        });
        mctOwnership.addNewPricingData(params);

        bytes memory currencyEncoded = mctInterface.encodeCurrency(
            address(mockERC20),
            0,
            false
        );

        // Verify data exists before removal
        assertEq(mctInterface.getMintPrice(currencyEncoded), 100);

        // Remove the pricing data
        mctOwnership.removePricingData(0);

        // Verify the pricing data was removed for both mint and redeem
        vm.expectRevert(); // Should revert when trying to get mint price
        mctInterface.getMintPrice(currencyEncoded);

        vm.expectRevert(); // Should revert when trying to get redeem price
        mctInterface.getRedeemPrice(currencyEncoded);
    }

    function testOnlyOwnerModifiers() public {
        vm.startPrank(user);

        IMultipleCurrencyToken.CreatePricingDataParams[]
            memory params = new IMultipleCurrencyToken.CreatePricingDataParams[](
                1
            );
        params[0] = IMultipleCurrencyToken.CreatePricingDataParams({
            currency: address(mockERC20),
            tokenId: 0,
            is1155: false,
            price: 100
        });

        vm.expectRevert("Ownable: caller is not the owner");
        mctOwnership.addNewPricingData(params);

        vm.expectRevert("Ownable: caller is not the owner");
        mctOwnership.adjustPricingData(0, 200);

        vm.expectRevert("Ownable: caller is not the owner");
        mctOwnership.adjustAdjustmentFactor(2, 1);

        vm.expectRevert("Ownable: caller is not the owner");
        mctOwnership.removePricingData(0);

        vm.stopPrank();
    }
}
