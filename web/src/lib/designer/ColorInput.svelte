<script>
  import { parseHex, toHex, rgbToHsv, hsvToRgb, SWATCHES } from './color.js'

  let { label, value = $bindable() } = $props()

  let open = $state(false)
  let hsv = $state({ h: 0, s: 0, v: 0 })
  let alpha = $state(1)
  let draft = $state('')
  let root

  $effect(() => {
    draft = value ?? ''
  })

  function toggle() {
    open = !open
    if (!open) return
    const rgba = parseHex(value)
    hsv = rgbToHsv(rgba)
    alpha = rgba.a
  }

  function commit() {
    value = toHex({ ...hsvToRgb(hsv), a: alpha })
  }

  function pickSv(event) {
    const pad = event.currentTarget
    const move = (e) => {
      const rect = pad.getBoundingClientRect()
      hsv.s = Math.min(1, Math.max(0, (e.clientX - rect.left) / rect.width))
      hsv.v = 1 - Math.min(1, Math.max(0, (e.clientY - rect.top) / rect.height))
      commit()
    }
    const up = () => {
      window.removeEventListener('pointermove', move)
      window.removeEventListener('pointerup', up)
    }
    move(event)
    window.addEventListener('pointermove', move)
    window.addEventListener('pointerup', up)
  }

  function swatch(color) {
    value = color
    const rgba = parseHex(color)
    hsv = rgbToHsv(rgba)
    alpha = rgba.a
  }

  function typed() {
    if (/^#([0-9a-f]{3,4}|[0-9a-f]{6}|[0-9a-f]{8})$/i.test(draft) || draft === 'transparent') value = draft
    else draft = value
  }

  function outside(event) {
    if (open && root && !root.contains(event.target)) open = false
  }

  const hue = $derived(toHex(hsvToRgb({ h: hsv.h, s: 1, v: 1 })))
  const solid = $derived(toHex(hsvToRgb(hsv)))
</script>

<svelte:window onpointerdown={outside} />

<div class="color" bind:this={root}>
  {#if label}<span class="label">{label}</span>{/if}
  <div class="row">
    <button type="button" class="swatch" onclick={toggle} aria-label={label}>
      <span style="background:{value === 'transparent' ? 'transparent' : value};"></span>
    </button>
    <input class="input sm" bind:value={draft} onchange={typed} spellcheck="false" />
  </div>

  {#if open}
    <div class="popover panel">
      <div class="sv" style="background-color:{hue};" onpointerdown={pickSv} role="presentation">
        <div class="cursor" style="left:{hsv.s * 100}%;top:{(1 - hsv.v) * 100}%;background:{solid};"></div>
      </div>
      <input type="range" class="hue" min="0" max="359" bind:value={hsv.h} oninput={commit} />
      <div class="alpha" style="--solid:{solid};">
        <input type="range" min="0" max="1" step="0.01" bind:value={alpha} oninput={commit} />
      </div>
      <div class="swatches">
        {#each SWATCHES as color}
          <button type="button" style="background:{color};" onclick={() => swatch(color)} aria-label={color}></button>
        {/each}
        <button type="button" class="none" onclick={() => swatch('transparent')} aria-label="transparent"></button>
      </div>
    </div>
  {/if}
</div>

<style>
  .color {
    position: relative;
    display: flex;
    flex-direction: column;
    gap: 5px;
    min-width: 0;
  }

  .row {
    display: flex;
    gap: 6px;
  }

  .swatch,
  .swatches button {
    flex: none;
    width: 28px;
    height: 28px;
    padding: 3px;
    background: repeating-conic-gradient(#5c5f66 0% 25%, #373a40 0% 50%) 50% / 8px 8px;
    border: 1px solid var(--dark-4);
    border-radius: var(--radius-sm);
    cursor: pointer;
  }

  .swatch span {
    display: block;
    width: 100%;
    height: 100%;
    border-radius: 2px;
  }

  .popover {
    position: absolute;
    top: calc(100% + 6px);
    right: 0;
    z-index: 20;
    display: flex;
    flex-direction: column;
    gap: 10px;
    width: 220px;
    padding: 10px;
  }

  .sv {
    position: relative;
    height: 130px;
    border-radius: var(--radius-sm);
    background-image: linear-gradient(to top, #000, transparent), linear-gradient(to right, #fff, transparent);
    cursor: crosshair;
  }

  .cursor {
    position: absolute;
    width: 12px;
    height: 12px;
    margin: -6px 0 0 -6px;
    border: 2px solid #fff;
    border-radius: 50%;
    box-shadow: 0 0 0 1px rgba(0, 0, 0, 0.4);
    pointer-events: none;
  }

  .hue {
    background: linear-gradient(to right, #f00, #ff0, #0f0, #0ff, #00f, #f0f, #f00);
  }

  .alpha {
    border-radius: 2px;
    background: repeating-conic-gradient(#5c5f66 0% 25%, #373a40 0% 50%) 50% / 8px 8px;
  }

  .alpha input {
    display: block;
    background: linear-gradient(to right, transparent, var(--solid));
  }

  .swatches {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 4px;
  }

  .swatches button {
    width: 100%;
    height: 20px;
    padding: 0;
  }

  .swatches .none {
    background: linear-gradient(135deg, #fff 45%, var(--red) 45%, var(--red) 55%, #fff 55%);
  }
</style>
