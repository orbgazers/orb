export interface Market {
  id: string,
  title: string;
  description: string;
  //totalVolume: number; // currency?
  closingDate: Date;
  settlementDate: Date;
  creator: string;
  arbiter: string;
  outcomeTokens: OutcomeToken[];
}

export type MarketKey = keyof Market;
export type MarketForm = Record<MarketKey, any>;

export interface ContractInfo {
  address: string;
  // if we have time - lookup name in dictionary
}

export interface OutcomeToken {
  name: string;
  symbol: string;
  price: number;
}

export type OutcomeTokenForm = Record<keyof OutcomeToken, any>