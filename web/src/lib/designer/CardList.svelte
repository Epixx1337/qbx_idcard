<script>
  import { PRESETS } from '../card.js'
  import { designer, t } from '../store.svelte.js'
  import { createCard, isDirty, openCard } from './actions.svelte.js'

  let search = $state('')
  let creating = $state(false)
  let newItem = $state('')
  let preset = $state('card')

  const available = $derived(designer.items.filter((item) => !designer.cards.some((card) => card.item === item.name)))
  const filtered = $derived(
    designer.cards.filter((card) => `${card.item} ${card.label}`.toLowerCase().includes(search.toLowerCase()))
  )

  function create() {
    if (!newItem) return
    createCard(newItem, preset)
    creating = false
    newItem = ''
  }

  function kindOf(card) {
    const kind = card.template?.kind ?? card.license?.kind ?? (card.license?.badge ? 'badge' : 'card')
    return kind
  }
</script>

<aside class="list">
  <div class="search">
    <i class="fa-solid fa-magnifying-glass"></i>
    <input class="input sm" placeholder={t('search')} bind:value={search} />
  </div>

  <div class="cards">
    {#each filtered as card (card.item)}
      <button class="card-row" class:active={card.item === designer.item} onclick={() => openCard(card.item)}>
        <i class="fa-solid {kindOf(card) === 'badge' ? 'fa-shield-halved' : 'fa-id-card'}"></i>
        <div class="text">
          <span class="name">{card.label}{card.item === designer.item && isDirty() ? ' •' : ''}</span>
          <span class="item">{card.item}</span>
        </div>
        {#if !card.exists}
          <span class="badge red" title={t('missing_item')}>!</span>
        {:else if card.template}
          <span class="badge blue">{t('custom')}</span>
        {:else if card.draft}
          <span class="badge yellow">{t('draft')}</span>
        {:else}
          <span class="badge">{t('default')}</span>
        {/if}
      </button>
    {/each}
  </div>

  {#if creating}
    <div class="create">
      <label class="field">
        <span class="label">{t('item')}</span>
        <select class="select sm" bind:value={newItem}>
          <option value="" disabled>{t('choose_item')}</option>
          {#each available as item (item.name)}
            <option value={item.name}>{item.label} ({item.name})</option>
          {/each}
        </select>
      </label>
      <label class="field">
        <span class="label">{t('preset_label')}</span>
        <select class="select sm" bind:value={preset}>
          {#each PRESETS as name}
            <option value={name}>{t(`preset.${name}`)}</option>
          {/each}
        </select>
      </label>
      <div class="actions">
        <button class="btn subtle" onclick={() => (creating = false)}>{t('cancel')}</button>
        <button class="btn" disabled={!newItem} onclick={create}>{t('create')}</button>
      </div>
    </div>
  {:else}
    <button class="btn subtle new" onclick={() => (creating = true)}>
      <i class="fa-solid fa-plus"></i>{t('new_card')}
    </button>
  {/if}
</aside>

<style>
  .list {
    display: flex;
    flex-direction: column;
    gap: 10px;
    width: 250px;
    flex: none;
    padding: 12px;
    border-right: 1px solid var(--dark-4);
    min-height: 0;
  }

  .search {
    position: relative;
  }

  .search i {
    position: absolute;
    left: 9px;
    top: 50%;
    transform: translateY(-50%);
    font-size: 11px;
    color: var(--dark-3);
  }

  .search .input {
    padding-left: 27px;
  }

  .cards {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 4px;
    overflow-y: auto;
    min-height: 0;
  }

  .card-row {
    display: flex;
    align-items: center;
    gap: 10px;
    width: 100%;
    padding: 8px 10px;
    font-family: inherit;
    text-align: left;
    color: var(--dark-0);
    background: transparent;
    border: 1px solid transparent;
    border-radius: var(--radius-sm);
    cursor: pointer;
  }

  .card-row:hover {
    background: var(--dark-6);
  }

  .card-row.active {
    background: var(--accent-15);
    border-color: var(--accent-35);
  }

  .card-row > i {
    width: 16px;
    font-size: 13px;
    color: var(--dark-2);
  }

  .card-row.active > i {
    color: var(--blue-light);
  }

  .text {
    flex: 1;
    display: flex;
    flex-direction: column;
    min-width: 0;
  }

  .name,
  .item {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .name {
    font-size: 13px;
    font-weight: 500;
  }

  .item {
    font-family: 'Roboto Mono', monospace;
    font-size: 11px;
    color: var(--dark-3);
  }

  .create {
    display: flex;
    flex-direction: column;
    gap: 10px;
    padding: 10px;
    background: var(--dark-6);
    border: 1px solid var(--dark-4);
    border-radius: var(--radius-sm);
  }

  .actions {
    display: flex;
    justify-content: flex-end;
    gap: 6px;
  }

  .new {
    width: 100%;
  }
</style>
