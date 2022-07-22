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