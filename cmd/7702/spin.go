package main

import (
	"context"
	"encoding/hex"
	"fmt"
	"math/big"

	"github.com/PermissionlessGames/degen-casino/bindings/AccountSystem7702"
	"github.com/PermissionlessGames/degen-casino/bindings/DegenGambit"
	"github.com/ethereum/go-ethereum/accounts/keystore"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/spf13/cobra"
)

func CreateSpinCommand() *cobra.Command {
	var keyfile, password, rpc, targetAddressRaw, accountAddressRaw, actionNonceRaw, valueRaw, feeTokenRaw, feeValueRaw, authorization string
	var targetAddress, accountAddress, feeToken common.Address
	var actionNonce, value, feeValue *big.Int
	var isBasisPoints bool

	delegateCmd := &cobra.Command{
		Use:   "spin",
		Short: "Spin a slot machine",
		PreRunE: func(cmd *cobra.Command, args []string) error {
			if keyfile == "" {
				return fmt.Errorf("--keyfile not specified (this should be a path to an Ethereum account keystore file)")
			}

			if rpc == "" {
				return fmt.Errorf("--rpc not specified (this should be a URL to an Ethereum JSONRPC API)")
			}

			if !common.IsHexAddress(targetAddressRaw) {
				return fmt.Errorf("--target is not a valid Ethereum address")
			}
			targetAddress = common.HexToAddress(targetAddressRaw)

			if !common.IsHexAddress(accountAddressRaw) {
				return fmt.Errorf("--account is not a valid Ethereum address")
			}
			accountAddress = common.HexToAddress(accountAddressRaw)

			if actionNonceRaw != "" {
				var ok bool
				actionNonce, ok = big.NewInt(0).SetString(actionNonceRaw, 10)
				if !ok {
					return fmt.Errorf("--action-nonce is not a valid big integer")
				}
			}

			if valueRaw != "" {
				var ok bool
				value, ok = big.NewInt(0).SetString(valueRaw, 10)
				if !ok {
					return fmt.Errorf("--value is not a valid big integer")
				}
			}

			if !common.IsHexAddress(feeTokenRaw) {
				return fmt.Errorf("--fee-token is not a valid Ethereum address")
			}
			feeToken = common.HexToAddress(feeTokenRaw)

			if feeValueRaw != "" {
				var ok bool
				feeValue, ok = big.NewInt(0).SetString(feeValueRaw, 10)
				if !ok {
					return fmt.Errorf("--fee-value is not a valid big integer")
				}
			}

			return nil
		},
		RunE: func(cmd *cobra.Command, args []string) error {

			key, keyErr := KeyFromFile(keyfile, password)
			if keyErr != nil {
				return fmt.Errorf("Failed to load key: %v", keyErr)
			}

			fmt.Printf("rpc: %s\n", rpc)
			client, err := ethclient.DialContext(context.Background(), rpc)
			if err != nil {
				return fmt.Errorf("failed to connect to RPC: %w", err)
			}

			return Spin(client, key, accountAddress, targetAddress, actionNonce, value, feeToken, feeValue, isBasisPoints, authorization)
		},
	}

	delegateCmd.Flags().StringVar(&keyfile, "keyfile", "", "The keyfile to use to sign the transaction")
	delegateCmd.Flags().StringVar(&password, "password", "", "The password to use to sign the transaction")
	delegateCmd.Flags().StringVar(&rpc, "rpc", "", "The RPC to use to sign the transaction")
	delegateCmd.Flags().StringVar(&targetAddressRaw, "target", "", "The target to use to sign the transaction")
	delegateCmd.Flags().StringVar(&accountAddressRaw, "account", "", "The account to use to sign the transaction")
	delegateCmd.Flags().StringVar(&actionNonceRaw, "action-nonce", "", "The action nonce to use to sign the transaction")
	delegateCmd.Flags().StringVar(&valueRaw, "value", "0", "The value to use to sign the transaction")
	delegateCmd.Flags().StringVar(&feeTokenRaw, "fee-token", "0x0000000000000000000000000000000000000000", "The fee token to use to sign the transaction")
	delegateCmd.Flags().StringVar(&feeValueRaw, "fee-value", "0", "The fee value to use to sign the transaction")
	delegateCmd.Flags().BoolVar(&isBasisPoints, "is-basis-points", false, "Whether the fee value is a basis point")
	delegateCmd.Flags().StringVar(&authorization, "authorization", "", "The authorization to use to sign the transaction")

	return delegateCmd
}

func Spin(client *ethclient.Client, key *keystore.Key, accountAddress, targetAddress common.Address, actionNonce *big.Int, value *big.Int, feeToken common.Address, feeValue *big.Int, isBasisPoints bool, authorization string) error {
	// Get the spin call data for DegenGambit contract
	spinCallData, err := GetSpinCallData(true)
	if err != nil {
		return fmt.Errorf("failed to get spin call data: %w", err)
	}

	if actionNonce == nil {
		accountSystem, err := AccountSystem7702.NewAccountSystem7702(accountAddress, client)
		if err != nil {
			return fmt.Errorf("failed to get AccountSystem7702 contract: %w", err)
		}

		actionNonce, err = accountSystem.Nonce(nil)
		if err != nil {
			return fmt.Errorf("failed to get nonce: %w", err)
		}

		actionNonce = actionNonce.Add(actionNonce, big.NewInt(1))
	}

	action := Action{
		Target:        targetAddress, // DegenGambit contract address
		Data:          common.FromHex(spinCallData),
		Value:         value,         // Amount to send for spinning
		Nonce:         actionNonce,   // Nonce for the action
		Expiration:    big.NewInt(0), // No expiration
		FeeToken:      feeToken,
		FeeValue:      feeValue,
		IsBasisPoints: isBasisPoints,
	}

	// Get the ABI for AccountSystem7702
	accountSystemAbi, err := AccountSystem7702.AccountSystem7702MetaData.GetAbi()
	if err != nil {
		return fmt.Errorf("failed to get AccountSystem7702 ABI: %w", err)
	}

	signedAction, err := SignAction(action, key.PrivateKey)
	if err != nil {
		return fmt.Errorf("failed to sign action: %w", err)
	}

	fmt.Printf("signedAction: %s\n", hex.EncodeToString(signedAction))

	fmt.Printf("action: %+v\n", action)

	// Pack the execute function call with the action and authorization
	calldata, err := accountSystemAbi.Pack(
		"execute",
		[]Action{action},
		[][]byte{signedAction},
	)
	if err != nil {
		return fmt.Errorf("failed to pack input: %w", err)
	}

	fmt.Printf("calldata: %s\n", hex.EncodeToString(calldata))

	if authorization != "" {
		fmt.Printf("sending tx with authorization: %s\n", authorization)
		err = SendTxWithAuthorization(client, key, calldata, accountAddress, authorization)
	}

	return nil
}

func GetSpinCallData(boost bool) (string, error) {
	abi, err := DegenGambit.DegenGambitMetaData.GetAbi()
	if err != nil {
		return "", fmt.Errorf("failed to get ABI: %v", err)
	}

	// Generate transaction data (override method name if safe function is specified)
	methodName := "spin"
	txCalldata, err := abi.Pack(
		methodName,
		boost,
	)

	if err != nil {
		return "", err
	}

	return hex.EncodeToString(txCalldata), nil
}
