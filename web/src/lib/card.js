import { t } from './store.svelte.js'

export const FIELDS = [
  'fullname', 'firstname', 'lastname', 'birthdate', 'sex', 'nationality',
  'citizenid', 'cardtype', 'job', 'grade', 'callsign', 'issued'
]

export const FONTS = {
  roboto: "'Roboto', sans-serif",
  mono: "'Roboto Mono', monospace",
  slab: "'Roboto Slab', serif",
  oswald: "'Oswald', sans-serif",
  signature: "'Alex Brush', cursive"
}

export const SAMPLE = {
  firstname: 'John',
  lastname: 'Doe',
  birthdate: '1990-01-01',
  sex: 'M',
  nationality: 'American',
  citizenid: 'ABC12345',
  job: 'Police',
  grade: 'Officer',
  callsign: '1-A-12',
  issued: '2026-01-01'
}

export function fieldValue(field, data, template) {
  if (field === 'fullname') return `${data.firstname ?? ''} ${data.lastname ?? ''}`.trim()
  if (field === 'cardtype') return template.label ?? ''
  return data[field] ?? ''
}

let counter = 0

export function uid() {
  counter += 1
  return `e${Date.now().toString(36)}${counter}`
}

const toArray = (value) => (Array.isArray(value) ? value : Object.values(value ?? {}))

const text = (props) => ({
  type: 'text', text: '', x: 20, y: 20, w: 160, h: 24, rotate: 0, opacity: 1,
  font: 'roboto', size: 14, weight: 500, color: '#1a1b1e', align: 'left', spacing: 0, uppercase: false, italic: false,
  ...props, id: uid()
})

const field = (props) => text({
  type: 'field', field: 'fullname', label: '', labelSize: 8, labelColor: '#5c5f66', h: 30, weight: 700, uppercase: true,
  ...props
})

const frame = { radius: 0, borderWidth: 0, borderColor: '#000000', rotate: 0, opacity: 1 }

const photo = (props) => ({ type: 'photo', x: 20, y: 20, w: 90, h: 110, ...frame, radius: 6, grayscale: false, ...props, id: uid() })
const image = (props) => ({ type: 'image', x: 20, y: 20, w: 80, h: 80, ...frame, src: 'badges/examplebadge.png', fit: 'contain', ...props, id: uid() })
const rect = (props) => ({ type: 'rect', x: 20, y: 20, w: 120, h: 40, ...frame, fill: '#228be6', ...props, id: uid() })

export const ELEMENTS = { text, field, photo, image, rect }

export function createElement(type, template) {
  const element = ELEMENTS[type]({ text: t('preset.text') })
  element.x = Math.round((template.width - element.w) / 2)
  element.y = Math.round((template.height - element.h) / 2)
  return element
}

function classicCard(license, label) {
  const value = { labelColor: '#5c5f66', color: '#1a1b1e', size: 13 }
  return {
    label,
    kind: 'card',
    width: 428,
    height: 270,
    radius: 14,
    background: license.background ?? '#ebf7fd',
    backgroundImage: license.backgroundImage,
    prop: license.prop,
    jobs: license.jobs,
    elements: [
      text({ text: t('preset.state'), x: 20, y: 14, w: 200, h: 24, size: 15, weight: 700, spacing: 2, uppercase: true }),
      field({ field: 'cardtype', x: 190, y: 16, w: 158, h: 20, size: 12, weight: 500, spacing: 1.5, align: 'right', color: '#373a40' }),
      photo({ x: 24, y: 60, w: 112, h: 136, radius: 8, borderWidth: 1, borderColor: '#00000030' }),
      field({ ...value, field: 'lastname', label: t('field.lastname'), x: 156, y: 58, w: 252 }),
      field({ ...value, field: 'firstname', label: t('field.firstname'), x: 156, y: 92, w: 252 }),
      field({ ...value, field: 'birthdate', label: t('field.birthdate'), x: 156, y: 126, w: 120 }),
      field({ ...value, field: 'sex', label: t('field.sex'), x: 288, y: 126, w: 120 }),
      field({ ...value, field: 'nationality', label: t('field.nationality'), x: 156, y: 160, w: 120 }),
      field({ ...value, field: 'citizenid', label: t('field.citizenid'), x: 288, y: 160, w: 120, font: 'mono' }),
      field({ field: 'fullname', x: 24, y: 212, w: 240, h: 40, font: 'signature', size: 26, weight: 400, uppercase: false, color: '#1a1b1e' }),
      photo({ x: 342, y: 222, w: 28, h: 28, radius: 14, grayscale: true, opacity: 0.8 }),
      image({ src: 'flags/32.png', x: 378, y: 222, w: 28, h: 28, opacity: 0.85 })
    ]
  }
}

function badgeWallet(license, label) {
  const value = { labelColor: '#5c5f66', color: '#1a1b1e', size: 12, align: 'center' }
  return {
    label,
    kind: 'badge',
    width: 520,
    height: 320,
    radius: 18,
    background: license.background ?? '#1a1b1e',
    prop: license.prop,
    jobs: license.jobs,
    elements: [
      rect({ x: 14, y: 14, w: 236, h: 292, fill: '#25262b', radius: 12, borderWidth: 1, borderColor: '#373a40' }),
      image({ src: `badges/${license.badge ?? 'examplebadge'}.png`, x: 32, y: 28, w: 200, h: 228 }),
      field({ field: 'grade', x: 32, y: 264, w: 200, h: 28, size: 13, spacing: 1.5, align: 'center', color: '#e9ecef' }),
      rect({ x: 266, y: 14, w: 240, h: 292, fill: '#f1f3f5', radius: 12 }),
      field({ field: 'cardtype', x: 280, y: 24, w: 212, h: 22, size: 12, spacing: 1.5, align: 'center' }),
      rect({ x: 266, y: 52, w: 240, h: 4, fill: '#1c3f94', radius: 0 }),
      photo({ x: 336, y: 68, w: 100, h: 120, radius: 8, borderWidth: 1, borderColor: '#00000030' }),
      field({ ...value, field: 'fullname', label: t('field.officer'), x: 280, y: 196, w: 212, h: 34, size: 15 }),
      field({ ...value, field: 'callsign', label: t('field.callsign'), x: 280, y: 234, w: 100 }),
      field({ ...value, field: 'citizenid', label: t('field.citizenid'), x: 392, y: 234, w: 100, font: 'mono' }),
      field({ field: 'fullname', x: 280, y: 268, w: 212, h: 32, font: 'signature', size: 22, weight: 400, uppercase: false, align: 'center', color: '#1a1b1e' })
    ]
  }
}

function blank(label) {
  return { label, kind: 'card', width: 428, height: 270, radius: 14, background: '#ffffff', elements: [] }
}

export const PRESETS = ['card', 'badge', 'blank']

export function createPreset(preset, license = {}, label = '') {
  if (preset === 'badge') return badgeWallet(license, label)
  if (preset === 'blank') return blank(label)
  return classicCard(license, label)
}

export function normalize(template) {
  return {
    ...template,
    jobs: toArray(template.jobs),
    elements: toArray(template.elements).map((element) => ({ ...element, id: element.id ?? uid() }))
  }
}

export function resolveTemplate(card) {
  if (card.template) return normalize(card.template)
  const license = card.license ?? {}
  return normalize(createPreset(license.kind === 'badge' || license.badge ? 'badge' : 'card', license, license.header ?? card.label ?? card.cardtype ?? ''))
}
