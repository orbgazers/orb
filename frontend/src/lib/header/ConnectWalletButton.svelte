<script lang="ts">
	import { fetchMarkets, initContracts } from '$lib/utils/market.store';
	import { chainData, formatEth, metamaskAvatar } from '$lib/utils/utils';
	import { onMount } from 'svelte';
	import { connected, defaultEvmStores, signer } from 'svelte-ethers-store';

	onMount(fetchMarkets);

	function connectToWallet() {
		defaultEvmStores.setProvider();
	}
</script>

{#if !$connected}
	<button type="button" class="btn btn-primary" on:click={connectToWallet}>Connect Wallet</button>
{:else}
	<div class="d-flex align-items-center">
		<span>
			<!-- {$chainData?.name} -->

			{#await $signer.getBalance() then balance}
				<div class="d-flex align-items-center balance-field px-2">
					<img src="/img/eth.svg" />
					{formatEth(balance)}
					{$chainData?.nativeCurrency.symbol}
				</div>
			{/await}

			<!-- ({truncateEthAddress($signerAddress)}) -->

			<!-- {#await $provider.getNetwork() then network} {network.name} {/await} -->
		</span>

		<div
			class="d-flex align-items-center ms-2"
			contenteditable="false"
			bind:innerHTML={$metamaskAvatar}
		/>
	</div>
{/if}

<style lang="scss">
	.balance-field {
		background: #ececec;
		border-radius: 5px;
		height: 36px;
	}
</style>
