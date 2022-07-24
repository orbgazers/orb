<script lang="ts">
	import { markets } from '$lib/utils/market.store';
	import Time from 'svelte-time';

</script>

<div class="cover-image">
	<span class="header-text">A market for predictions, bets, options and all matters of promises</span>
</div>

<div class="row g-3">
	{#each $markets as market}
		<div class="col-3">
			<div class="market-card">
				<a href="/market/{market.id}">
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
	.cover-image {
		border: 1px solid #6F27F5;
		border-radius: 20px;
		border-width: 2px;
		height: 240px;
		padding: 40px;
		font-size: 40px;
		line-height: 48px;
		font-weight: bold;
		margin-bottom: 40px;
		background-image: url(/img/header-image.png);
		background-size:100% 100%;

		.header-text{
			position: absolute;
			width: 532px;
			font-family: SFProDisplay-Bold;
		}

	}
</style>
