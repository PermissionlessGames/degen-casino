.PHONY: clean generate test docs redocs forge

build: forge generate docs bin/casino

rebuild: clean build

generate: forge bindings/DegenGambit/DegenGambit.go

bindings/DegenGambit/DegenGambit.go:
	mkdir -p bindings/DegenGambit
	seer evm generate --package DegenGambit --output bindings/DegenGambit/DegenGambit.go --foundry out/DegenGambit.sol/DegenGambit.json --cli --struct DegenGambit

bin/casino: bindings/DegenGambit/DegenGambit.go
	go mod tidy
	go build -o bin/casino ./cmd/casino/

test:
	forge test -vvv

clean:
	rm -rf out/* bin/* docs/docgen/* bindings/*

forge:
	forge build

docs:
	forge doc
	mkdir -p docs/abis
	mkdir -p docs/interfaces
	jq .abi out/DegenGambit.sol/DegenGambit.json >docs/abis/DegenGambit.abi.json
	jq . docs/abis/DegenGambit.abi.json | solface -annotations -license MIT -name IDegenGambit -pragma "^0.8.13" >docs/interfaces/IDegenGambit.sol

redocs: clean docs
