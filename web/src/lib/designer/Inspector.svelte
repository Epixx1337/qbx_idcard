<script>
  import { designer, t } from '../store.svelte.js'
  import { moveLayer, selectedElement, snapshot } from './actions.svelte.js'
  import CardPanel from './CardPanel.svelte'
  import ElementPanel from './ElementPanel.svelte'

  const TABS = ['element', 'layers', 'card']
  const ICONS = { text: 'fa-font', field: 'fa-i-cursor', photo: 'fa-user', image: 'fa-image', rect: 'fa-square' }

  const selected = $derived(selectedElement())
  const layers = $derived(designer.template ? [...designer.template.elements].reverse() : [])

  function describe(el) {
    if (el.type === 'text') return el.text || t('element.text')
    if (el.type === 'field') return el.label || t(`field.${el.field}`)
    if (el.type === 'image') return el.src.split('/').pop()
    return t(`element.${el.type}`)
  }
</script>

<aside class="inspector" onfocusin={snapshot} onpointerdowncapture={snapshot}>
  <div class="tabs">
    {#each TABS as tab}
      <button class="tab" class:active={designer.tab === tab} onclick={() => (designer.tab = tab)}>{t(`tab.${tab}`)}</button>
    {/each}
  </div>

  <div class="content">
    {#if designer.tab === 'element'}
      {#if selected}
        {#key selected.id}
          <ElementPanel element={selected} />
        {/key}
      {:else}
        <div class="empty">
          <i class="fa-solid fa-arrow-pointer"></i>
          <span>{t('no_selection')}</span>
        </div>
      {/if}
    {:else if designer.tab === 'layers'}
      <div class="layers">
        {#each layers as el, i (el.id)}
          <div class="layer" class:active={el.id === designer.selected}>
            <button class="layer-name" onclick={() => (designer.selected = el.id)}>
              <i class="fa-solid {ICONS[el.type]}"></i>
              <span>{describe(el)}</span>
            </button>
            <button class="icon-btn" disabled={i === 0} onclick={() => moveLayer(el.id, 1)} aria-label="up">
              <i class="fa-solid fa-chevron-up"></i>
            </button>
            <button class="icon-btn" disabled={i === layers.length - 1} onclick={() => moveLayer(el.id, -1)} aria-label="down">
              <i class="fa-solid fa-chevron-down"></i>
            </button>
          </div>
        {:else}
          <div class="empty"><span>{t('no_layers')}</span></div>
        {/each}
      </div>
    {:else}
      <CardPanel />
    {/if}
  </div>
</aside>

<style>
  .inspector {
    display: flex;
    flex-direction: column;
    width: 300px;
    flex: none;
    min-height: 0;
    border-left: 1px solid var(--dark-4);
  }

  .tabs {
    display: flex;
    gap: 4px;
    padding: 8px;
    border-bottom: 1px solid var(--dark-4);
  }

  .tab {
    flex: 1;
    padding: 7px;
    font-family: inherit;
    font-size: 12px;
    font-weight: 500;
    color: var(--dark-1);
    background: transparent;
    border: none;
    border-radius: var(--radius-sm);
    cursor: pointer;
  }

  .tab:hover {
    background: var(--dark-6);
  }

  .tab.active {
    color: var(--blue-light);
    background: var(--accent-15);
  }

  .content {
    flex: 1;
    overflow-y: auto;
    min-height: 0;
  }

  .empty {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 10px;
    padding: 40px 20px;
    font-size: 12px;
    text-align: center;
    color: var(--dark-3);
  }

  .empty i {
    font-size: 20px;
  }

  .layers {
    display: flex;
    flex-direction: column;
    gap: 2px;
    padding: 8px;
  }

  .layer {
    display: flex;
    align-items: center;
    border-radius: var(--radius-sm);
  }

  .layer:hover {
    background: var(--dark-6);
  }

  .layer.active {
    background: var(--accent-15);
  }

  .layer-name {
    flex: 1;
    display: flex;
    align-items: center;
    gap: 10px;
    min-width: 0;
    padding: 7px 8px;
    font-family: inherit;
    font-size: 12px;
    text-align: left;
    color: var(--dark-0);
    background: transparent;
    border: none;
    cursor: pointer;
  }

  .layer-name i {
    width: 14px;
    color: var(--dark-2);
  }

  .layer-name span {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .layer .icon-btn {
    width: 24px;
    height: 24px;
    font-size: 10px;
  }
</style>
