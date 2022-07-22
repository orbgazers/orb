<script lang="ts">
	import Time from 'svelte-time';
	import type { Market } from '$lib/utils/market.model';

	let markets: Market[] = [];

	fetch('/mocks/markets.json')
		.then((response) => response.json())
		.then((data) => {
			console.log(data);
			markets = data;
		})
		.catch((error) => {
			console.log(error);
		});
</script>

<div class="row g-3">
	{#each markets as market}
		<div class="col-3">
			<div class="market-card">
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
