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
	// EIP-712 domain type hash
	domainTypeHash := crypto.Keccak256([]byte("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"))

	// Pack domain parameters
	name := "AccountSystem7702" // Must match the contract's domain name
	version := "1"              // Must match the contract's domain version

	// Encode the domain separator
	domainSeparator := crypto.Keccak256(
		domainTypeHash,
		crypto.Keccak256([]byte(name)),
		crypto.Keccak256([]byte(version)),
		common.LeftPadBytes(chainId.Bytes(), 32),
		verifyingContract.Bytes(),
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

// HashAction computes the EIP712 hash of a game action
func HashAction(action Action, chainId *big.Int, verifyingContract common.Address) ([32]byte, error) {
	domainSeparator := GetDomainSeparator(chainId, verifyingContract)

	// Define the type hash
	typeHash := crypto.Keccak256([]byte("Action(address target,bytes data,uint256 value,uint256 nonce,uint256 expiration,ExecutorTerms[] executorTerms)ExecutorTerms(address feeToken,uint256 value,bool isBasisPoints)"))

	// Ensure all big.Int fields are initialized
	if action.Value == nil {
		action.Value = big.NewInt(0)
	}
	if action.Expiration == nil {
		action.Expiration = big.NewInt(0)
	}

	// Create the struct hash
	structHash := crypto.Keccak256(
		typeHash,
		action.Target.Bytes(),
		crypto.Keccak256(action.Data),
		common.LeftPadBytes(action.Value.Bytes(), 32),
		common.LeftPadBytes(action.Nonce.Bytes(), 32),
		common.LeftPadBytes(action.Expiration.Bytes(), 32),
		common.LeftPadBytes(action.FeeToken.Bytes(), 32),
		common.LeftPadBytes(action.FeeValue.Bytes(), 32),
		common.LeftPadBytes(big.NewInt(map[bool]int64{true: 1, false: 0}[action.IsBasisPoints]).Bytes(), 32),
	)

	// Compute the final hash using EIP-712
	final := crypto.Keccak256(
		[]byte{0x19, 0x01},
		domainSeparator[:],
		structHash,
	)

	return [32]byte(final), nil
}

// Updated SignActionHash to take Action struct
func SignAction(action Action, chainId *big.Int, contractAddress common.Address, privateKey *ecdsa.PrivateKey) ([]byte, error) {
	structHash, err := HashAction(action, chainId, contractAddress)
	if err != nil {
		return nil, fmt.Errorf("failed to get action hash: %w", err)
	}
	domainSeparator := GetDomainSeparator(chainId, contractAddress)
	hashToSign := HashTypedDataV4(domainSeparator[:], structHash[:])

	// Sign the hash
	signature, err := crypto.Sign(hashToSign, privateKey)
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
