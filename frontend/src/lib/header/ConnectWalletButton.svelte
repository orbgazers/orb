<script lang="ts">
	import { chainData, formatEth, metamaskAvatar } from '$lib/utils/utils';
import { ethers } from 'ethers';
	import { connected, defaultEvmStores, signerAddress, signer, contracts, provider } from 'svelte-ethers-store';
	import truncateEthAddress from 'truncate-eth-address';

	function connectToWallet() {
		defaultEvmStores.setProvider();
	}

	contracts.subscribe(c => console.log(c));
signer.subscribe(c => console.log(c));
provider.subscribe(c => console.log(c));

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
	<div class="d-flex align-items-center">
		<span>
			<!-- {$chainData?.name} -->

			{#await $signer.getBalance() then balance}
				<div class="d-flex align-items-center balance-field px-2">
					<img src="/img/eth.svg" />
					{formatEth(balance)} {$chainData?.nativeCurrency.symbol}
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
