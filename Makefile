.PHONY: clean generate docs test redocs forge interfaces

build: forge generate docs bin/casino bin/technician bin/7702 interfaces

rebuild: clean build

generate: forge bindings/DegenGambit/DegenGambit.go bindings/BlockInspector/BlockInspector.go bindings/TestableDegenGambit/TestableDegenGambit.go bindings/AccountSystem/AccountSystem.go bindings/DegenCasinoAccount/DegenCasinoAccount.go bindings/AccountSystem7702/AccountSystem7702.go

bindings/DegenGambit/DegenGambit.go:
	mkdir -p bindings/DegenGambit
	seer evm generate --package DegenGambit --output bindings/DegenGambit/DegenGambit.go --foundry out/DegenGambit.sol/DegenGambit.json --cli --struct DegenGambit

bindings/BlockInspector/BlockInspector.go:
	mkdir -p bindings/BlockInspector
	seer evm generate --package BlockInspector --output bindings/BlockInspector/BlockInspector.go --foundry out/BlockInspector.sol/BlockInspector.json --cli --struct BlockInspector

bindings/TestableDegenGambit/TestableDegenGambit.go:
	mkdir -p bindings/TestableDegenGambit
	seer evm generate --package TestableDegenGambit --output bindings/TestableDegenGambit/TestableDegenGambit.go --foundry out/TestableDegenGambit.sol/TestableDegenGambit.json --cli --struct TestableDegenGambit

bindings/AccountSystem/AccountSystem.go:
	mkdir -p bindings/AccountSystem
	seer evm generate --package AccountSystem --output bindings/AccountSystem/AccountSystem.go --foundry out/AccountSystem.sol/AccountSystem.json --cli --struct AccountSystem

bindings/AccountSystem7702/AccountSystem7702.go:
	mkdir -p bindings/AccountSystem7702
	seer evm generate --package AccountSystem7702 --output bindings/AccountSystem7702/AccountSystem7702.go --foundry out/AccountSystem7702.sol/AccountSystem7702.json --cli --struct AccountSystem7702

bindings/DegenCasinoAccount/DegenCasinoAccount.go:
	mkdir -p bindings/DegenCasinoAccount
	seer evm generate --package DegenCasinoAccount --output bindings/DegenCasinoAccount/DegenCasinoAccount.go --foundry out/AccountSystem.sol/DegenCasinoAccount.json --cli --struct DegenCasinoAccount

bin/casino: bindings/DegenGambit/DegenGambit.go
	go mod tidy
	go build -o bin/casino ./cmd/casino/

bin/technician: bindings/BlockInspector/BlockInspector.go
	go mod tidy
	go build -o bin/technician ./cmd/technician

bin/7702: bindings/AccountSystem7702/AccountSystem7702.go
	go mod tidy
	go build -o bin/7702 ./cmd/7702/

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

src/interfaces/IAccountSystem7702.sol: out/AccountSystem7702.sol/AccountSystem7702.json
	mkdir -p src/interfaces
	jq .abi out/AccountSystem7702.sol/AccountSystem7702.json | solface -annotations -license MIT -name IAccountSystem7702 -pragma "^0.8.13" >src/interfaces/IAccountSystem7702.sol

out/AccountSystem.sol/AccountSystem.json:
	forge

out/AccountSystem.sol/DegenCasinoAccount.json:
	forge

out/DegenGambit.sol/DegenGambit.json:
	forge

out/AccountSystem7702.sol/AccountSystem7702.json:
	forge
