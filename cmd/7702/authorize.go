package main

import (
	"context"
	"fmt"
	"math/big"

	"github.com/ethereum/go-ethereum/accounts/keystore"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/common/hexutil"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/ethereum/go-ethereum/rlp"
	"github.com/spf13/cobra"
)

func CreateAuthorizeCommand() *cobra.Command {
	var implementationAddressRaw, delegatorKeyfile, delegatorPassword, rpc string
	var implementationAddress common.Address
	var delegatorKey *keystore.Key

	delegateCmd := &cobra.Command{
		Use:   "authorize",
		Short: "Authorize an implementation to an EIP-7702 account",
		PreRunE: func(cmd *cobra.Command, args []string) error {
			if implementationAddressRaw == "" {
				return fmt.Errorf("--implementation is not a valid Ethereum address")
			}
			implementationAddress = common.HexToAddress(implementationAddressRaw)

			if delegatorKeyfile == "" {
				return fmt.Errorf("--keyfile is not a valid Ethereum account keystore file")
			}

			var err error
			delegatorKey, err = KeyFromFile(delegatorKeyfile, delegatorPassword)
			if err != nil {
				return fmt.Errorf("failed to load key: %w", err)
			}

			if rpc == "" {
				return fmt.Errorf("--rpc is not a valid Ethereum RPC URL")
			}

			return nil
		},
		RunE: func(cmd *cobra.Command, args []string) error {
			client, err := ethclient.Dial(rpc)
			if err != nil {
				return fmt.Errorf("failed to connect to RPC: %w", err)
			}

			return Authorize(client, implementationAddress, delegatorKey)
		},
	}

	delegateCmd.Flags().StringVar(&implementationAddressRaw, "implementation", "", "The implementation to authorize")
	delegateCmd.Flags().StringVar(&delegatorKeyfile, "keyfile", "", "The keyfile to use to delegate implementation")
	delegateCmd.Flags().StringVar(&delegatorPassword, "password", "", "The password to use to delegate implementation")
	delegateCmd.Flags().StringVar(&rpc, "rpc", "", "The RPC to use to delegate implementation")

	return delegateCmd
}

func Authorize(client *ethclient.Client, implementationAddress common.Address, key *keystore.Key) error {
	chainId, err := client.ChainID(context.Background())
	if err != nil {
		return fmt.Errorf("failed to get chain id: %w", err)
	}

	nonce, err := client.NonceAt(context.Background(), key.Address, nil)
	if err != nil {
		return fmt.Errorf("failed to get nonce: %w", err)
	}

	delegateSignature, err := Sign7702Authorization(chainId, implementationAddress, key, nonce)
	if err != nil {
		return fmt.Errorf("failed to sign message: %w", err)
	}

	fmt.Printf("Delegate signature: %s\n", delegateSignature)
	return nil
}

func Sign7702Authorization(chainId *big.Int, contractAddress common.Address, key *keystore.Key, nonce uint64) (string, error) {
	// EIP-7702 specific message format
	// MAGIC (0x05) || rlp([chain_id, address, nonce])

	fmt.Printf("Chain ID: %s\n", chainId)
	fmt.Printf("Contract address: %s\n", contractAddress)
	fmt.Printf("Nonce: %d\n", nonce)

	// Create the authorization tuple
	authTuple := []interface{}{
		chainId,
		contractAddress,
		nonce,
	}

	// RLP encode the authorization tuple
	encodedData, err := rlp.EncodeToBytes(authTuple)
	if err != nil {
		return "", fmt.Errorf("failed to RLP encode authorization: %w", err)
	}

	// Prepend MAGIC (0x05) to the encoded data
	magicByte := []byte{0x05}
	msgToSign := crypto.Keccak256(append(magicByte, encodedData...))

	// Sign according to EIP-2
	signature, err := crypto.Sign(msgToSign, key.PrivateKey)
	if err != nil {
		return "", fmt.Errorf("failed to sign message: %w", err)
	}

	// Extract v, r, s from signature
	r := new(big.Int).SetBytes(signature[:32])
	s := new(big.Int).SetBytes(signature[32:64])
	v := signature[64]

	// Create the authorization tuple with signature components
	finalAuthTuple := []interface{}{
		chainId,
		contractAddress,
		nonce,
		v, // y_parity
		r, // r
		s, // s
	}

	// RLP encode the final authorization tuple
	finalEncoded, err := rlp.EncodeToBytes(finalAuthTuple)
	if err != nil {
		return "", fmt.Errorf("failed to RLP encode final authorization: %w", err)
	}

	return hexutil.Encode(finalEncoded), nil
}
