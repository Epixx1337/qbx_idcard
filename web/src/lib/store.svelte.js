export const app = $state({
  view: null,
  locales: {}
})

export const viewer = $state({
  card: null,
  closeKey: '',
  visible: false
})

export const designer = $state({
  cards: [],
  items: [],
  sample: null,
  handheld: {},
  item: null,
  template: null,
  saved: null,
  selected: null,
  tab: 'card',
  snap: true,
  busy: false,
  confirm: null,
  history: [],
  future: []
})

export function t(key, ...args) {
  let text = app.locales[`ui.${key}`] ?? key
  for (const arg of args) text = text.replace('%s', arg)
  return text
}
