<script>
  import Card from '../Card.svelte'
  import { SAMPLE } from '../card.js'
  import { designer } from '../store.svelte.js'
  import { selectedElement, snapshot } from './actions.svelte.js'

  const SNAP = 5
  const HANDLES = ['nw', 'n', 'ne', 'e', 'se', 's', 'sw', 'w']

  let width = $state(0)
  let height = $state(0)
  let guides = $state({ x: null, y: null })

  const template = $derived(designer.template)
  const data = $derived(designer.sample ?? SAMPLE)
  const scale = $derived(template ? Math.max(0.2, Math.min((width - 80) / template.width, (height - 80) / template.height, 2.5)) : 1)
  const selected = $derived(selectedElement())

  // Snaps an axis to the card edges/center and the other elements' edges/centers
  function snapAxis(start, size, axis) {
    if (!designer.snap) return { value: Math.round(start), guide: null }
    const total = axis === 'x' ? template.width : template.height
    const targets = [0, total / 2, total]
    for (const el of template.elements) {
      if (el.id === designer.selected) continue
      const pos = axis === 'x' ? el.x : el.y
      const len = axis === 'x' ? el.w : el.h
      targets.push(pos, pos + len / 2, pos + len)
    }

    const threshold = SNAP / scale
    for (const offset of [0, size / 2, size]) {
      for (const target of targets) {
        if (Math.abs(start + offset - target) < threshold) return { value: Math.round(target - offset), guide: target }
      }
    }
    return { value: Math.round(start), guide: null }
  }

  function track(event, onmove) {
    let moved = false
    const startX = event.clientX
    const startY = event.clientY
    const move = (e) => {
      if (!moved) snapshot()
      moved = true
      onmove((e.clientX - startX) / scale, (e.clientY - startY) / scale, e.shiftKey)
    }
    const up = () => {
      guides = { x: null, y: null }
      window.removeEventListener('pointermove', move)
      window.removeEventListener('pointerup', up)
    }
    window.addEventListener('pointermove', move)
    window.addEventListener('pointerup', up)
  }

  function startDrag(event, element) {
    designer.selected = element.id
    designer.tab = 'element'
    const origin = { x: element.x, y: element.y }
    track(event, (dx, dy, free) => {
      if (free) {
        element.x = Math.round(origin.x + dx)
        element.y = Math.round(origin.y + dy)
        return
      }
      const x = snapAxis(origin.x + dx, element.w, 'x')
      const y = snapAxis(origin.y + dy, element.h, 'y')
      element.x = x.value
      element.y = y.value
      guides = { x: x.guide, y: y.guide }
    })
  }

  function startResize(event, handle) {
    event.stopPropagation()
    const element = selected
    const origin = { x: element.x, y: element.y, w: element.w, h: element.h }
    track(event, (dx, dy) => {
      if (handle.includes('e')) element.w = Math.max(1, Math.round(origin.w + dx))
      if (handle.includes('s')) element.h = Math.max(1, Math.round(origin.h + dy))
      if (handle.includes('w')) {
        const w = Math.max(1, Math.round(origin.w - dx))
        element.x = origin.x + origin.w - w
        element.w = w
      }
      if (handle.includes('n')) {
        const h = Math.max(1, Math.round(origin.h - dy))
        element.y = origin.y + origin.h - h
        element.h = h
      }
    })
  }
</script>

<div class="canvas" bind:clientWidth={width} bind:clientHeight={height} onpointerdown={() => (designer.selected = null)} role="presentation">
  {#if template}
    <div class="stage" style="width:{template.width * scale}px;height:{template.height * scale}px;">
      <div class="clip" style="border-radius:{(template.radius ?? 0) * scale}px;">
        <Card {template} {data} {scale} onelementdown={startDrag} />
      </div>

      {#if guides.x !== null}<div class="guide v" style="left:{guides.x * scale}px;"></div>{/if}
      {#if guides.y !== null}<div class="guide h" style="top:{guides.y * scale}px;"></div>{/if}

      {#if selected}
        <div
          class="selection"
          style="left:{selected.x * scale}px;top:{selected.y * scale}px;width:{selected.w * scale}px;height:{selected.h * scale}px;transform:rotate({selected.rotate ?? 0}deg);"
        >
          {#each HANDLES as handle}
            <div class="handle {handle}" onpointerdown={(e) => startResize(e, handle)} role="presentation"></div>
          {/each}
        </div>
      {/if}
    </div>
    <div class="size">{template.width} × {template.height}</div>
  {/if}
</div>

<style>
  .canvas {
    position: relative;
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 0;
    overflow: hidden;
    background-color: var(--dark-8);
    background-image: radial-gradient(var(--dark-5) 1px, transparent 1px);
    background-size: 18px 18px;
  }

  .stage {
    position: relative;
    flex: none;
  }

  .clip {
    width: 100%;
    height: 100%;
    overflow: hidden;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
  }

  .clip :global(.el) {
    cursor: move;
  }

  .guide {
    position: absolute;
    background: var(--red);
    pointer-events: none;
  }

  .guide.v {
    top: -20px;
    bottom: -20px;
    width: 1px;
  }

  .guide.h {
    left: -20px;
    right: -20px;
    height: 1px;
  }

  .selection {
    position: absolute;
    outline: 1px solid var(--blue);
    pointer-events: none;
  }

  .handle {
    position: absolute;
    width: 8px;
    height: 8px;
    margin: -4px 0 0 -4px;
    background: #fff;
    border: 1px solid var(--blue);
    border-radius: 2px;
    pointer-events: all;
  }

  .nw { left: 0; top: 0; cursor: nwse-resize; }
  .n { left: 50%; top: 0; cursor: ns-resize; }
  .ne { left: 100%; top: 0; cursor: nesw-resize; }
  .e { left: 100%; top: 50%; cursor: ew-resize; }
  .se { left: 100%; top: 100%; cursor: nwse-resize; }
  .s { left: 50%; top: 100%; cursor: ns-resize; }
  .sw { left: 0; top: 100%; cursor: nesw-resize; }
  .w { left: 0; top: 50%; cursor: ew-resize; }

  .size {
    position: absolute;
    left: 12px;
    bottom: 10px;
    font-family: 'Roboto Mono', monospace;
    font-size: 11px;
    color: var(--dark-3);
  }
</style>
