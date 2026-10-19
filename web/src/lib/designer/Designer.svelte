<script>
  import { designer, t } from '../store.svelte.js'
  import {
    addElement, close, currentCard, duplicateSelected, give, isDirty, moveLayer, nudge,
    redo, remove, removeSelected, save, selectedElement, undo
  } from './actions.svelte.js'
  import CardList from './CardList.svelte'
  import Canvas from './Canvas.svelte'
  import Inspector from './Inspector.svelte'

  const TOOLS = [
    ['text', 'fa-font'],
    ['field', 'fa-i-cursor'],
    ['photo', 'fa-user'],
    ['image', 'fa-image'],
    ['rect', 'fa-square']
  ]

  const card = $derived(currentCard())
  const selected = $derived(selectedElement())
  const dirty = $derived(isDirty())

  function confirm(ok) {
    const action = designer.confirm?.action
    designer.confirm = null
    if (ok) action?.()
  }

  function keydown(event) {
    if (designer.confirm) {
      if (event.key === 'Escape') confirm(false)
      else if (event.key === 'Enter') confirm(true)
      return
    }

    const tag = event.target.tagName
    if (tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT') {
      if (event.key === 'Escape') event.target.blur()
      return
    }

    const ctrl = event.ctrlKey || event.metaKey
    const step = event.shiftKey ? 10 : 1
    const key = event.key.toLowerCase()

    if (ctrl && key === 'z') event.shiftKey ? redo() : undo()
    else if (ctrl && key === 'y') redo()
    else if (ctrl && key === 'd') duplicateSelected()
    else if (ctrl && key === 's') save()
    else if (key === 'delete' || key === 'backspace') removeSelected()
    else if (key === 'escape') selected ? (designer.selected = null) : close()
    else if (key === 'arrowleft') nudge(-step, 0)
    else if (key === 'arrowright') nudge(step, 0)
    else if (key === 'arrowup') nudge(0, -step)
    else if (key === 'arrowdown') nudge(0, step)
    else return

    event.preventDefault()
  }
</script>

<svelte:window onkeydown={keydown} />

