import { Contract, FixedNumber } from "ethers";
import { contracts, defaultEvmStores } from "svelte-ethers-store";
import { derived, writable, type Readable, type Writable } from "svelte/store";
import type { Market } from "./market.model";

export const markets: Writable<Market[]> = writable([]);

fetch('/mocks/markets.json')
  .then((response) => response.json())
  .then((data) => {
    markets.set(data);
  })
  .catch((error) => {
    console.log(error);
  });

export function getMarket(id: string): Readable<Market | undefined> {
  return derived(markets,
    $markets => $markets.find(market => market.contractAddress === id)
  )
}

// export let _signerAddress: string;

// signerAddress.subscribe(address => _signerAddress = address);


fetch('/abi/Markets.json')
  .then((response) => response.json())
  .then(abi => {
    defaultEvmStores.attachContract('markets', '0xa513e6e4b8f2a923d98304ec87f64353c4d5c853', abi, true).then();
  })
  .catch((error) => {
    console.log(error);
  });

export function createMarket(market: Market) {
  console.log(market);
  // TODO settlement and initialLiquidity

  contracts.subscribe(contracts => {
    contracts.markets.create([
      '0x88c17fd2Df5C1BCcA07a391A3B734174063acbdf',
      market.closingDate.valueOf(),
      market.arbiter,
      market.settlementDate.valueOf(),
      '0x0000000000000000000000000000000000000001',
      0,
      market.outcomeTokens.length,
      10000,
      market.title,
      market.description,
      market.outcomeTokens.map(token => token.name),
      market.outcomeTokens.map(token => token.symbol),
      market.outcomeTokens.map(token => FixedNumber.fromString(token.price.toString()))
    ]).then(bla => console.log(bla));
  })
  // let c = contract.create({
  //   owner: market.creator,
  //   stopTime: market.closingDate.valueOf(),
  //   arbiter: market.arbiter,
  //   settlementTime: market.settlementDate.valueOf(),
  //   settlement: '0x0',
  //   id: 0,
  //   numOutcomes: market.outcomeTokens.length,
  //   initialLiquidity: 10000,
  //   name: market.title,
  //   description: market.description,
  //   outcomeNames: market.outcomeTokens.map(token => token.name),
  //   outcomeSymbols: market.outcomeTokens.map(token => token.symbol),
  //   initialPrices: market.outcomeTokens.map(token => token.price)
  // }).then(bla => console.log(bla))

  console.log(c);
}


// {
//     "name": "owner",
//       "type": "address"
// },
// {
//     "name": "stopTime",
//       "type": "uint64"
// },
// {
//     "name": "arbiter",
//       "type": "address"
// },
// {
//     "name": "settlementTime",
//       "type": "uint64"
// },
// {
//     "name": "settlement",
//       "type": "address"
// },
// {
//     "name": "id",
//       "type": "uint64"
// },
// {
//     "name": "numOutcomes",
//       "type": "uint8"
// },
// {
//     "name": "initialLiquidity",
//       "type": "uint256"
// },
// {
//     "name": "name",
//       "type": "string"
// },
// {
//     "name": "description",
//       "type": "string"
// },
// {
//     "name": "outcomeNames",
//       "type": "string[]"
// },
// {
//     "name": "outcomeSymbols",
//       "type": "string[]"
// },
// {
//     "name": "initialPrices",
//       "type": "uint64[]"
// }