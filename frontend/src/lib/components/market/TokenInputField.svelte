<div class="gray-field d-flex align-content-between">
	<div class="w-100">
		<input type="number" placeholder="0.0" class="text-truncate" />
	</div>

	<div class="d-flex align-items-center">
		<img class="me-1" src="/img/usdc.webp" alt="token logo"/>
		<span>USDC</span>
		<!-- {#if $connected}
							{#await $signer.getBalance() then balance}
								Balance: {formatEth(balance)}
							{/await}
						{/if} -->
	</div>
</div>

<style lang="scss">
  .gray-field {
		input {
			border: none;
			outline: none;
			background: none;
			font-family: monospace;
			font-size: 24px;
		}

		img {
			height: 18px;
		}
	}
</style>
