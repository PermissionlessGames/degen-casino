package main

import (
	"bytes"
	"math/big"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/rlp"
)

// AATx implements EIP-7702 transaction type
type AATx struct {
	types.AccessListTx                 // Base transaction fields
	AuthorizationList  []Authorization // List of authorization tuples
}

// copyAddressPtr copies an address.
func copyAddressPtr(a *common.Address) *common.Address {
	if a == nil {
		return nil
	}
	cpy := *a
	return &cpy
}

// Implement all required methods
func (tx *AATx) txType() uint8 { return types.AccessListTxType }
func (tx *AATx) copy() types.TxData {
	cpy := &AATx{
		AccessListTx: types.AccessListTx{
			Nonce: tx.Nonce,
			To:    copyAddressPtr(tx.To),
			Data:  common.CopyBytes(tx.Data),
			Gas:   tx.Gas,
			// These are copied below.
			AccessList: make(types.AccessList, len(tx.AccessList)),
			Value:      new(big.Int),
			ChainID:    new(big.Int),
			GasPrice:   new(big.Int),
			V:          new(big.Int),
			R:          new(big.Int),
			S:          new(big.Int),
		},
		AuthorizationList: make([]Authorization, len(tx.AuthorizationList)),
	}
	copy(cpy.AccessList, tx.AccessList)
	copy(cpy.AuthorizationList, tx.AuthorizationList)
	if tx.Value != nil {
		cpy.Value.Set(tx.Value)
	}
	if tx.ChainID != nil {
		cpy.ChainID.Set(tx.ChainID)
	}
	if tx.GasPrice != nil {
		cpy.GasPrice.Set(tx.GasPrice)
	}
	if tx.V != nil {
		cpy.V.Set(tx.V)
	}
	if tx.R != nil {
		cpy.R.Set(tx.R)
	}
	if tx.S != nil {
		cpy.S.Set(tx.S)
	}
	return cpy
}
func (tx *AATx) accessList() types.AccessList { return tx.AccessListTx.AccessList }
func (tx *AATx) data() []byte                 { return tx.AccessListTx.Data }
func (tx *AATx) gas() uint64                  { return tx.AccessListTx.Gas }
func (tx *AATx) gasFeeCap() *big.Int          { return tx.AccessListTx.GasPrice }
func (tx *AATx) gasTipCap() *big.Int          { return tx.AccessListTx.GasPrice }
func (tx *AATx) value() *big.Int              { return tx.AccessListTx.Value }
func (tx *AATx) nonce() uint64                { return tx.AccessListTx.Nonce }
func (tx *AATx) to() *common.Address          { return tx.AccessListTx.To }
func (tx *AATx) chainId() *big.Int            { return tx.AccessListTx.ChainID }

func (tx *AATx) effectiveGasPrice(dst *big.Int, baseFee *big.Int) *big.Int {
	return dst.Set(tx.GasPrice)
}

func (tx *AATx) rawSignatureValues() (v, r, s *big.Int) {
	return tx.V, tx.R, tx.S
}

func (tx *AATx) setSignatureValues(chainID, v, r, s *big.Int) {
	tx.ChainID, tx.V, tx.R, tx.S = chainID, v, r, s
}

func (tx *AATx) encode(b *bytes.Buffer) error {
	return rlp.Encode(b, tx)
}

func (tx *AATx) decode(input []byte) error {
	return rlp.DecodeBytes(input, tx)
}
