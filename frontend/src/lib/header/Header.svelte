<script>
	import ConnectWalletButton from './ConnectWalletButton.svelte';
</script>

<header class="row p-3 mb-3 border-bottom justify-content-between">
	<div class="col-auto d-flex">
		<img
			src="/favicon.png"
			alt="Logo"
			class="logo me-3"
		/>
		<h2 class="title">The Pondering Orb</h2>
	</div>

	<div class="col-auto d-flex justify-content-end">
		<button type="button" class="btn btn-outline-primary me-3">Create a Market</button>
		<ConnectWalletButton />
	</div>
</header>

<style lang="scss">


	.logo {
		height: 40px;
	}

</style>
