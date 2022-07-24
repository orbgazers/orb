import { BigNumber, FixedNumber } from "ethers";
import { contracts, defaultEvmStores, signerAddress } from "svelte-ethers-store";
import { derived, get, writable, type Readable, type Writable } from "svelte/store";
import type { Market, OutcomeToken } from "./market.model";

export const markets: Writable<Market[]> = writable([]);

export function getMarket(id: string): Readable<Market | undefined> {
  return derived(markets,
    $markets => $markets.find(market => market.id === id)
  )
}

let initialized = false;
// instantiate contracts
export function initContracts() {
  if (initialized) return;
  fetch('/abi/deployment.json')
    .then(response => response.json())
    .then(deployment => {
      fetch('/abi/Markets.json')
        .then(response => response.json())
        .then(abi => {
          defaultEvmStores.attachContract('markets', deployment.Markets, abi, true)
            .then(x => {
              initialized = true;
            })
        })

      fetch('/abi/IERC20.json')
        .then(response => response.json())
        .then(abi => {
          defaultEvmStores.attachContract('backingCoin', deployment.BackingCoin, abi, true);
        });
    })
  
  
}

const unsubscribe = contracts.subscribe(c => {
  if (c.markets) fetchMarkets();
  console.log(c);
  console.log(get(defaultEvmStores.provider));
})

// export async function initContracts() {
//   if (initialized) return;
//   const dR = await fetch('/abi/deployment.json');
//   const deployment = await dR.json()

//   const mA = await fetch('/abi/Markets.json');
//   const marketsAbi = await mA.json();
//   const markets = defaultEvmStores.attachContract('markets', deployment.Markets, marketsAbi, true);
//   console.log(markets);

//   const bcA = await fetch('/abi/IERC20.json');
//   const backingCoinAbi = await bcA.json();
//   const backingCoin = await defaultEvmStores.attachContract('backingCoin', deployment.BackingCoin, backingCoinAbi, true);
//   console.log(backingCoin);

//   initialized = true;

//   return fetchMarkets;
// }

// TODO correct type
export async function createMarket(market: Market) {
  const marketsContract = get(contracts).markets;
  if (!marketsContract) return;

  const backingCoin = get(contracts).backingCoin;
  const transaction = await backingCoin.functions.approve(marketsContract.address, 10000);
  const receipt = await transaction.wait();
  const tx2 = await marketsContract.create([
    // TODO settlement and initialLiquidity
    get(signerAddress),
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
    market.outcomeTokens.map(token =>
    // TODO multiply by 10^18
      FixedNumber.fromString(token.price.toString()))
  ]);
  const r2 = await tx2.wait();

  return r2;
}

export async function fetchMarkets(): Promise<Market[]> {
  const marketResponse = await get(contracts).markets.getMarketList();
  const _markets = marketResponse.map(response => marketResponseToMarket(response.info as MarketResponse));
  markets.set(_markets);
  unsubscribe();
  return _markets;
}

function marketResponseToMarket(response: MarketResponse): Market {
  const outcomeTokens: OutcomeToken[] = [];
  for (let i = 0; i < response.numOutcomes; i++) {
    outcomeTokens.push({
      name: response.outcomeNames[i],
      symbol: response.outcomeSymbols[i],
      price: FixedNumber.fromValue(response.initialPrices[i]).toUnsafeFloat() / 1000000000000000000
    })
  }
  return {
    id: response.id.toHexString(),
    title: response.name,
    description: response.description,
    closingDate: new Date(response.stopTime.toNumber()),
    settlementDate: new Date(response.settlementTime.toNumber()),
    creator: response.owner,
    arbiter: response.arbiter,
    outcomeTokens: outcomeTokens
  }
}

export async function buy(id: number, index: number, amount: BigNumber, buyer: string) {
  const _contracts = get(contracts);
  if (!_contracts) return;

  let tx = await _contracts.backingCoin.functions.approve(_contracts.markets.address, amount);
  await tx.wait();
  tx = await _contracts.markets.buy(id, index, amount, 0, buyer);
  await tx.wait();
}

interface MarketResponse {
  arbiter: string,
  description: string,
  id: BigNumber,
  initialLiquidity: BigNumber,
  initialPrices: BigNumber[],
  name: string,
  numOutcomes: number,
  outcomeNames: string[],
  outcomeSymbols: string[],
  owner: string,
  settlement: string,
  settlementTime: BigNumber,
  stopTime: BigNumber
}