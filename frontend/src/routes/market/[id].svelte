<script lang="ts">
	import { page } from '$app/stores';
	import MarketView from '$lib/components/market/MarketView.svelte';
</script>

<MarketView contractAddress={$page.params.id} />
