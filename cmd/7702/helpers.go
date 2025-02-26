package main

import (
	"context"
	"crypto/ecdsa"
	"encoding/hex"
	"fmt"
	"math/big"
	"os"
	"strings"
	"time"

	"github.com/PermissionlessGames/degen-casino/bindings/AccountSystem7702"
	"github.com/ethereum/go-ethereum/accounts/keystore"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/ethereum/go-ethereum/rlp"
	"golang.org/x/term"
)

// Unlocks a key from a keystore (byte contents of a keystore file) with the given password.
func UnlockKeystore(keystoreData []byte, password string) (*keystore.Key, error) {
	key, err := keystore.DecryptKey(keystoreData, password)
	return key, err
}

// Loads a key from file, prompting the user for the password if it is not provided as a function argument.
func KeyFromFile(keystoreFile string, password string) (*keystore.Key, error) {
	var emptyKey *keystore.Key
	keystoreContent, readErr := os.ReadFile(keystoreFile)
	if readErr != nil {
		return emptyKey, readErr
	}

	// If password is "", prompt user for password.
	if password == "" {
		fmt.Printf("Please provide a password for keystore (%s): ", keystoreFile)
		passwordRaw, inputErr := term.ReadPassword(int(os.Stdin.Fd()))
		if inputErr != nil {
			return emptyKey, fmt.Errorf("error reading password: %s", inputErr.Error())
		}
		fmt.Print("\n")
		password = string(passwordRaw)
	}

	key, err := UnlockKeystore(keystoreContent, password)
	return key, err
}

// EIP712Domain represents the domain separator struct
type EIP712Domain struct {
	Name              string         `json:"name"`
	Version           string         `json:"version"`
	ChainId           *big.Int       `json:"chainId"`
	VerifyingContract common.Address `json:"verifyingContract"`
}

// HashTypedDataV4 implements the same logic as _hashTypedDataV4 in the contract
func HashTypedDataV4(domainSeparator, structHash []byte) []byte {
	return crypto.Keccak256([]byte{0x19, 0x01}, domainSeparator, structHash)
}

func GetDomainSeparator(chainId *big.Int, verifyingContract common.Address) [32]byte {
	// EIP712Domain type hash
	domainTypeHash := crypto.Keccak256([]byte("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"))

	// Hash the name and version
	nameHash := crypto.Keccak256([]byte("AccountSystem7702"))
	versionHash := crypto.Keccak256([]byte("1"))

	// Encode and hash all components
	domainSeparator := crypto.Keccak256(
		append(append(append(append(
			domainTypeHash,
			nameHash...),
			versionHash...),
			common.LeftPadBytes(chainId.Bytes(), 32)...),
			common.LeftPadBytes(verifyingContract.Bytes(), 32)...),
	)

	return [32]byte(domainSeparator)
}

// Add these struct types if not already defined
type Action struct {
	Target        common.Address
	Data          []byte
	Value         *big.Int
	Nonce         *big.Int
	Expiration    *big.Int
	FeeToken      common.Address
	FeeValue      *big.Int
	IsBasisPoints bool
}

// HashAction computes the hash of a game action
func HashAction(action Action) ([32]byte, error) {
	// First get the type hash - ensure we use the exact same string
	typeString := "Action(address target,bytes data,uint256 value,uint256 nonce,uint256 expiration,address feeToken,uint256 feeValue,bool isBasisPoints)"

	// Hash the type string first
	typeHash := crypto.Keccak256([]byte(typeString))

	// Pack the data exactly like abi.encode
	encodedData := make([]byte, 0, 32*9) // Pre-allocate space for 9 32-byte values

	// Pack in exact order as Solidity's abi.encode
	encodedData = append(encodedData, typeHash...)                                                                                             // type hash
	encodedData = append(encodedData, common.LeftPadBytes(action.Target.Bytes(), 32)...)                                                       // target address
	encodedData = append(encodedData, crypto.Keccak256(action.Data)...)                                                                        // keccak256(data)
	encodedData = append(encodedData, common.LeftPadBytes(action.Value.Bytes(), 32)...)                                                        // value
	encodedData = append(encodedData, common.LeftPadBytes(action.Nonce.Bytes(), 32)...)                                                        // nonce
	encodedData = append(encodedData, common.LeftPadBytes(action.Expiration.Bytes(), 32)...)                                                   // expiration
	encodedData = append(encodedData, common.LeftPadBytes(action.FeeToken.Bytes(), 32)...)                                                     // fee token
	encodedData = append(encodedData, common.LeftPadBytes(action.FeeValue.Bytes(), 32)...)                                                     // fee value
	encodedData = append(encodedData, common.LeftPadBytes(big.NewInt(map[bool]int64{true: 1, false: 0}[action.IsBasisPoints]).Bytes(), 32)...) // is basis points

	// Hash the encoded data
	final := crypto.Keccak256(encodedData)

	// Debug output
	fmt.Printf("Components:\n")
	fmt.Printf("Type String: %s\n", typeString)
	fmt.Printf("Type Hash: %x\n", typeHash)
	fmt.Printf("Data being hashed: %x\n", action.Data)
	fmt.Printf("Data Hash: %x\n", crypto.Keccak256(action.Data))
	fmt.Printf("Encoded Length: %d bytes\n", len(encodedData))
	fmt.Printf("Final Hash: %x\n", final)

	return [32]byte(final), nil
}

