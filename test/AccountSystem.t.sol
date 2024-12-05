// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "../lib/openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {ArbSysMock} from "./DegenGambit.t.sol";
import {DegenCasinoAccount, AccountSystem, Action, ExecutorTerms, AccountVersion, AccountSystemVersion} from "../src/AccountSystem.sol";
import {TestableDegenGambit} from "../src/testable/TestableDegenGambit.sol";

contract AccountSystemTest is Test {
    uint256 deployerPrivateKey = 0x42;
    address deployer = vm.addr(deployerPrivateKey);

    uint256 player1PrivateKey = 0x13371;
    address player1 = vm.addr(player1PrivateKey);

    uint256 player2PrivateKey = 0x14471;
    address player2 = vm.addr(player2PrivateKey);

    uint256 startingBalance = 1e21;

    AccountSystem accountSystem;
    TestableDegenGambit game;

    function setUp() public {
        vm.startPrank(deployer);
        accountSystem = new AccountSystem();
        game = new TestableDegenGambit(1, 1, 1);
        vm.stopPrank();

        vm.deal(player1, startingBalance);
        vm.deal(player2, startingBalance);

        ArbSysMock arbSys = new ArbSysMock();
        vm.etch(address(100), address(arbSys).code);
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

        game.mintGambit(player1, startingBalance);

        uint256 initialPlayerBalance = game.balanceOf(player1);

        vm.assertEq(game.balanceOf(accountAddress), 0);

        uint256 depositAmount = startingBalance / 10;
        uint256 withdrawalAmount = depositAmount / 2;

        game.transfer(accountAddress, depositAmount);

        vm.assertEq(game.balanceOf(accountAddress), depositAmount);
        vm.assertEq(
            game.balanceOf(player1),
            initialPlayerBalance - depositAmount
        );

        address[] memory tokenAddresses = new address[](1);
        tokenAddresses[0] = address(game);

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = withdrawalAmount;

        account.withdraw(tokenAddresses, amounts);

        vm.assertEq(
            game.balanceOf(accountAddress),
            depositAmount - withdrawalAmount
        );
        vm.assertEq(
            game.balanceOf(player1),
            initialPlayerBalance - depositAmount + withdrawalAmount
        );

        vm.stopPrank();
    }

    function test_withdraw_erc20_token_fails_as_nonplayer() public {
        vm.startPrank(player2);
        (address accountAddress, ) = accountSystem.createAccount(player1);
        DegenCasinoAccount account = accountSystem.accounts(player1);

        game.mintGambit(player2, startingBalance);

        uint256 initialPlayerBalance = game.balanceOf(player2);

        vm.assertEq(game.balanceOf(accountAddress), 0);

        uint256 depositAmount = startingBalance / 10;
        uint256 withdrawalAmount = depositAmount / 2;

        game.transfer(accountAddress, depositAmount);

        vm.assertEq(game.balanceOf(accountAddress), depositAmount);
        vm.assertEq(
            game.balanceOf(player2),
            initialPlayerBalance - depositAmount
        );

        address[] memory tokenAddresses = new address[](1);
        tokenAddresses[0] = address(game);

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = withdrawalAmount;

        vm.expectRevert(DegenCasinoAccount.Unauthorized.selector);
        account.withdraw(tokenAddresses, amounts);

        vm.assertEq(game.balanceOf(accountAddress), depositAmount);
        vm.assertEq(
            game.balanceOf(player2),
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

        game.mintGambit(player1, startingBalance);

        uint256 initialPlayerBalance = game.balanceOf(player1);

        vm.assertEq(game.balanceOf(accountAddress), 0);

        uint256 depositAmount = startingBalance / 10;

        game.transfer(accountAddress, depositAmount);

        vm.assertEq(game.balanceOf(accountAddress), depositAmount);
        vm.assertEq(
            game.balanceOf(player1),
            initialPlayerBalance - depositAmount
        );

        address[] memory tokenAddresses = new address[](1);
        tokenAddresses[0] = address(game);

        account.drain(tokenAddresses);

        vm.assertEq(game.balanceOf(accountAddress), 0);
        vm.assertEq(game.balanceOf(player1), initialPlayerBalance);

        vm.stopPrank();
    }

    function test_drain_erc20_token_fails_as_nonplayer() public {
        vm.startPrank(player2);
        (address accountAddress, ) = accountSystem.createAccount(player1);
        DegenCasinoAccount account = accountSystem.accounts(player1);

        game.mintGambit(player2, startingBalance);

        uint256 initialPlayerBalance = game.balanceOf(player2);

        vm.assertEq(game.balanceOf(accountAddress), 0);

        uint256 depositAmount = startingBalance / 10;

        game.transfer(accountAddress, depositAmount);

        vm.assertEq(game.balanceOf(accountAddress), depositAmount);
        vm.assertEq(
            game.balanceOf(player2),
            initialPlayerBalance - depositAmount
        );

        address[] memory tokenAddresses = new address[](1);
        tokenAddresses[0] = address(game);

        vm.expectRevert(DegenCasinoAccount.Unauthorized.selector);
        account.drain(tokenAddresses);

        vm.assertEq(game.balanceOf(accountAddress), depositAmount);
        vm.assertEq(
            game.balanceOf(player2),
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

        game.mintGambit(player1, startingBalance);

        uint256 initialERC20PlayerBalance = game.balanceOf(player1);

        vm.assertEq(game.balanceOf(accountAddress), 0);

        uint256 erc20DepositAmount = startingBalance / 20;
        uint256 erc20WithdrawalAmount = erc20DepositAmount / 4;

        game.transfer(accountAddress, erc20DepositAmount);

        vm.assertEq(accountAddress.balance, nativeDepositAmount);
        vm.assertEq(
            player1.balance,
            initialNativePlayerBalance - nativeDepositAmount
        );

        vm.assertEq(game.balanceOf(accountAddress), erc20DepositAmount);
        vm.assertEq(
            game.balanceOf(player1),
            initialERC20PlayerBalance - erc20DepositAmount
        );

        address[] memory tokenAddresses = new address[](2);
        tokenAddresses[0] = address(0);
        tokenAddresses[1] = address(game);

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
            game.balanceOf(accountAddress),
            erc20DepositAmount - erc20WithdrawalAmount
        );
        vm.assertEq(
            game.balanceOf(player1),
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

        game.mintGambit(player2, startingBalance);

        uint256 initialERC20PlayerBalance = game.balanceOf(player2);

        vm.assertEq(game.balanceOf(accountAddress), 0);

        uint256 erc20DepositAmount = startingBalance / 20;
        uint256 erc20WithdrawalAmount = erc20DepositAmount / 4;

        game.transfer(accountAddress, erc20DepositAmount);

        vm.assertEq(accountAddress.balance, nativeDepositAmount);
        vm.assertEq(
            player2.balance,
            initialNativePlayerBalance - nativeDepositAmount
        );

        vm.assertEq(game.balanceOf(accountAddress), erc20DepositAmount);
        vm.assertEq(
            game.balanceOf(player2),
            initialERC20PlayerBalance - erc20DepositAmount
        );

        address[] memory tokenAddresses = new address[](2);
        tokenAddresses[0] = address(0);
        tokenAddresses[1] = address(game);

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

        vm.assertEq(game.balanceOf(accountAddress), erc20DepositAmount);
        vm.assertEq(
            game.balanceOf(player2),
            initialERC20PlayerBalance - erc20DepositAmount
        );

        vm.stopPrank();
    }

    function test_drain_batch() public {
        vm.startPrank(player1);
        (address accountAddress, ) = accountSystem.createAccount(player1);
        DegenCasinoAccount account = accountSystem.accounts(player1);

        uint256 initialNativePlayerBalance = player1.balance;

        vm.assertEq(accountAddress.balance, 0);

        uint256 nativeDepositAmount = startingBalance / 10;

        accountAddress.call{value: nativeDepositAmount}("");

        game.mintGambit(player1, startingBalance);

        uint256 initialERC20PlayerBalance = game.balanceOf(player1);

        vm.assertEq(game.balanceOf(accountAddress), 0);

        uint256 erc20DepositAmount = startingBalance / 20;

        game.transfer(accountAddress, erc20DepositAmount);

        vm.assertEq(accountAddress.balance, nativeDepositAmount);
        vm.assertEq(
            player1.balance,
            initialNativePlayerBalance - nativeDepositAmount
        );

        vm.assertEq(game.balanceOf(accountAddress), erc20DepositAmount);
        vm.assertEq(
            game.balanceOf(player1),
            initialERC20PlayerBalance - erc20DepositAmount
        );

        address[] memory tokenAddresses = new address[](2);
        tokenAddresses[0] = address(0);
        tokenAddresses[1] = address(game);

        account.drain(tokenAddresses);

        vm.assertEq(accountAddress.balance, 0);
        vm.assertEq(player1.balance, initialNativePlayerBalance);

        vm.assertEq(game.balanceOf(accountAddress), 0);
        vm.assertEq(game.balanceOf(player1), initialERC20PlayerBalance);

        vm.stopPrank();
    }

    function test_drain_batch_fail_as_nonplayer() public {
        vm.startPrank(player2);
        (address accountAddress, ) = accountSystem.createAccount(player1);
        DegenCasinoAccount account = accountSystem.accounts(player1);

        uint256 initialNativePlayerBalance = player1.balance;

        vm.assertEq(accountAddress.balance, 0);

        uint256 nativeDepositAmount = startingBalance / 10;

        accountAddress.call{value: nativeDepositAmount}("");

        game.mintGambit(player2, startingBalance);

        uint256 initialERC20PlayerBalance = game.balanceOf(player2);

        vm.assertEq(game.balanceOf(accountAddress), 0);

        uint256 erc20DepositAmount = startingBalance / 20;

        game.transfer(accountAddress, erc20DepositAmount);

        vm.assertEq(accountAddress.balance, nativeDepositAmount);
        vm.assertEq(
            player2.balance,
            initialNativePlayerBalance - nativeDepositAmount
        );

        vm.assertEq(game.balanceOf(accountAddress), erc20DepositAmount);
        vm.assertEq(
            game.balanceOf(player2),
            initialERC20PlayerBalance - erc20DepositAmount
        );

        address[] memory tokenAddresses = new address[](2);
        tokenAddresses[0] = address(0);
        tokenAddresses[1] = address(game);

        vm.expectRevert(DegenCasinoAccount.Unauthorized.selector);
        account.drain(tokenAddresses);

        vm.assertEq(accountAddress.balance, nativeDepositAmount);
        vm.assertEq(
            player2.balance,
            initialNativePlayerBalance - nativeDepositAmount
        );

        vm.assertEq(game.balanceOf(accountAddress), erc20DepositAmount);
        vm.assertEq(
            game.balanceOf(player2),
            initialERC20PlayerBalance - erc20DepositAmount
        );

        vm.stopPrank();
    }

    function _signAction(
        address accountAddress,
        Action memory action,
        uint256 signerKey
    ) internal view returns (bytes memory) {
        DegenCasinoAccount account = DegenCasinoAccount(
            payable(accountAddress)
        );
        bytes32 actionHash = account.actionHash(action);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerKey, actionHash);
        return abi.encodePacked(r, s, v);
    }

    function _signTerms(
        address accountAddress,
        ExecutorTerms memory terms,
        uint256 signerKey
    ) internal view returns (bytes memory) {
        DegenCasinoAccount account = DegenCasinoAccount(
            payable(accountAddress)
        );
        bytes32 termsHash = account.executorTermsHash(terms);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerKey, termsHash);
        return abi.encodePacked(r, s, v);
    }

    function test_play_with_valid_signatures() public {
        // Create and fund the account
        (address accountAddress, ) = accountSystem.createAccount(player2);
        DegenCasinoAccount account = DegenCasinoAccount(
            payable(accountAddress)
        );

        // Set up the game action
        Action memory action = Action({
            game: address(game),
            data: abi.encodeWithSignature(
                "mintGambit(address,uint256)",
                accountAddress,
                1 ether
            ),
            value: 0,
            request: 1
        });

        // Set up executor terms
        address[] memory rewardTokens = new address[](1);
        rewardTokens[0] = address(game);
        uint16[] memory basisPoints = new uint16[](1);
        basisPoints[0] = 1000; // 10%
        ExecutorTerms memory terms = ExecutorTerms({
            rewardTokens: rewardTokens,
            basisPoints: basisPoints
        });

        // Sign the action and terms
        bytes memory actionSig = _signAction(
            accountAddress,
            action,
            player2PrivateKey
        );
        bytes memory termsSig = _signTerms(
            accountAddress,
            terms,
            player2PrivateKey
        );

        // Execute play
        vm.prank(player1); // player1 is the executor
        account.play(action, terms, actionSig, termsSig);

        // Verify results
        assertEq(account.lastRequest(), 1);
        assertEq(game.balanceOf(accountAddress), 0.9 ether); // 90% of minted amount
        assertEq(game.balanceOf(player1), 0.1 ether); // 10% reward to executor
    }

    function test_play_with_jackpot_win() public {
        // Create and fund the account
        (address accountAddress, ) = accountSystem.createAccount(player2);
        DegenCasinoAccount account = DegenCasinoAccount(
            payable(accountAddress)
        );

        // Fund the account for playing
        vm.deal(accountAddress, 100 * game.CostToSpin());
        vm.deal(address(game), 100 ether); // Ensure game has enough balance

        // First action: spin
        Action memory spinAction = Action({
            game: address(game),
            data: abi.encodeWithSignature("spin(bool)", false),
            value: game.CostToSpin(),
            request: 1
        });

        // Set up executor terms for native token rewards
        address[] memory rewardTokens = new address[](1);
        rewardTokens[0] = address(0); // native token
        uint16[] memory basisPoints = new uint16[](1);
        basisPoints[0] = 1000; // 10%
        ExecutorTerms memory terms = ExecutorTerms({
            rewardTokens: rewardTokens,
            basisPoints: basisPoints
        });

        // Sign and execute spin
        bytes memory spinSig = _signAction(
            accountAddress,
            spinAction,
            player2PrivateKey
        );
        bytes memory termsSig = _signTerms(
            accountAddress,
            terms,
            player2PrivateKey
        );

        vm.prank(player1);
        account.play(spinAction, terms, spinSig, termsSig);

        // Rig the game to win with three 2s
        game.setEntropyFromOutcomes(2, 2, 2, accountAddress, false);

        // Roll forward and accept
        vm.roll(block.number + 1);

        // Second action: accept
        Action memory acceptAction = Action({
            game: address(game),
            data: abi.encodeWithSignature("accept()"),
            value: 0, // No value needed for accept
            request: 2
        });

        // Sign and execute accept
        bytes memory acceptSig = _signAction(
            accountAddress,
            acceptAction,
            player2PrivateKey
        );

        // Record balances before accept
        uint256 executorStartBalance = player1.balance;
        uint256 accountStartBalance = accountAddress.balance;

        vm.prank(player1);
        account.play(acceptAction, terms, acceptSig, termsSig);

        // Verify results
        uint256 expectedPayout = 50 * game.CostToSpin(); // 50x the cost to spin
        uint256 executorFee = expectedPayout / 10; // 10%
        assertEq(
            accountAddress.balance,
            accountStartBalance + expectedPayout - executorFee
        );
        assertEq(player1.balance, executorStartBalance + executorFee);
    }
}
