import { ethers } from "ethers";
import { allChainsData, chainId, type ChainData, signerAddress } from "svelte-ethers-store";
import { derived, type Readable } from "svelte/store";
// @ts-ignore: Unreachable code error
import jazzicon from "@metamask/jazzicon";

export const chainData: Readable<ChainData | undefined> = derived(
  chainId,
  $chainId => {
    return allChainsData.find(chain => chain.chainId === $chainId);
  }
);

export function formatEth(number: ethers.BigNumberish) {
  return parseFloat(ethers.utils.formatEther(number)).toFixed(2);
};


export const metamaskAvatar: Readable<string> = derived(
  signerAddress,
  $signerAddress => {
    if (!$signerAddress) return '';
    const av: HTMLDivElement = jazzicon(36, parseInt($signerAddress.slice(2, 10), 16));
    // TODO: wtf, figure this out later
    av.getElementsByTagName('svg').item(0)?.setAttribute('style', 'margin-bottom: 50%;');
    return av.outerHTML;
  }
)

export function toOrdinalSuffix(i: number): string {
  var j = i % 10,
    k = i % 100;
  if (j == 1 && k != 11) {
    return i + "st";
  }
  if (j == 2 && k != 12) {
    return i + "nd";
  }
  if (j == 3 && k != 13) {
    return i + "rd";
  }
  return i + "th";
}






