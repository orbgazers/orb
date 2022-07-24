<script lang="ts">
	import { createForm } from 'svelte-forms-lib';
	import * as yup from 'yup/lib';
	import { DateInput } from 'date-picker-svelte';
	import { toOrdinalSuffix } from '$lib/utils/utils';
	import type { MarketForm, OutcomeTokenForm } from '$lib/utils/market.model';
	import { createMarket, fetchMarkets, markets } from '$lib/utils/market.store';
	import { get } from 'svelte/store';
	import { signerAddress } from 'svelte-ethers-store';
import { goto } from '$app/navigation';

	const initialToken: OutcomeTokenForm = {
		name: '',
		symbol: '',
		price: null
	};
	const { form, errors, state, handleChange, handleSubmit } = createForm({
		// initialValues: {
		// 	title: '',
		// 	description: '',
		// 	arbiter: get(signerAddress),
		// 	closingDate: null,
		// 	settlementDate: null,
		// 	outcomeTokens: [{ ...initialToken }, { ...initialToken }]
		// } as MarketForm,
		initialValues: {
			id: `0x${get(markets).length}`,
			title: 'Who is gonna win the Hackathon?',
			description: 'Who is gonna win the Hackathon?',
			arbiter: get(signerAddress),
			closingDate: null,
			settlementDate: null,
			outcomeTokens: [{
				name: 'The Pondering Orb',
				symbol: 'ORB',
				price: 0.7
			}, 
			{
				name: 'The Wondering Rob',
				symbol: 'ROB',
				price: 0.1
			}]
		} as MarketForm,
		validationSchema: yup.object().shape({
			title: yup.string().required(),
			description: yup.string().required(),
			arbiter: yup.string().required(),
			closingDate: yup.string().required(),
			settlementDate: yup.string().required(),
			outcomeTokens: yup
				.array(
					yup.object().shape({
						name: yup.string().required(),
						symbol: yup.string().required(),
						price: yup.number().required()
					})
				)
				.min(2)
		} as MarketForm),
		validate: (form) => {
			return (
				(form.outcomeTokens as OutcomeTokenForm[])
					.map((token) => token.price)
					.reduce((a, b) => a + b) === 1
			);
		},
		onSubmit: (values) => {
			submitForm(values);
		}
	});

	async function submitForm(values: MarketForm) {
		// TODO switch to proper id
		const _markets = [...get(markets), values];
		markets.set(_markets);
		// const createPromise = await createMarket(values);
		// const market = await fetchMarkets();
		// console.log(market[market.length - 1]);
		return await goto(`/market/${values.id}`);
	}

	function addToken(_form: MarketForm) {
		_form.outcomeTokens.push({ ...initialToken });
		form.set(_form);
		return null;
	}

	function removeToken(token: OutcomeTokenForm, _form: MarketForm) {
		_form.outcomeTokens = (_form.outcomeTokens as OutcomeTokenForm[]).filter((t) => t !== token);
		form.set(_form);
		return null;
	}
</script>

<h4 class="text-center">Create a prediction market</h4>
<div class="d-flex justify-content-center">
	<form on:submit={handleSubmit} novalidate>
		<p class="label">Title (Question)</p>
		<input
			id="title"
			name="title"
			on:change={handleChange}
			bind:value={$form.title}
			placeholder="Title"
			class:invalid={$errors.title}
		/>

		<p class="label">Description</p>
		<input
			id="description"
			name="description"
			on:change={handleChange}
			bind:value={$form.description}
			placeholder="Description"
			class:invalid={$errors.description}
		/>

		{#each $form.outcomeTokens as token, i}
			<div class="answer">
				<div class="d-flex align-items-center label">
					<span>{toOrdinalSuffix(i + 1)} Answer</span>
					<div class="remove-answer-button ms-2" on:click={removeToken(token, $form)}>
						<i class="bi bi-x" />
					</div>
				</div>

				<div class="row">
					<div class="col-6">
						<span>Answer</span>
						<input bind:value={token.name} placeholder="Answer" />
					</div>
					<div class="col-3">
						<span>Symbol</span>
						<input bind:value={token.symbol} placeholder="Symbol" />
					</div>
					<div class="col">
						<span>Price</span>
						<input type="number" bind:value={token.price} placeholder="Initial Price" />
					</div>
				</div>
			</div>
		{/each}

		<div class="d-flex justify-content-center mt-3">
			<button type="button" class="btn btn-outline-primary" on:click={addToken($form)}>
				<i class="bi bi-plus-lg" />
				Add an Answer
			</button>
		</div>

		<p class="label">Arbiter</p>
		<input
			id="arbiter"
			name="arbiter"
			on:change={handleChange}
			bind:value={$form.arbiter}
			placeholder="Arbiter"
			class:invalid={$errors.arbiter}
		/>

		<p class="label">Closing time</p>
		<DateInput
			bind:value={$form.closingDate}
			format="yyyy-MM-dd HH:mm"
			placeholder="Closing Time"
		/>
		{#if $errors.closingDate}
			<small>{$errors.closingDate}</small>
		{/if}

		<p class="label">Settlement time</p>
		<DateInput
			bind:value={$form.settlementDate}
			format="yyyy-MM-dd HH:mm"
			placeholder="Settlement Time"
		/>
		{#if $errors.settlementDate}
			<small>{$errors.settlementDate}</small>
		{/if}

		<div class="d-flex justify-content-center mt-3">
			<button type="submit" class="btn btn-primary">Create</button>
		</div>
	</form>
</div>

<style lang="scss">
	.label {
		margin-top: 1.25em;
		margin-bottom: 0.5em;
		font-weight: bolder;
	}

	form,
	:global(.date-time-field) {
		width: 550px;

		:global(input) {
			width: 100%;
			height: 46px;
			padding: 8px 16px;
			border: 1px solid #ced4da;
			border-radius: 4.8px;

			&.invalid {
				border: 1px solid red;
			}
		}
	}

	.remove-answer-button {
		display: none;
		cursor: pointer;
	}
	.answer:hover .remove-answer-button {
		display: block;
	}
</style>
