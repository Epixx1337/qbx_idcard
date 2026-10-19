<script>
  import { designer, t } from '../store.svelte.js'
  import { previewInHand } from './actions.svelte.js'
  import ColorInput from './ColorInput.svelte'
  import NumberInput from './NumberInput.svelte'

  const template = $derived(designer.template)

  let jobs = $state('')

  $effect(() => {
    jobs = (designer.template?.jobs ?? []).join(', ')
  })

  function setJobs() {
    template.jobs = jobs.split(',').map((job) => job.trim()).filter(Boolean)
  }

  const defaults = $derived(designer.handheld[template.kind] ?? {})

  function toggleOffset() {
    template.offset = template.offset ? null : { ...(defaults.offset ?? { x: 0, y: 0, z: 0, rx: 0, ry: 0, rz: 0 }) }
  }
</script>

<section>
  <div class="section-title">{t('section.card')}</div>
  <label class="field">
    <span class="label">{t('prop.name')}</span>
    <input class="input sm" bind:value={template.label} maxlength="50" />
    <span class="hint">{t('prop.name_hint')}</span>
  </label>
  <div class="field">
    <span class="label">{t('prop.kind')}</span>
    <div class="segmented">
      {#each ['card', 'badge'] as kind}
        <button class="seg" class:active={template.kind === kind} onclick={() => (template.kind = kind)}>
          <i class="fa-solid {kind === 'badge' ? 'fa-shield-halved' : 'fa-id-card'}"></i>{t(`kind.${kind}`)}
        </button>
      {/each}
    </div>
  </div>
  <div class="grid">
    <NumberInput label={t('prop.width')} bind:value={template.width} min={100} max={1000} />
    <NumberInput label={t('prop.height')} bind:value={template.height} min={100} max={1000} />
    <NumberInput label={t('prop.radius')} bind:value={template.radius} min={0} max={500} />
  </div>
</section>

<section>
  <div class="section-title">{t('section.background')}</div>
  <ColorInput label={t('prop.color')} bind:value={template.background} />
  <label class="field">
    <span class="label">{t('prop.image')}</span>
    <input class="input sm" bind:value={template.backgroundImage} placeholder="https://" spellcheck="false" />
  </label>
</section>

<section>
  <div class="section-title">{t('section.handheld')}</div>
  <label class="field">
    <span class="label">{t('prop.prop')}</span>
    <input class="input sm" bind:value={template.prop} placeholder={defaults.prop ?? ''} spellcheck="false" />
  </label>
  <label class="check">
    <input type="checkbox" checked={!!template.offset} onchange={toggleOffset} />{t('prop.custom_offset')}
  </label>
  {#if template.offset}
    <div class="grid three">
      <NumberInput label="X" bind:value={template.offset.x} step={0.005} decimals={3} min={-2} max={2} />
      <NumberInput label="Y" bind:value={template.offset.y} step={0.005} decimals={3} min={-2} max={2} />
      <NumberInput label="Z" bind:value={template.offset.z} step={0.005} decimals={3} min={-2} max={2} />
      <NumberInput label="RX" bind:value={template.offset.rx} decimals={1} min={-360} max={360} />
      <NumberInput label="RY" bind:value={template.offset.ry} decimals={1} min={-360} max={360} />
      <NumberInput label="RZ" bind:value={template.offset.rz} decimals={1} min={-360} max={360} />
    </div>
  {/if}
  <button class="btn subtle" onclick={previewInHand}><i class="fa-solid fa-hand"></i>{t('preview_hand')}</button>
</section>

<section>
  <div class="section-title">{t('section.access')}</div>
  <label class="field">
    <span class="label">{t('prop.jobs')}</span>
    <input class="input sm" bind:value={jobs} onchange={setJobs} placeholder="police, sheriff" spellcheck="false" />
    <span class="hint">{t('prop.jobs_hint')}</span>
  </label>
</section>

<style>
  section {
    display: flex;
    flex-direction: column;
    gap: 10px;
    padding: 12px 14px;
    border-bottom: 1px solid var(--dark-5);
  }

  .section-title {
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: var(--dark-2);
  }

  .grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 10px;
  }

  .grid.three {
    grid-template-columns: 1fr 1fr 1fr;
  }

  .segmented {
    display: flex;
    gap: 2px;
    padding: 2px;
    background: var(--dark-6);
    border: 1px solid var(--dark-4);
    border-radius: var(--radius-sm);
  }

  .seg {
    flex: 1;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 6px;
    padding: 5px;
    font-family: inherit;
    font-size: 12px;
    font-weight: 500;
    color: var(--dark-1);
    background: transparent;
    border: none;
    border-radius: var(--radius-sm);
    cursor: pointer;
  }

  .seg.active {
    color: #fff;
    background: var(--blue);
  }
</style>
