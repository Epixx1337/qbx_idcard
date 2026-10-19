<script>
  import Card from './Card.svelte'
  import { resolveTemplate } from './card.js'
  import { viewer, t } from './store.svelte.js'

  let innerHeight = $state(window.innerHeight)
  let innerWidth = $state(window.innerWidth)

  const template = $derived(viewer.card ? resolveTemplate(viewer.card) : null)
  const scale = $derived(
    template
      ? Math.min((innerHeight * (template.kind === 'badge' ? 0.34 : 0.3)) / template.height, (innerWidth * 0.42) / template.width)
      : 1
  )
</script>

<svelte:window bind:innerHeight bind:innerWidth />

{#if viewer.visible && template}
  <div class="viewer">
    <div class="holder" style="width:{template.width * scale}px;height:{template.height * scale}px;border-radius:{(template.radius ?? 0) * scale}px;">
      <Card {template} data={viewer.card} {scale} />
    </div>
    {#if viewer.closeKey}
      <div class="hint"><kbd>{viewer.closeKey}</kbd>{t('close')}</div>
    {/if}
  </div>
{/if}

<style>
  .viewer {
    position: absolute;
    top: 50%;
    right: 3vh;
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 10px;
    transform: translateY(-50%);
    animation: slide-in 0.25s cubic-bezier(0.2, 0.8, 0.2, 1);
  }

  .holder {
    overflow: hidden;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.45), 0 2px 6px rgba(0, 0, 0, 0.3);
  }

  .hint {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 5px 10px 5px 5px;
    font-size: 12px;
    font-weight: 500;
    color: var(--dark-0);
    background: var(--dark-7);
    border: 1px solid var(--dark-4);
    border-radius: var(--radius-sm);
    box-shadow: var(--shadow);
  }

  kbd {
    padding: 2px 7px;
    font-family: 'Roboto Mono', monospace;
    font-size: 11px;
    font-weight: 700;
    color: #fff;
    background: var(--blue);
    border-radius: var(--radius-sm);
  }

  @keyframes slide-in {
    from {
      opacity: 0;
      transform: translate(40px, -50%);
    }
    to {
      opacity: 1;
      transform: translate(0, -50%);
    }
  }
</style>
