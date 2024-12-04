// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "../lib/openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {DegenCasinoAccount, AccountSystem, AccountVersion, AccountSystemVersion} from "../src/AccountSystem.sol";
import {TestableDegenGambit} from "../src/testable/TestableDegenGambit.sol";

contract TestableDegenGambitTest is Test {
    uint256 deployerPrivateKey = 0x42;
    address deployer = vm.addr(deployerPrivateKey);

    uint256 player1PrivateKey = 0x13371;
    address player1 = vm.addr(player1PrivateKey);

    uint256 player2PrivateKey = 0x14471;
    address player2 = vm.addr(player2PrivateKey);

    uint256 startingBalance = 1e21;

    AccountSystem accountSystem;
    TestableDegenGambit erc20Contract;

    function setUp() public {
        vm.startPrank(deployer);
        accountSystem = new AccountSystem();
        erc20Contract = new TestableDegenGambit(1, 1, 1);
        vm.stopPrank();

        vm.deal(player1, startingBalance);
        vm.deal(player2, startingBalance);
    }

    function test_deployment() public {
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
        (address accountAddress, ) = accountSystem.createAccount(player1);
        DegenCasinoAccount account = accountSystem.accounts(player1);

        uint256 initialPlayerBalance = player1.balance;

        vm.assertEq(accountAddress.balance, 0);

        uint256 depositAmount = startingBalance / 10;
        uint256 withdrawalAmount = depositAmount / 2;

        accountAddress.call{value: depositAmount}("");

        vm.assertEq(accountAddress.balance, depositAmount);
        vm.assertEq(player1.balance, initialPlayerBalance - depositAmount);

        address[] memory tokenAddresses = new address[](1);
        tokenAddresses[0] = address(0);

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = withdrawalAmount;

        account.withdraw(tokenAddresses, amounts);

        vm.assertEq(accountAddress.balance, depositAmount - withdrawalAmount);
        vm.assertEq(
            player1.balance,
            initialPlayerBalance - depositAmount + withdrawalAmount
        );

        vm.stopPrank();
    }

    function test_withdraw_native_token_fails_as_nonplayer() public {
        vm.startPrank(player2);
        (address accountAddress, ) = accountSystem.createAccount(player1);
        DegenCasinoAccount account = accountSystem.accounts(player1);

        vm.assertEq(accountAddress.balance, 0);

        uint256 depositAmount = startingBalance / 10;
        uint256 withdrawalAmount = depositAmount / 2;

        accountAddress.call{value: depositAmount}("");

        vm.assertEq(accountAddress.balance, depositAmount);

        address[] memory tokenAddresses = new address[](1);
        tokenAddresses[0] = address(0);

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = withdrawalAmount;

        vm.expectRevert(DegenCasinoAccount.Unauthorized.selector);
        account.withdraw(tokenAddresses, amounts);

        vm.assertEq(accountAddress.balance, depositAmount);

        vm.stopPrank();
    }

    function test_withdraw_erc20_token() public {
        vm.startPrank(player1);
        (address accountAddress, ) = accountSystem.createAccount(player1);
        DegenCasinoAccount account = accountSystem.accounts(player1);

        erc20Contract.mintGambit(player1, startingBalance);

        uint256 initialPlayerBalance = erc20Contract.balanceOf(player1);

        vm.assertEq(erc20Contract.balanceOf(accountAddress), 0);

        uint256 depositAmount = startingBalance / 10;
        uint256 withdrawalAmount = depositAmount / 2;

        erc20Contract.transfer(accountAddress, depositAmount);

        vm.assertEq(erc20Contract.balanceOf(accountAddress), depositAmount);
        vm.assertEq(
            erc20Contract.balanceOf(player1),
            initialPlayerBalance - depositAmount
        );

        address[] memory tokenAddresses = new address[](1);
        tokenAddresses[0] = address(erc20Contract);

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = withdrawalAmount;

        account.withdraw(tokenAddresses, amounts);

        vm.assertEq(
            erc20Contract.balanceOf(accountAddress),
            depositAmount - withdrawalAmount
        );
        vm.assertEq(
            erc20Contract.balanceOf(player1),
            initialPlayerBalance - depositAmount + withdrawalAmount
        );

        vm.stopPrank();
    }

    function test_withdraw_erc20_token_fails_as_nonplayer() public {
        vm.startPrank(player2);
        (address accountAddress, ) = accountSystem.createAccount(player1);
        DegenCasinoAccount account = accountSystem.accounts(player1);

        erc20Contract.mintGambit(player2, startingBalance);

        uint256 initialPlayerBalance = erc20Contract.balanceOf(player2);

        vm.assertEq(erc20Contract.balanceOf(accountAddress), 0);

        uint256 depositAmount = startingBalance / 10;
        uint256 withdrawalAmount = depositAmount / 2;

        erc20Contract.transfer(accountAddress, depositAmount);

        vm.assertEq(erc20Contract.balanceOf(accountAddress), depositAmount);
        vm.assertEq(
            erc20Contract.balanceOf(player2),
            initialPlayerBalance - depositAmount
        );

        address[] memory tokenAddresses = new address[](1);
        tokenAddresses[0] = address(erc20Contract);

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = withdrawalAmount;

        vm.expectRevert(DegenCasinoAccount.Unauthorized.selector);
        account.withdraw(tokenAddresses, amounts);

        vm.assertEq(erc20Contract.balanceOf(accountAddress), depositAmount);
        vm.assertEq(
            erc20Contract.balanceOf(player2),
            initialPlayerBalance - depositAmount
        );

        vm.stopPrank();
    }

    function test_drain_native_token() public {
        vm.startPrank(player1);
        (address accountAddress, ) = accountSystem.createAccount(player1);
        DegenCasinoAccount account = accountSystem.accounts(player1);

        uint256 initialPlayerBalance = player1.balance;

        vm.assertEq(accountAddress.balance, 0);

        uint256 depositAmount = startingBalance / 10;

        accountAddress.call{value: depositAmount}("");

        vm.assertEq(accountAddress.balance, depositAmount);
        vm.assertEq(player1.balance, initialPlayerBalance - depositAmount);

        address[] memory tokenAddresses = new address[](1);
        tokenAddresses[0] = address(0);

        account.drain(tokenAddresses);

        vm.assertEq(accountAddress.balance, 0);
        vm.assertEq(player1.balance, initialPlayerBalance);

        vm.stopPrank();
    }

    function test_drain_native_token_fails_as_nonplayer() public {
        vm.startPrank(player2);
        (address accountAddress, ) = accountSystem.createAccount(player1);
        DegenCasinoAccount account = accountSystem.accounts(player1);

        vm.assertEq(accountAddress.balance, 0);

        uint256 depositAmount = startingBalance / 10;

        accountAddress.call{value: depositAmount}("");

        vm.assertEq(accountAddress.balance, depositAmount);

        address[] memory tokenAddresses = new address[](1);
        tokenAddresses[0] = address(0);

        vm.expectRevert(DegenCasinoAccount.Unauthorized.selector);
        account.drain(tokenAddresses);

        vm.assertEq(accountAddress.balance, depositAmount);

        vm.stopPrank();
    }

    function test_drain_erc20_token() public {
        vm.startPrank(player1);
        (address accountAddress, ) = accountSystem.createAccount(player1);
        DegenCasinoAccount account = accountSystem.accounts(player1);

        erc20Contract.mintGambit(player1, startingBalance);

        uint256 initialPlayerBalance = erc20Contract.balanceOf(player1);

        vm.assertEq(erc20Contract.balanceOf(accountAddress), 0);

        uint256 depositAmount = startingBalance / 10;

        erc20Contract.transfer(accountAddress, depositAmount);

        vm.assertEq(erc20Contract.balanceOf(accountAddress), depositAmount);
        vm.assertEq(
            erc20Contract.balanceOf(player1),
            initialPlayerBalance - depositAmount
        );

        address[] memory tokenAddresses = new address[](1);
        tokenAddresses[0] = address(erc20Contract);

        account.drain(tokenAddresses);

        vm.assertEq(erc20Contract.balanceOf(accountAddress), 0);
        vm.assertEq(erc20Contract.balanceOf(player1), initialPlayerBalance);

        vm.stopPrank();
    }

    function test_drain_erc20_token_fails_as_nonplayer() public {
        vm.startPrank(player2);
        (address accountAddress, ) = accountSystem.createAccount(player1);
        DegenCasinoAccount account = accountSystem.accounts(player1);

        erc20Contract.mintGambit(player2, startingBalance);

        uint256 initialPlayerBalance = erc20Contract.balanceOf(player2);

        vm.assertEq(erc20Contract.balanceOf(accountAddress), 0);

        uint256 depositAmount = startingBalance / 10;

        erc20Contract.transfer(accountAddress, depositAmount);

        vm.assertEq(erc20Contract.balanceOf(accountAddress), depositAmount);
        vm.assertEq(
            erc20Contract.balanceOf(player2),
            initialPlayerBalance - depositAmount
        );

        address[] memory tokenAddresses = new address[](1);
        tokenAddresses[0] = address(erc20Contract);

        vm.expectRevert(DegenCasinoAccount.Unauthorized.selector);
        account.drain(tokenAddresses);

        vm.assertEq(erc20Contract.balanceOf(accountAddress), depositAmount);
        vm.assertEq(
            erc20Contract.balanceOf(player2),
            initialPlayerBalance - depositAmount
        );

        vm.stopPrank();
    }

    function test_withdraw_batch() public {
        vm.startPrank(player1);
        (address accountAddress, ) = accountSystem.createAccount(player1);
        DegenCasinoAccount account = accountSystem.accounts(player1);

        uint256 initialNativePlayerBalance = player1.balance;

        vm.assertEq(accountAddress.balance, 0);

        uint256 nativeDepositAmount = startingBalance / 10;
        uint256 nativeWithdrawalAmount = nativeDepositAmount / 2;

        accountAddress.call{value: nativeDepositAmount}("");

        erc20Contract.mintGambit(player1, startingBalance);

        uint256 initialERC20PlayerBalance = erc20Contract.balanceOf(player1);

        vm.assertEq(erc20Contract.balanceOf(accountAddress), 0);

        uint256 erc20DepositAmount = startingBalance / 20;
        uint256 erc20WithdrawalAmount = erc20DepositAmount / 4;

        erc20Contract.transfer(accountAddress, erc20DepositAmount);

        vm.assertEq(accountAddress.balance, nativeDepositAmount);
        vm.assertEq(
            player1.balance,
            initialNativePlayerBalance - nativeDepositAmount
        );

        vm.assertEq(
            erc20Contract.balanceOf(accountAddress),
            erc20DepositAmount
        );
        vm.assertEq(
            erc20Contract.balanceOf(player1),
            initialERC20PlayerBalance - erc20DepositAmount
        );

        address[] memory tokenAddresses = new address[](2);
        tokenAddresses[0] = address(0);
        tokenAddresses[1] = address(erc20Contract);

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = nativeWithdrawalAmount;
        amounts[1] = erc20WithdrawalAmount;

        account.withdraw(tokenAddresses, amounts);

        vm.assertEq(
            accountAddress.balance,
            nativeDepositAmount - nativeWithdrawalAmount
        );
        vm.assertEq(
            player1.balance,
            initialNativePlayerBalance -
                nativeDepositAmount +
                nativeWithdrawalAmount
        );

        vm.assertEq(
            erc20Contract.balanceOf(accountAddress),
            erc20DepositAmount - erc20WithdrawalAmount
        );
        vm.assertEq(
            erc20Contract.balanceOf(player1),
            initialERC20PlayerBalance -
                erc20DepositAmount +
                erc20WithdrawalAmount
        );

        vm.stopPrank();
    }

    function test_withdraw_batch_fail_as_nonplayer() public {
        vm.startPrank(player2);
        (address accountAddress, ) = accountSystem.createAccount(player1);
        DegenCasinoAccount account = accountSystem.accounts(player1);

        uint256 initialNativePlayerBalance = player1.balance;

        vm.assertEq(accountAddress.balance, 0);

        uint256 nativeDepositAmount = startingBalance / 10;
        uint256 nativeWithdrawalAmount = nativeDepositAmount / 2;

        accountAddress.call{value: nativeDepositAmount}("");

        erc20Contract.mintGambit(player2, startingBalance);

        uint256 initialERC20PlayerBalance = erc20Contract.balanceOf(player2);

        vm.assertEq(erc20Contract.balanceOf(accountAddress), 0);

        uint256 erc20DepositAmount = startingBalance / 20;
        uint256 erc20WithdrawalAmount = erc20DepositAmount / 4;

        erc20Contract.transfer(accountAddress, erc20DepositAmount);

        vm.assertEq(accountAddress.balance, nativeDepositAmount);
        vm.assertEq(
            player2.balance,
            initialNativePlayerBalance - nativeDepositAmount
        );

        vm.assertEq(
            erc20Contract.balanceOf(accountAddress),
            erc20DepositAmount
        );
        vm.assertEq(
            erc20Contract.balanceOf(player2),
            initialERC20PlayerBalance - erc20DepositAmount
        );

        address[] memory tokenAddresses = new address[](2);
        tokenAddresses[0] = address(0);
        tokenAddresses[1] = address(erc20Contract);

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = nativeWithdrawalAmount;
        amounts[1] = erc20WithdrawalAmount;

        vm.expectRevert(DegenCasinoAccount.Unauthorized.selector);
        account.withdraw(tokenAddresses, amounts);

        vm.assertEq(accountAddress.balance, nativeDepositAmount);
        vm.assertEq(
            player2.balance,
            initialNativePlayerBalance - nativeDepositAmount
        );

        vm.assertEq(
            erc20Contract.balanceOf(accountAddress),
            erc20DepositAmount
        );
        vm.assertEq(
            erc20Contract.balanceOf(player2),
            initialERC20PlayerBalance - erc20DepositAmount
        );

        vm.stopPrank();
    }
}
