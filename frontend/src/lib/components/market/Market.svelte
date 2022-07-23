<script lang="ts">
	import { getMarket } from '$lib/utils/market.store';
	import Liquidity from './Liquidity.svelte';
	import Trade from './Trade.svelte';
	export let contractAddress: string;

	const market = getMarket(contractAddress);

	enum View {
		trade,
		liquidity
	}

	let view: View = View.trade;

	function setView(_view: View) {
		view = _view;
		return null;
	}
</script>

{#if $market}
	<div class="center">
		<h2 class="text-center">{$market.title}</h2>
		<h4 class="text-center">{$market.description}</h4>
		<div class="el">
			<div class="toggle-group">
				<div
					type="button"
					class="btn btn-lg toggle-btn me-3"
					class:selected={view === View.trade}
					on:click={setView(View.trade)}
				>
					Buy / Sell
				</div>
				<div
					type="button"
					class="btn btn-lg toggle-btn ms-3"
					class:selected={view === View.liquidity}
					on:click={setView(View.liquidity)}
				>
					Liquidity
				</div>
			</div>
		</div>
		<div class="el">
			
				{#if view === View.trade}
					<Trade market={$market} />
				{/if}
				{#if view === View.liquidity}
					<Liquidity market={$market} />
				{/if}
			
		</div>
	</div>
{/if}

<style lang="scss">
	.center {
		.el {
			display: flex;
			justify-content: center;
			margin-top: 2em;

			div {
				width: 488px;
			}
		}
	}

	.toggle-group {
		background: $lilac;
		display: flex;
		padding: 5px;
		border-radius: 50px;

		.toggle-btn.selected {
			background: $lilac-selected;
		}
	}
</style>
