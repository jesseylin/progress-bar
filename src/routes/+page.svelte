<script lang="ts">
	let hh = $state(1);
	let mm = $state(0);
	let ss = $state(0);
	let showDetails = $state(false);
	let selectedPreset = $state<number | null>(1);

	let startedAt = $state<number | null>(null);
	let now = $state(Date.now());
	let paused = $state(false);
	let elapsedBeforePause = $state(0);

	const durationMs = $derived((hh * 3600 + mm * 60 + ss) * 1000);
	const running = $derived(startedAt !== null && !paused);
	const elapsed = $derived(
		startedAt === null
			? 0
			: paused
				? elapsedBeforePause
				: elapsedBeforePause + (now - startedAt),
	);
	const clampedElapsed = $derived(Math.min(elapsed, durationMs));
	const progress = $derived(durationMs > 0 ? clampedElapsed / durationMs : 0);
	const remaining = $derived(Math.max(0, durationMs - clampedElapsed));
	const finished = $derived(
		startedAt !== null && elapsed >= durationMs && durationMs > 0,
	);

	$effect(() => {
		const match = presets.findIndex(
			([, h, m, s]) => h === hh && m === mm && s === ss,
		);
		selectedPreset = match === -1 ? null : match;
	});

	$effect(() => {
		if (!running || finished) return;
		const id = setInterval(() => (now = Date.now()), 250);
		return () => clearInterval(id);
	});

	function fmt(ms: number) {
		const total = Math.ceil(ms / 1000);
		const h = Math.floor(total / 3600);
		const m = Math.floor((total % 3600) / 60);
		const s = total % 60;
		const pad = (n: number) => n.toString().padStart(2, "0");
		return `${pad(h)}:${pad(m)}:${pad(s)}`;
	}

	function start() {
		if (durationMs <= 0) return;
		startedAt = Date.now();
		now = Date.now();
		elapsedBeforePause = 0;
		paused = false;
	}
	function pauseResume() {
		if (startedAt === null) return;
		if (paused) {
			startedAt = Date.now();
			now = Date.now();
			paused = false;
		} else {
			elapsedBeforePause += Date.now() - startedAt;
			paused = true;
		}
	}
	function reset() {
		startedAt = null;
		paused = false;
		elapsedBeforePause = 0;
	}

	const presets: [string, number, number, number][] = [
		["30m", 0, 30, 0],
		["1h", 1, 0, 0],
		["3h", 3, 0, 0],
		["6h", 6, 0, 0],
		["8h", 8, 0, 0],
	];
</script>

<svelte:head>
	<title>Progress Timer</title>
</svelte:head>

<main
	class="min-h-screen bg-neutral-950 text-neutral-100 flex items-center justify-center p-6"
>
	<div
		class="w-full max-w-xl rounded-2xl bg-neutral-900/60 ring-1 ring-white/10 shadow-2xl p-5 space-y-4"
	>
		<div
			class="h-20 w-full rounded-2xl bg-neutral-800 overflow-hidden ring-1 ring-white/5"
		>
			<div
				class="h-full bg-gradient-to-r from-sky-400 via-indigo-400 to-violet-500 transition-[width] duration-300 ease-linear"
				style="width: {progress * 100}%"
			></div>
		</div>

		<div class="flex justify-center">
			<button
				onclick={() => (showDetails = !showDetails)}
				aria-label="Toggle precise duration"
				class="text-neutral-500 hover:text-neutral-300 transition-transform duration-200"
				style="transform: rotate({showDetails ? 180 : 0}deg)"
			>
				<svg
					width="20"
					height="20"
					viewBox="0 0 20 20"
					fill="none"
					stroke="currentColor"
					stroke-width="2"
					stroke-linecap="round"
					stroke-linejoin="round"
					><polyline points="5 8 10 13 15 8"></polyline></svg
				>
			</button>
		</div>

		{#if showDetails}
			<div class="space-y-6">
				<div class="text-center">
					<div
						class="text-5xl font-semibold tabular-nums tracking-tight"
					>
						{fmt(startedAt === null ? durationMs : remaining)}
					</div>
					<div class="mt-2 text-sm text-neutral-400 tabular-nums">
						{fmt(clampedElapsed)} / {fmt(durationMs)} &middot; {(
							progress * 100
						).toFixed(1)}%
					</div>
				</div>

				<div class="flex items-end justify-center gap-2">
					<div class="flex flex-col items-center">
						<label class="text-xs text-neutral-500 mb-1" for="hh"
							>hh</label
						>
						<input
							id="hh"
							type="number"
							min="0"
							max="99"
							bind:value={hh}
							disabled={startedAt !== null}
							class="w-20 text-center text-2xl tabular-nums bg-neutral-800 rounded-lg px-2 py-2 ring-1 ring-white/10 focus:outline-none focus:ring-sky-400 disabled:opacity-50"
						/>
					</div>
					<div class="text-2xl text-neutral-600 pb-2">:</div>
					<div class="flex flex-col items-center">
						<label class="text-xs text-neutral-500 mb-1" for="mm"
							>mm</label
						>
						<input
							id="mm"
							type="number"
							min="0"
							max="59"
							bind:value={mm}
							disabled={startedAt !== null}
							class="w-20 text-center text-2xl tabular-nums bg-neutral-800 rounded-lg px-2 py-2 ring-1 ring-white/10 focus:outline-none focus:ring-sky-400 disabled:opacity-50"
						/>
					</div>
					<div class="text-2xl text-neutral-600 pb-2">:</div>
					<div class="flex flex-col items-center">
						<label class="text-xs text-neutral-500 mb-1" for="ss"
							>ss</label
						>
						<input
							id="ss"
							type="number"
							min="0"
							max="59"
							bind:value={ss}
							disabled={startedAt !== null}
							class="w-20 text-center text-2xl tabular-nums bg-neutral-800 rounded-lg px-2 py-2 ring-1 ring-white/10 focus:outline-none focus:ring-sky-400 disabled:opacity-50"
						/>
					</div>
				</div>
			</div>
		{/if}

		<div class="flex justify-center gap-3">
			{#if startedAt === null}
				<button
					onclick={start}
					disabled={durationMs <= 0}
					class="px-5 py-2 rounded-lg bg-sky-500 hover:bg-sky-400 text-neutral-950 font-medium disabled:opacity-40"
					>Start</button
				>
			{:else}
				<button
					onclick={pauseResume}
					disabled={finished}
					class="px-5 py-2 rounded-lg bg-neutral-700 hover:bg-neutral-600 font-medium disabled:opacity-40"
					>{paused ? "Resume" : "Pause"}</button
				>
				<button
					onclick={reset}
					class="px-5 py-2 rounded-lg bg-neutral-800 hover:bg-neutral-700 font-medium ring-1 ring-white/10"
					>Reset</button
				>
			{/if}
		</div>

		<div class="flex justify-center gap-2 text-xs text-neutral-500">
			{#each presets as [label, h, m, s], i}
				<button
					onclick={() => {
						hh = h;
						mm = m;
						ss = s;
						selectedPreset = i;
					}}
					disabled={startedAt !== null}
					class="px-3 py-1 rounded-full ring-1 transition-colors disabled:opacity-30 {selectedPreset ===
					i
						? 'bg-sky-500/20 text-sky-300 ring-sky-400/50'
						: 'ring-white/10 hover:bg-neutral-800'}">{label}</button
				>
			{/each}
		</div>
	</div>
</main>
