<script lang="ts">
	import { markets, fetchMarkets } from '$lib/utils/market.store';
	import Time from 'svelte-time';
</script>

<div class="row g-3">
	<button on:click="{fetchMarkets()}">Fetch</button>
	{#each markets as market}
		<div class="col-3">
			<div class="market-card">
				<a href="/market/{market.contractAddress}">
					<h5 class="fw-bold mb-2">{market.title}</h5>
					<p>{market.description}</p>
					<div class="d-flex justify-content-between mb-2">
						<span class="fw-bold">Total Vol.</span>
						<span>$1,000,000</span>
					</div>
					<div class="d-flex justify-content-between mb-3">
						<span class="fw-bold">Closing date</span>
						<Time timestamp={market.closingDate} format="D MMM YYYY hh:mma" />
					</div>

					{#if market.outcomeTokens.length > 0}
						<div class="outcome-tokens mb-3">
							{#each market.outcomeTokens as token}
								<div class="single d-flex justify-content-between">
									<span>{token.name}</span>
									<span>${token.price}</span>
								</div>
							{/each}
						</div>
					{/if}

					<button class="btn btn-outline-primary w-100">Buy token</button>
				</a>
			</div>
		</div>
	{/each}
</div>

<style lang="scss">
	$border: 1px solid #dfdfdf;
	.market-card {
		background: white;
		border: $border;
		border-radius: 10px;
		padding: 20px;

		.outcome-tokens {
			border: $border;
			border-radius: 5px;

			.single {
				padding: 10px;
				&:not(:last-child) {
					border-bottom: $border;
				}
			}
		}
	}
</style>
