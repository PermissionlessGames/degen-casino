.PHONY: clean generate test docs redocs forge

build: forge generate docs bin/casino

rebuild: clean build

generate: bindings/DegenGambit/DegenGambit.go

bindings/DegenGambit/DegenGambit.go: forge
	mkdir -p bindings/DegenGambit
	seer evm generate --package DegenGambit --output bindings/DegenGambit/DegenGambit.go --foundry out/DegenGambit.sol/DegenGambit.json --cli --struct DegenGambit

bin/casino: bindings/DegenGambit/DegenGambit.go
	go build -o bin/casino ./cmd/casino/

test:
	forge test -vvv

clean:
	rm -rf out/* bin/* docs/*

forge:
	forge build

docs:
	forge doc

redocs: clean docs