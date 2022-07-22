<script lang="ts">
	import { page } from '$app/stores';
	import Market from '$lib/components/market/Market.svelte';
</script>

<Market contractAddress={$page.params.id} />
