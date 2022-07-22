<script>
	import ConnectWalletButton from './ConnectWalletButton.svelte';
</script>


<a href="/">
<header class="row p-3 mb-5 border-bottom justify-content-between">
	
		<div class="col-auto d-flex">
			<img src="/favicon.png" alt="Logo" class="logo me-3" />
			<h2 class="fw-bold">The Pondering Orb</h2>
		</div>
	

	<div class="col-auto d-flex justify-content-end">
		<button type="button" class="btn btn-outline-primary me-3">Create a Market</button>
		<ConnectWalletButton />
	</div>
</header>
</a>


<style lang="scss">
	.logo {
		height: 40px;
	}
</style>