// SignAction signs an action with the given private key
func SignAction(action Action, privateKey *ecdsa.PrivateKey) ([]byte, error) {
	hash, err := HashAction(action)
	if err != nil {
		return nil, fmt.Errorf("failed to get action hash: %w", err)
	}

	// Sign the hash
	signature, err := crypto.Sign(hash[:], privateKey)
	if err != nil {
		return nil, fmt.Errorf("failed to sign action hash: %w", err)
	}

	// Adjust V value for Ethereum compatibility
	signature[64] += 27

	return signature, nil
}

func SendTxWithAuthorization(client *ethclient.Client, key *keystore.Key, calldata []byte, targetAddress common.Address, authorization string) error {
	fmt.Printf("sending tx with authorization: %s\n", authorization)
	// Get chain ID
	chainID, err := client.ChainID(context.Background())
	if err != nil {
		return fmt.Errorf("failed to get chain ID: %w", err)
	}
	fmt.Printf("chain ID: %s\n", chainID)
	// Get sender's nonce
	nonce, err := client.NonceAt(context.Background(), key.Address, nil)
	if err != nil {
		return fmt.Errorf("failed to get nonce: %w", err)
	}
	fmt.Printf("nonce: %d\n", nonce)

	gasPrice, err := client.SuggestGasPrice(context.Background())
	if err != nil {
		return fmt.Errorf("failed to get gas price: %w", err)
	}
	fmt.Printf("gas price: %s\n", gasPrice)

	gasLimit := uint64(5000000)
	fmt.Printf("gas limit: %d\n", gasLimit)

	authorizationTuple, err := DecodeAuthorization(authorization)
	if err != nil {
		return fmt.Errorf("failed to decode authorization: %w", err)
	}
	fmt.Printf("authorization tuple: %+v\n", authorizationTuple)
	// Create and send the 7702 transaction
	tx := types.NewTx(&AATx{
		AccessListTx: types.AccessListTx{
			ChainID:  chainID,
			Nonce:    nonce,
			GasPrice: gasPrice,
			Gas:      gasLimit,
			To:       &targetAddress,
			Value:    big.NewInt(0),
			Data:     calldata,
		},
		AuthorizationList: []Authorization{authorizationTuple},
	})
	fmt.Printf("created tx %s\n", tx.Hash().Hex())

	fmt.Printf("About to sign tx with chainID: %s\n", chainID)
	fmt.Printf("Signer address: %s\n", key.Address.Hex())

	signer := types.NewEIP2930Signer(chainID)
	fmt.Printf("Created signer\n")

	signedTx, err := types.SignTx(tx, signer, key.PrivateKey)
	if err != nil {
		return fmt.Errorf("failed to sign transaction: %w", err)
	}

	fmt.Printf("signed tx: %s\n", signedTx.Hash().Hex())
	fmt.Printf("About to send transaction\n")

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	fmt.Printf("sending tx\n")

	err = client.SendTransaction(ctx, signedTx)
	if err != nil {
		fmt.Printf("error: %s\n", err)
		return fmt.Errorf("failed to send transaction: %w", err)
	}

	fmt.Printf("Transaction sent: %s\n", signedTx.Hash().Hex())
	return nil
}

// Authorization tuple as specified in EIP-7702
type Authorization struct {
	ChainID *big.Int
	Address common.Address
	Nonce   uint64
	YParity uint8
	R, S    *big.Int
}

// Convert hex string authorization to Authorization struct
func DecodeAuthorization(hexAuth string) (Authorization, error) {
	// Remove "0x" prefix if present
	hexAuth = strings.TrimPrefix(hexAuth, "0x")

	// Decode hex to bytes
	authBytes, err := hex.DecodeString(hexAuth)
	if err != nil {
		return Authorization{}, fmt.Errorf("failed to decode hex: %w", err)
	}

	// Define a struct that matches the RLP encoding format
	var raw struct {
		ChainID *big.Int
		Address []byte
		Nonce   uint64
		YParity uint64
		R       *big.Int
		S       *big.Int
	}

	// Decode RLP into our raw struct
	if err := rlp.DecodeBytes(authBytes, &raw); err != nil {
		return Authorization{}, fmt.Errorf("failed to decode RLP: %w", err)
	}

	// Convert the raw format to our Authorization struct
	auth := Authorization{
		ChainID: raw.ChainID,
		Address: common.BytesToAddress(raw.Address),
		Nonce:   raw.Nonce,
		YParity: uint8(raw.YParity),
		R:       raw.R,
		S:       raw.S,
	}

	return auth, nil
}

func SendAccountSystem7702Tx(client *ethclient.Client, key *keystore.Key, accountAddress, targetAddress common.Address, actionNonce *big.Int, value *big.Int, feeToken common.Address, feeValue *big.Int, isBasisPoints bool, authorization string, calldata []byte) error {
	// Get the spin call data for DegenGambit contract
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
		Data:          calldata,
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
	accountSystemCalldata, err := accountSystemAbi.Pack(
		"execute",
		[]Action{action},
		[][]byte{signedAction},
	)
	if err != nil {
		return fmt.Errorf("failed to pack input: %w", err)
	}

	fmt.Printf("accountSystemCalldata: %s\n", hex.EncodeToString(accountSystemCalldata))

	if authorization != "" {
		fmt.Printf("sending tx with authorization: %s\n", authorization)
		err = SendTxWithAuthorization(client, key, accountSystemCalldata, accountAddress, authorization)
	}

	return nil
}
