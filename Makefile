.PHONY: clean generate docs test redocs forge interfaces

build: forge generate docs bin/casino bin/technician interfaces

rebuild: clean build

generate: forge bindings/DegenGambit/DegenGambit.go bindings/BlockInspector/BlockInspector.go bindings/TestableDegenGambit/TestableDegenGambit.go

bindings/DegenGambit/DegenGambit.go:
	mkdir -p bindings/DegenGambit
	seer evm generate --package DegenGambit --output bindings/DegenGambit/DegenGambit.go --foundry out/DegenGambit.sol/DegenGambit.json --cli --struct DegenGambit

bindings/BlockInspector/BlockInspector.go:
	mkdir -p bindings/BlockInspector
	seer evm generate --package BlockInspector --output bindings/BlockInspector/BlockInspector.go --foundry out/BlockInspector.sol/BlockInspector.json --cli --struct BlockInspector

bindings/TestableDegenGambit/TestableDegenGambit.go:
	mkdir -p bindings/TestableDegenGambit
	seer evm generate --package TestableDegenGambit --output bindings/TestableDegenGambit/TestableDegenGambit.go --foundry out/TestableDegenGambit.sol/TestableDegenGambit.json --cli --struct TestableDegenGambit

bin/casino: bindings/DegenGambit/DegenGambit.go
	go mod tidy
	go build -o bin/casino ./cmd/casino/

bin/technician: bindings/BlockInspector/BlockInspector.go
	go mod tidy
	go build -o bin/technician ./cmd/technician

test:
	forge test -vvv

clean:
	forge clean
	rm -rf bin/* docs/docgen/* bindings/*

forge:
	forge build

docs:
	forge doc
	mkdir -p docs/abis
	mkdir -p docs/interfaces
	mkdir -p docs/abis/testable
	jq .abi out/DegenGambit.sol/DegenGambit.json >docs/abis/DegenGambit.abi.json
	jq .abi out/TestableDegenGambit.sol/TestableDegenGambit.json >docs/abis/testable/TestableDegenGambit.abi.json

redocs: clean docs

interfaces: src/interfaces/IAccountSystem.sol src/interfaces/IDegenCasinoAccount.sol src/interfaces/IDegenGambit.sol

src/interfaces/IAccountSystem.sol: out/AccountSystem.sol/AccountSystem.json
	mkdir -p src/interfaces
	jq .abi out/AccountSystem.sol/AccountSystem.json | solface -annotations -license MIT -name IAccountSystem -pragma "^0.8.13" >src/interfaces/IAccountSystem.sol

src/interfaces/IDegenCasinoAccount.sol: out/AccountSystem.sol/DegenCasinoAccount.json
	mkdir -p src/interfaces
	jq .abi out/AccountSystem.sol/DegenCasinoAccount.json | solface -annotations -license MIT -name IDegenCasinoAccount -pragma "^0.8.13" >src/interfaces/IDegenCasinoAccount.sol

src/interfaces/IDegenGambit.sol: out/DegenGambit.sol/DegenGambit.json
	mkdir -p src/interfaces
	jq .abi out/DegenGambit.sol/DegenGambit.json | solface -annotations -license MIT -name IDegenGambit -pragma "^0.8.13" >src/interfaces/IDegenGambit.sol

out/AccountSystem.sol/AccountSystem.json:
	forge

out/AccountSystem.sol/DegenCasinoAccount.json:
	forge

out/DegenGambit.sol/DegenGambit.json:
	forge