<script>
  import { FIELDS, FONTS } from '../card.js'
  import { t } from '../store.svelte.js'
  import ColorInput from './ColorInput.svelte'
  import NumberInput from './NumberInput.svelte'

  let { element } = $props()

  const WEIGHTS = [300, 400, 500, 700, 900]
  const ALIGNS = [
    ['left', 'fa-align-left'],
    ['center', 'fa-align-center'],
    ['right', 'fa-align-right']
  ]
  const typed = $derived(element.type === 'text' || element.type === 'field')
  const framed = $derived(element.type === 'photo' || element.type === 'image' || element.type === 'rect')
</script>

<section>
  <div class="section-title">{t(`element.${element.type}`)}</div>

  {#if element.type === 'text'}
    <label class="field">
      <span class="label">{t('prop.text')}</span>
      <textarea class="input sm" rows="2" bind:value={element.text}></textarea>
    </label>
  {:else if element.type === 'field'}
    <label class="field">
      <span class="label">{t('prop.field')}</span>
      <select class="select sm" bind:value={element.field}>
        {#each FIELDS as field}
          <option value={field}>{t(`field.${field}`)}</option>
        {/each}
      </select>
    </label>
    <label class="field">
      <span class="label">{t('prop.label')}</span>
      <input class="input sm" bind:value={element.label} placeholder={t('prop.label_hint')} />
    </label>
    {#if element.label}
      <div class="grid">
        <NumberInput label={t('prop.label_size')} bind:value={element.labelSize} min={4} max={100} />
        <ColorInput label={t('prop.label_color')} bind:value={element.labelColor} />
      </div>
    {/if}
  {:else if element.type === 'image'}
    <label class="field">
      <span class="label">{t('prop.src')}</span>
      <input class="input sm" bind:value={element.src} spellcheck="false" />
      <span class="hint">{t('prop.src_hint')}</span>
    </label>
    <label class="field">
      <span class="label">{t('prop.fit')}</span>
      <select class="select sm" bind:value={element.fit}>
        {#each ['contain', 'cover', 'fill'] as fit}
          <option value={fit}>{t(`fit.${fit}`)}</option>
        {/each}
      </select>
    </label>
  {:else if element.type === 'photo'}
    <label class="check">
      <input type="checkbox" bind:checked={element.grayscale} />{t('prop.grayscale')}
    </label>
  {:else if element.type === 'rect'}
    <ColorInput label={t('prop.fill')} bind:value={element.fill} />
  {/if}
</section>

{#if typed}
  <section>
    <div class="section-title">{t('section.typography')}</div>
    <div class="grid">
      <label class="field">
        <span class="label">{t('prop.font')}</span>
        <select class="select sm" bind:value={element.font}>
          {#each Object.keys(FONTS) as font}
            <option value={font}>{t(`font.${font}`)}</option>
          {/each}
        </select>
      </label>
      <label class="field">
        <span class="label">{t('prop.weight')}</span>
        <select class="select sm" bind:value={element.weight}>
          {#each WEIGHTS as weight}
            <option value={weight}>{weight}</option>
          {/each}
        </select>
      </label>
      <NumberInput label={t('prop.size')} bind:value={element.size} min={4} max={200} />
      <NumberInput label={t('prop.spacing')} bind:value={element.spacing} step={0.5} decimals={1} min={-10} max={50} />
    </div>
    <ColorInput label={t('prop.color')} bind:value={element.color} />
    <div class="row">
      <div class="segmented">
        {#each ALIGNS as [align, icon]}
          <button class="icon-btn" class:active={element.align === align} onclick={() => (element.align = align)} aria-label={align}>
            <i class="fa-solid {icon}"></i>
          </button>
        {/each}
      </div>
      <div class="segmented">
        <button class="icon-btn" class:active={element.uppercase} onclick={() => (element.uppercase = !element.uppercase)} title={t('prop.uppercase')}>
          <i class="fa-solid fa-font"></i>
        </button>
        <button class="icon-btn" class:active={element.italic} onclick={() => (element.italic = !element.italic)} title={t('prop.italic')}>
          <i class="fa-solid fa-italic"></i>
        </button>
      </div>
    </div>
  </section>
{/if}

{#if framed}
  <section>
    <div class="section-title">{t('section.frame')}</div>
    <div class="grid">
      <NumberInput label={t('prop.radius')} bind:value={element.radius} min={0} max={1000} />
      <NumberInput label={t('prop.border')} bind:value={element.borderWidth} min={0} max={50} />
    </div>
    {#if element.borderWidth > 0}
      <ColorInput label={t('prop.border_color')} bind:value={element.borderColor} />
    {/if}
  </section>
{/if}

<section>
  <div class="section-title">{t('section.layout')}</div>
  <div class="grid">
    <NumberInput label="X" bind:value={element.x} min={-1000} max={2000} />
    <NumberInput label="Y" bind:value={element.y} min={-1000} max={2000} />
    <NumberInput label={t('prop.width')} bind:value={element.w} min={1} max={2000} />
    <NumberInput label={t('prop.height')} bind:value={element.h} min={1} max={2000} />
    <NumberInput label={t('prop.rotate')} bind:value={element.rotate} min={-360} max={360} />
  </div>
  <label class="field">
    <span class="label">{t('prop.opacity')} · {Math.round(element.opacity * 100)}%</span>
    <input type="range" min="0" max="1" step="0.01" bind:value={element.opacity} />
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

  .row {
    display: flex;
    justify-content: space-between;
  }

  .segmented {
    display: flex;
    gap: 2px;
    padding: 2px;
    background: var(--dark-6);
    border: 1px solid var(--dark-4);
    border-radius: var(--radius-sm);
  }

  .segmented .icon-btn {
    width: 28px;
    height: 26px;
  }

  textarea {
    resize: vertical;
    min-height: 34px;
  }
</style>
