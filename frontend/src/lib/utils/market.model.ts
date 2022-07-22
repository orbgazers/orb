export interface Market {
  title: string;
  description: string;
  //totalVolume: number; // currency?
  closingDate: Date;
  settlementDate: Date;
  contractAddress: string;
  creator?: ContractInfo;
  arbiter?: ContractInfo;
  outcomeTokens?: string[];
}

export interface ContractInfo {
  address: string;
  // if we have time - lookup name in dictionary
}