<script lang="ts">
	import ConnectWalletButton from './ConnectWalletButton.svelte';
	import { connected } from 'svelte-ethers-store';
</script>

<header class="row p-3 mb-5 border-bottom justify-content-between">
	<div class="col-auto d-flex">
		<a href="/">
			<div class="d-flex">
				<img src="/favicon.png" alt="Logo" class="logo me-3" />
				<h2 class="fw-bold">The Pondering Orb</h2>
			</div>
		</a>
	</div>

	<div class="col-auto d-flex justify-content-end align-items-center">
		{#if $connected}
			<a href="/market/create"
				><button type="button" class="btn btn-outline-primary me-3">Create a Market</button>
			</a>
		{/if}

		<ConnectWalletButton />
	</div>
</header>

<style lang="scss">
	.logo {
		height: 40px;
	}
</style>
