<script lang="ts">
	import Header from '$lib/header/Header.svelte';
	import '../app.scss';
</script>

<Header />

<main class="container-xxl pb-5">
	<slot />
</main>
