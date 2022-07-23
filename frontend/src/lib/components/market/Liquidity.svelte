<script lang="ts">
	import type { Market, OutcomeToken } from '$lib/utils/market.model';
import TokenInputField from './TokenInputField.svelte';

	export let market: Market;
</script>

<div class="card-fancy">
  <h5 class="text-center">Add Liquidity</h5>
  <TokenInputField></TokenInputField>
  <button type="submit" class="btn btn-primary w-100">Add</button>
</div>