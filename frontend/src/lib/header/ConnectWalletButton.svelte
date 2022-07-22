<script lang="ts">
	import { chainData, formatEth, metamaskAvatar } from '$lib/utils/utils';
	import { connected, defaultEvmStores, signerAddress, signer } from 'svelte-ethers-store';
	import truncateEthAddress from 'truncate-eth-address';

	function connectToWallet() {
		defaultEvmStores.setProvider();
	}

	// async function getBalance(): Promise<string | null> {
	// 	if (!$signer) return null;
	// 	const balance = await $signer.getBalance();
	// 	return formatEth(balance);
	// }

	// provider.subscribe((provider) => {
	// 	if (provider)
	// 		provider.getNetwork().then((nw) => {
	// 			console.log(nw);
	// 		});
	// });
</script>

{#if !$connected}
	<button type="button" class="btn btn-primary" on:click={connectToWallet}>Connect Wallet</button>
{:else}
	<div class="d-flex">
		<span>
			{$chainData?.name}

			{#await $signer.getBalance() then balance}
				{formatEth(balance)} {$chainData?.nativeCurrency.symbol}
			{/await}

			({truncateEthAddress($signerAddress)})

			<!-- {#await $provider.getNetwork() then network} {network.name} {/await} -->
		</span>

		<div
			class="d-flex align-items-center"
			contenteditable="false"
			bind:innerHTML={$metamaskAvatar}
		/>
	</div>
{/if}
