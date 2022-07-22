<script lang="ts">
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
				<h5>{market.title}</h5>
				<span>{market.description}</span>
				<div class="d-flex justify-content-between">
					<span class="bold">Closing date</span>
					<span>{market.closingDate}</span>
				</div>
			</div>
		</div>
	{/each}
</div>

<style lang="scss">
	.market-card {
		background: white;
		border: 1px solid #dfdfdf;
		border-radius: 10px;
		padding: 20px;
	}
</style>
