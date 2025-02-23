package main

import (
	"crypto/ecdsa"
	"fmt"
	"math/big"
	"os"

	"github.com/ethereum/go-ethereum/accounts/keystore"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/crypto"
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

// Add these helper functions at the end of the file
func encodeAddresses(addresses []common.Address) []byte {
	encoded := make([]byte, len(addresses)*32)
	for i, addr := range addresses {
		copy(encoded[i*32:], common.LeftPadBytes(addr.Bytes(), 32))
	}
	return encoded
}

func encodeBigInts(ints []*big.Int) []byte {
	encoded := make([]byte, len(ints)*32)
	for i, val := range ints {
		copy(encoded[i*32:], common.LeftPadBytes(val.Bytes(), 32))
	}
	return encoded
}
