import { fetchNui } from '../nui.js'
import { createElement, createPreset, normalize, resolveTemplate, uid } from '../card.js'
import { app, designer, t } from '../store.svelte.js'

const HISTORY_LIMIT = 100

const serialize = () => JSON.stringify($state.snapshot(designer.template))

export const isDirty = () => designer.template !== null && serialize() !== designer.saved

export function selectedElement() {
  return designer.template?.elements.find((el) => el.id === designer.selected) ?? null
}

export function currentCard() {
  return designer.cards.find((card) => card.item === designer.item) ?? null
}

export function snapshot() {
  if (!designer.template) return
  const state = serialize()
  if (designer.history.at(-1) === state) return
  designer.history.push(state)
  if (designer.history.length > HISTORY_LIMIT) designer.history.shift()
  designer.future = []
}

export function undo() {
  const current = serialize()
  while (designer.history.at(-1) === current) designer.history.pop()
  const previous = designer.history.pop()
  if (!previous) return
  designer.future.push(current)
  designer.template = JSON.parse(previous)
}

export function redo() {
  const next = designer.future.pop()
  if (!next) return
  designer.history.push(serialize())
  designer.template = JSON.parse(next)
}

export function confirmThen(message, action) {
  designer.confirm = { message, action }
}

function load(item, template) {
  designer.item = item
  designer.template = template
  designer.saved = serialize()
  designer.selected = null
  designer.history = []
  designer.future = []
}

export function openCard(item, guard = true) {
  if (guard && isDirty()) return confirmThen(t('confirm.discard'), () => openCard(item, false))
  const card = designer.cards.find((entry) => entry.item === item)
  if (card) load(item, resolveTemplate(card))
}

export function createCard(item, preset) {
  const entry = designer.items.find((i) => i.name === item)
  const existing = designer.cards.find((card) => card.item === item)
  if (existing) return openCard(item)

  const label = entry?.label ?? item
  designer.cards.push({ item, label, exists: true, template: null, license: null, draft: true })
  designer.cards.sort((a, b) => a.item.localeCompare(b.item))
  load(item, normalize(createPreset(preset, {}, label)))
  designer.saved = null
}

export function addElement(type) {
  snapshot()
  const element = createElement(type, designer.template)
  designer.template.elements.push(element)
  designer.selected = element.id
  designer.tab = 'element'
}

export function duplicateSelected() {
  const element = selectedElement()
  if (!element) return
  snapshot()
  const copy = { ...$state.snapshot(element), id: uid(), x: element.x + 10, y: element.y + 10 }
  designer.template.elements.push(copy)
  designer.selected = copy.id
}

export function removeSelected() {
  if (!selectedElement()) return
  snapshot()
  designer.template.elements = designer.template.elements.filter((el) => el.id !== designer.selected)
  designer.selected = null
}

export function moveLayer(id, direction) {
  const elements = designer.template.elements
  const index = elements.findIndex((el) => el.id === id)
  const target = index + direction
  if (index < 0 || target < 0 || target >= elements.length) return
  snapshot()
  const [element] = elements.splice(index, 1)
  elements.splice(target, 0, element)
}

export function nudge(dx, dy) {
  const element = selectedElement()
  if (!element) return
  snapshot()
  element.x += dx
  element.y += dy
}

async function request(name, data) {
  designer.busy = true
  try {
    return await fetchNui(name, data)
  } finally {
    designer.busy = false
  }
}

function applyServerData(data) {
  const drafts = designer.cards.filter((card) => card.draft && !data.cards.some((c) => c.item === card.item))
  designer.cards = [...data.cards, ...drafts].sort((a, b) => a.item.localeCompare(b.item))
  designer.items = data.items ?? designer.items
}

export async function save() {
  if (!designer.template || designer.busy) return
  const result = await request('designer:save', { item: designer.item, template: $state.snapshot(designer.template) })
  if (!result) return
  applyServerData(result)
  const card = currentCard()
  if (card?.template) designer.template = normalize(card.template)
  designer.saved = serialize()
}

export function remove() {
  const card = currentCard()
  if (!card) return

  if (!card.template) {
    if (card.draft) {
      designer.cards = designer.cards.filter((c) => c !== card)
      designer.template = null
      designer.item = null
    } else {
      load(card.item, resolveTemplate(card))
    }
    return
  }

  confirmThen(t(card.license ? 'confirm.reset' : 'confirm.delete', card.label), async () => {
    const result = await request('designer:delete', { item: card.item })
    if (!result) return
    applyServerData(result)
    const updated = currentCard()
    if (updated) {
      load(updated.item, resolveTemplate(updated))
    } else {
      designer.template = null
      designer.item = null
    }
  })
}

export function give() {
  if (!designer.item || designer.busy) return
  if (!currentCard()?.template && !currentCard()?.license) return
  request('designer:give', { item: designer.item })
}

export function previewInHand() {
  const template = designer.template
  if (!template) return
  fetchNui('designer:preview', { kind: template.kind, prop: template.prop || null, offset: $state.snapshot(template.offset) ?? null })
}

export function close(guard = true) {
  if (guard && isDirty()) return confirmThen(t('confirm.close'), () => close(false))
  app.view = null
  designer.template = null
  designer.item = null
  fetchNui('designer:close')
}
