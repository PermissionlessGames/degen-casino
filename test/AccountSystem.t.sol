// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "../lib/openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {Account, AccountSystem, AccountVersion, AccountSystemVersion} from "../src/AccountSystem.sol";
import {TestableDegenGambit} from "../src/testable/TestableDegenGambit.sol";

contract TestableDegenGambitTest is Test {
    uint256 deployerPrivateKey = 0x42;
    address deployer = vm.addr(deployerPrivateKey);

    uint256 player1PrivateKey = 0x13371;
    address player1 = vm.addr(player1PrivateKey);

    uint256 player2PrivateKey = 0x14471;
    address player2 = vm.addr(player2PrivateKey);

    AccountSystem accountSystem;
    IERC20 erc20Contract;

    function setUp() public {
        vm.startPrank(deployer);
        accountSystem = new AccountSystem();
        erc20Contract = new TestableDegenGambit(1, 1, 1);
        vm.stopPrank();
    }

    function test_AccountSystemCreated_event() public {
        vm.startPrank(deployer);
        vm.expectEmit();
        emit AccountSystem.AccountSystemCreated(
            AccountSystemVersion,
            AccountVersion
        );
        new AccountSystem();
        vm.stopPrank();
    }

    function test_account_creation() public {
        address expectedAccountAddress = accountSystem.calculateAccountAddress(
            player1
        );

        address actualAccountAddress = address(accountSystem.accounts(player1));
        vm.assertEq(actualAccountAddress, address(0));

        vm.startPrank(player1);

        vm.expectEmit(address(accountSystem));
        emit AccountSystem.AccountCreated(
            expectedAccountAddress,
            player1,
            AccountVersion
        );
        (address accountAddress, bool created) = accountSystem.createAccount(
            player1
        );

        vm.stopPrank();

        vm.assertEq(expectedAccountAddress, accountAddress);
        vm.assertTrue(created);

        address actualPlayer = accountSystem.accounts(player1).player();
        vm.assertEq(actualPlayer, player1);
    }

    function test_account_creation_is_idempotent() public {
        address expectedAccountAddress = accountSystem.calculateAccountAddress(
            player1
        );

        address actualAccountAddress = address(accountSystem.accounts(player1));
        vm.assertEq(actualAccountAddress, address(0));

        vm.startPrank(player1);

        (address accountAddress, bool created) = accountSystem.createAccount(
            player1
        );

        vm.assertEq(expectedAccountAddress, accountAddress);
        vm.assertTrue(created);

        address actualPlayer = accountSystem.accounts(player1).player();
        vm.assertEq(actualPlayer, player1);

        (accountAddress, created) = accountSystem.createAccount(player1);

        vm.assertEq(expectedAccountAddress, accountAddress);
        vm.assertEq(created, false);

        vm.stopPrank();
    }

    function test_account_creation_is_permissionless() public {
        address expectedAccountAddress = accountSystem.calculateAccountAddress(
            player1
        );

        address actualAccountAddress = address(accountSystem.accounts(player1));
        vm.assertEq(actualAccountAddress, address(0));

        // Even player2 can create an account for player1.
        vm.startPrank(player2);

        vm.expectEmit(address(accountSystem));
        emit AccountSystem.AccountCreated(
            expectedAccountAddress,
            player1,
            AccountVersion
        );
        accountSystem.createAccount(player1);

        vm.stopPrank();

        actualAccountAddress = address(accountSystem.accounts(player1));
        vm.assertEq(expectedAccountAddress, actualAccountAddress);

        address actualPlayer = accountSystem.accounts(player1).player();
        vm.assertEq(actualPlayer, player1);
    }

    function test_withdraw_native_token() public {
        vm.startPrank(player1);
        accountSystem.createAccount(player1);
        vm.stopPrank();
    }
}