<div class="backdrop">
  <div class="designer panel">
    <header class="panel-header">
      <div class="title">
        <div class="logo"><i class="fa-solid fa-id-card"></i></div>
        <div>
          <div class="panel-title">{t('designer')}</div>
          <div class="panel-subtitle">
            {#if card}{card.label} · <span class="mono">{card.item}</span>{:else}{t('designer_hint')}{/if}
          </div>
        </div>
      </div>

      <div class="actions">
        {#if card}
          <button class="btn subtle" onclick={give} disabled={designer.busy || (!card.template && !card.license)}>
            <i class="fa-solid fa-hand-holding"></i>{t('give')}
          </button>
          <button class="btn subtle" onclick={remove} disabled={designer.busy}>
            {#if card.template && !card.license}
              <i class="fa-solid fa-trash"></i>{t('delete')}
            {:else}
              <i class="fa-solid fa-rotate-left"></i>{t('reset')}
            {/if}
          </button>
          <button class="btn" onclick={save} disabled={designer.busy || (!dirty && !!card.template)}>
            <i class="fa-solid fa-floppy-disk"></i>{t('save')}
          </button>
        {/if}
        <button class="icon-btn" onclick={() => close()} aria-label={t('close')}>
          <i class="fa-solid fa-xmark"></i>
        </button>
      </div>
    </header>

    <div class="body">
      <CardList />

      <main>
        {#if designer.template}
          <div class="toolbar">
            <div class="group">
              {#each TOOLS as [type, icon]}
                <button class="tool" onclick={() => addElement(type)}>
                  <i class="fa-solid {icon}"></i>{t(`element.${type}`)}
                </button>
              {/each}
            </div>
            <div class="group">
              <button class="icon-btn" onclick={undo} disabled={!designer.history.length} title={t('undo')}><i class="fa-solid fa-rotate-left"></i></button>
              <button class="icon-btn" onclick={redo} disabled={!designer.future.length} title={t('redo')}><i class="fa-solid fa-rotate-right"></i></button>
              <span class="divider"></span>
              <button class="icon-btn" onclick={() => moveLayer(designer.selected, 1)} disabled={!selected} title={t('forward')}><i class="fa-solid fa-arrow-up"></i></button>
              <button class="icon-btn" onclick={() => moveLayer(designer.selected, -1)} disabled={!selected} title={t('backward')}><i class="fa-solid fa-arrow-down"></i></button>
              <button class="icon-btn" onclick={duplicateSelected} disabled={!selected} title={t('duplicate')}><i class="fa-solid fa-clone"></i></button>
              <button class="icon-btn" onclick={removeSelected} disabled={!selected} title={t('remove')}><i class="fa-solid fa-trash"></i></button>
              <span class="divider"></span>
              <button class="icon-btn" class:active={designer.snap} onclick={() => (designer.snap = !designer.snap)} title={t('snap')}><i class="fa-solid fa-magnet"></i></button>
            </div>
          </div>
          <Canvas />
        {:else}
          <div class="placeholder">
            <i class="fa-solid fa-id-card"></i>
            <span>{t('designer_hint')}</span>
          </div>
        {/if}
      </main>

      {#if designer.template}
        <Inspector />
      {/if}
    </div>
  </div>

  {#if designer.confirm}
    <div class="modal-backdrop">
      <div class="modal panel">
        <div class="panel-title">{t('confirm.title')}</div>
        <p>{designer.confirm.message}</p>
        <div class="modal-actions">
          <button class="btn subtle" onclick={() => confirm(false)}>{t('cancel')}</button>
          <button class="btn danger" onclick={() => confirm(true)}>{t('confirm.ok')}</button>
        </div>
      </div>
    </div>
  {/if}
</div>

<style>
  .backdrop {
    position: absolute;
    inset: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    background: rgba(0, 0, 0, 0.35);
  }

  .designer {
    display: flex;
    flex-direction: column;
    width: min(1500px, 94vw);
    height: min(880px, 90vh);
    overflow: hidden;
    animation: pop 0.15s ease;
  }

  .title {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .logo {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 36px;
    height: 36px;
    font-size: 16px;
    color: var(--blue-light);
    background: var(--accent-15);
    border-radius: var(--radius-md);
  }

  .mono {
    font-family: 'Roboto Mono', monospace;
  }

  .actions {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .body {
    flex: 1;
    display: flex;
    min-height: 0;
  }

  main {
    flex: 1;
    display: flex;
    flex-direction: column;
    min-width: 0;
  }

  .toolbar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    padding: 8px 10px;
    border-bottom: 1px solid var(--dark-4);
  }

  .group {
    display: flex;
    align-items: center;
    gap: 4px;
  }

  .tool {
    display: inline-flex;
    align-items: center;
    gap: 7px;
    padding: 6px 10px;
    font-family: inherit;
    font-size: 12px;
    font-weight: 500;
    color: var(--dark-0);
    background: var(--dark-6);
    border: 1px solid var(--dark-4);
    border-radius: var(--radius-sm);
    cursor: pointer;
    transition: border-color 0.12s ease, background 0.12s ease;
  }

  .tool:hover {
    background: var(--dark-5);
    border-color: var(--accent-35);
  }

  .tool i {
    color: var(--blue-light);
  }

  .divider {
    width: 1px;
    height: 18px;
    margin: 0 4px;
    background: var(--dark-4);
  }

  .placeholder {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 12px;
    font-size: 13px;
    color: var(--dark-3);
    background: var(--dark-8);
  }

  .placeholder i {
    font-size: 32px;
  }

  .modal-backdrop {
    position: absolute;
    inset: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    background: rgba(0, 0, 0, 0.45);
  }

  .modal {
    display: flex;
    flex-direction: column;
    gap: 12px;
    width: 380px;
    padding: 18px;
  }

  .modal p {
    font-size: 13px;
    line-height: 1.5;
    color: var(--dark-1);
  }

  .modal-actions {
    display: flex;
    justify-content: flex-end;
    gap: 8px;
  }

  @keyframes pop {
    from {
      opacity: 0;
      transform: scale(0.98);
    }
    to {
      opacity: 1;
      transform: scale(1);
    }
  }
</style>
