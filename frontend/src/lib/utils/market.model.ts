export interface Market {
  title: string;
  description: string;
  //totalVolume: number; // currency?
  closingDate: Date;
  settlementDate: Date;
  contractAddress: string;
  creator: ContractInfo;
  arbiter: ContractInfo;
  outcomeTokens: OutcomeToken[];
}

export type MarketKey = keyof Market;
export type MarketForm = { [id in MarketKey]: any }

export interface ContractInfo {
  address: string;
  // if we have time - lookup name in dictionary
}

export interface OutcomeToken {
  name: string;
  symbol: string;
  price: number;
}

export type OutcomeTokenForm = {[id in keyof OutcomeToken]: any}