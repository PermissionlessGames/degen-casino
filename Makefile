.PHONY: clean generate test docs redocs forge

build: forge generate docs bin/casino bin/technician bin/test

rebuild: clean build

generate: forge bindings/DegenGambit/DegenGambit.go bindings/BlockInspector/BlockInspector.go bindings/Tests.go

bindings/DegenGambit/DegenGambit.go:
	mkdir -p bindings/DegenGambit
	seer evm generate --package DegenGambit --output bindings/DegenGambit/DegenGambit.go --foundry out/DegenGambit.sol/DegenGambit.json --cli --struct DegenGambit

bindings/BlockInspector/BlockInspector.go:
	mkdir -p bindings/BlockInspector
	seer evm generate --package BlockInspector --output bindings/BlockInspector/BlockInspector.go --foundry out/BlockInspector.sol/BlockInspector.json --cli --struct BlockInspector

bindings/Tests.go:
	mkdir -p bindings/Tests/TestableDegenGambit
	seer evm generate --package TestableDegenGambit --output bindings/Tests/TestableDegenGambit/TestableDegenGambit.go --foundry out/TestableDegenGambit.sol/TestableDegenGambit.json --cli --struct TestableDegenGambit

bin/casino: bindings/DegenGambit/DegenGambit.go
	go mod tidy
	go build -o bin/casino ./cmd/casino/

bin/technician: bindings/BlockInspector/BlockInspector.go
	go mod tidy
	go build -o bin/technician ./cmd/technician

bin/test: bindings/Tests.go
	go mod tidy
	go build -o bin/test ./cmd/test

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
