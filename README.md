# The Pondering Orb

## Installation

Tooling required:

- Make
- [Foundry](https://github.com/foundry-rs/foundry#installation)
- [Node.js and pnpm](https://pnpm.io/installation)

## Commands

- `make setup` - initialize libraries and node packages
- `make build` - build your project
- `make abi` - generate contract ABI JSON files
- `make clean` - remove compiled files
- `make nuke` - remove all untracked files (including compiled files)
- `make lintcheck` - check files are properly linted
- `make lint` - lint files
- `make test` - run tests
- `make testgas` - run tests and show gas report
- `make watch` - re-run tests whenever files change
- `make deploy-local` - deploy contracts locally for testing
    - before, run `cp .env.example .env` then `anvil` (in a separate terminal)

## Credits

- [ZuniswapV2](https://github.com/Jeiwan/zuniswapv2) for a foundry-tested,
  Solidity 0.8.x compatible UniswapV2 implementation.
