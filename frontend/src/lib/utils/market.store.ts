import { FixedNumber } from "ethers";
import { contracts, defaultEvmStores } from "svelte-ethers-store";
import { get } from "svelte/store";
import type { Market } from "./market.model";

export const markets: Market[] = [];

export function getMarket(id: string): Market {
  return markets.find(market => market.contractAddress === id)!
}

fetch('/abi/Markets.json')
  .then(response => response.json())
  .then(x => console.log(x))

// instantiate contracts
fetch('/abi/deployment.json')
  .then(response => response.json())
  .then(deployment => {
    fetch('/abi/Markets.json')
      .then(response => response.json())
      .then(abi => {
        defaultEvmStores.attachContract('markets', deployment.Markets, abi, true);
      })
  })

// TODO correct type
export async function createMarket(market: Market): Promise<any> {
  // NOTE: only call if `markets` is initialized
  return get(contracts).markets.create([
    // TODO settlement and initialLiquidity
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
  ])
}

// TODO good type
export async function fetchMarkets(): Promise<any> {
    console.log(await get(contracts).markets.numMarkets())
    return Promise.resolve()
}