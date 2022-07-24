<script lang="ts">
	import type { Market, OutcomeToken } from '$lib/utils/market.model';
	import TokenInputField from './TokenInputField.svelte';
	import { buy } from "../../utils/market.store";
	import { get } from 'svelte/store';
	import { signerAddress } from 'svelte-ethers-store';
	import {BigNumber, FixedNumber} from "ethers";

	export let market: Market;

	enum TradeMode {
		buy = 'Buy',
		sell = 'Sell'
	}

	let tradeMode: TradeMode = TradeMode.buy;

	function selectTradeMode(mode: TradeMode) {
		tradeMode = mode;
		return null;
	}

	let tradeAmount: number;
	let selectedToken: OutcomeToken;
	let selectedIndex: number;
	function selectToken(token: OutcomeToken, i: number) {
		selectedToken = token;
		selectedIndex = i;
		return null;
	}

	async function submitForm() {
		let idNum = parseInt(market.id)
		console.log("idNum", idNum)
		console.log("index", selectedIndex)
		const fixed = FixedNumber.fromString(selectedToken.price.toString())
		console.log("fixed", fixed)
		const bignum = FixedNumber.from(BigNumber.from(10).pow(18))
		console.log("big guy", bignum)
		const amount = fixed.mulUnsafe(bignum)
		return await buy(idNum, selectedIndex, amount, get(signerAddress));
	}
</script>

{#if market}
	<div class="card-fancy">
		<div class="d-flex tabs">
			<div
				class="btn btn-lg"
				class:selected={tradeMode === TradeMode.buy}
				on:click={selectTradeMode(TradeMode.buy)}
			>
				Buy
			</div>
			<div
				class="btn btn-lg"
				class:selected={tradeMode === TradeMode.sell}
				on:click={selectTradeMode(TradeMode.sell)}
			>
				Sell
			</div>
		</div>
		{#each market.outcomeTokens as token, i}
			<div
				class="gray-field token smooth-transition d-flex justify-content-between"
				class:selected={selectedToken === token}
				on:click={selectToken(token, i)}
			>
				<span>{token.name}</span>
				<span>${token.price}</span>
			</div>
		{/each}

		<form>
			<p>Amount</p>
			<TokenInputField bind:value={tradeAmount} />

			<button type="button" on:click={submitForm} class="btn btn-primary btn-lg w-100">{tradeMode}</button>
		</form>
	</div>
{/if}

<style lang="scss">
	.tabs {
		.btn {
			border-radius: 0;
		}
		.selected {
			border-bottom: 2px solid $primary;
			color: $primary;
		}
	}

	.token {
		cursor: pointer;
		&:hover {
			background-color: #e2e2e2;
		}
		&.selected {
			background-color: $lilac-selected;
		}
	}

	
</style>
