<script lang="ts">
	import type { Market, OutcomeToken } from '$lib/utils/market.model';
	import TokenInputField from './TokenInputField.svelte';

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

	let selectedToken: OutcomeToken;
	function selectToken(token: OutcomeToken) {
		selectedToken = token;
		return null;
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
		{#each market.outcomeTokens as token}
			<div
				class="gray-field token smooth-transition d-flex justify-content-between"
				class:selected={selectedToken === token}
				on:click={selectToken(token)}
			>
				<span>{token.name}</span>
				<span>${token.price}</span>
			</div>
		{/each}

		<form>
			<p>Amount</p>
			<TokenInputField />

			<button type="submit" class="btn btn-primary btn-lg w-100">{tradeMode}</button>
		</form>
	</div>
{/if}

<style lang="scss">
	.tabs {
		.btn {
			border-radius: 0;
		}
		.selected {
			border-bottom: 1px solid $primary;
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
