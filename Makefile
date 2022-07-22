# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

setup: libs deps
.PHONY: setup

libs:
	git submodule update --init --recursive
.PHONY: libs

deps:
	pnpm install --frozen-lockfile
.PHONY: deps

build:
	forge build
.PHONY: build

clean:
	forge clean
.PHONY: clean

nuke: clean
	git clean -Xdf
.PHONY: nuke

PRETTIER := pnpm exec prettier --check "src/**/*.sol"
SOLHINT  := pnpm exec solhint --config ./.solhint.json "src/**/*.sol"

lintcheck:
	$(PRETTIER)
	$(SOLHINT)
.PHONY: lintcheck

lint:
	$(PRETTIER) --write
	$(SOLHINT) --fix
.PHONY: lint

test:
	forge test
.PHONY: test

testgas:
	forge test --gas-report
.PHONY: testgas

testfork:
	forge test --fork-url $(ETH_NODE)
.PHONY: testfork

watch:
	forge test --watch src/
.PHONY: watch

# TODO does it need the extra :Deploy ?
deploy-local:
	forge script src/deploy/Deploy.s.sol:DeployLocal \
		--fork-url http://localhost:8545 \
		--private-key $(PRIVATE_KEY0) \
		--broadcast
.PHONY: deploy-local

# To initialize a fresh git repo from the contents.
init:
	git init .
	git commit --allow-empty -m "initial empty commit"
	rm -f .gitmodules
	rm -rf lib
	git submodule add git@github.com:foundry-rs/forge-std.git lib/forge-std
	git submodule add git@github.com:OpenZeppelin/openzeppelin-contracts.git lib/openzeppelin
	git submodule add git@github.com:Rari-Capital/solmate.git lib/solmate
.PHONY: init
