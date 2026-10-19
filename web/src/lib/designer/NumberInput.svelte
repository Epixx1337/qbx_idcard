<script>
  let { label, value = $bindable(), step = 1, min = -Infinity, max = Infinity, decimals = 0 } = $props()

  const clamp = (v) => Math.min(max, Math.max(min, Number(v.toFixed(decimals))))

  function input(event) {
    const parsed = parseFloat(event.currentTarget.value)
    if (Number.isFinite(parsed)) value = clamp(parsed)
  }

  // Drag the label sideways to scrub the value
  function scrub(event) {
    const startX = event.clientX
    const start = value ?? 0
    const move = (e) => {
      value = clamp(start + Math.round((e.clientX - startX) / 2) * step)
    }
    const up = () => {
      window.removeEventListener('pointermove', move)
      window.removeEventListener('pointerup', up)
    }
    window.addEventListener('pointermove', move)
    window.addEventListener('pointerup', up)
  }
</script>

<label class="num">
  <span class="label" onpointerdown={scrub} role="presentation">{label}</span>
  <input class="input sm" type="number" {step} value={value ?? 0} oninput={input} />
</label>

<style>
  .num {
    display: flex;
    flex-direction: column;
    gap: 5px;
    min-width: 0;
  }

  .label {
    cursor: ew-resize;
  }
</style>
