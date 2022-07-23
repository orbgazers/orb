<script lang="ts">
	import type { Market, OutcomeToken } from '$lib/utils/market.model';

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
		<div class="gray-field d-flex align-content-between">
			<div class="w-100">
				<input type="number" placeholder="0.0" class="text-truncate" />
			</div>

			<div class="d-flex align-items-center">
				<img class="me-1" src="/img/usdc.webp" />
				<span>USDC</span>
				<!-- {#if $connected}
							{#await $signer.getBalance() then balance}
								Balance: {formatEth(balance)}
							{/await}
						{/if} -->
			</div>
		</div>

		<button type="submit" class="btn btn-primary btn-lg w-100">{tradeMode}</button>
	</form>
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

	.gray-field {
		input {
			border: none;
			outline: none;
			background: none;
			font-family: monospace;
			font-size: 24px;
		}

		img {
			height: 18px;
		}
	}
</style>
