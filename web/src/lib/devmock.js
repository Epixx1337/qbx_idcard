import en from '../../../locales/en.json'
import { app } from './store.svelte.js'

function flatten(source, target = {}, prefix = '') {
  for (const [key, value] of Object.entries(source)) {
    const full = prefix ? `${prefix}.${key}` : key
    if (typeof value === 'object') flatten(value, target, full)
    else target[full] = value
  }
  return target
}

const licenses = {
  id_card: { header: 'Identity', background: '#ebf7fd', backgroundImage: 'https://i.ibb.co/vxvGzg1/card.png', prop: 'prop_franklin_dl' },
  driver_license: { header: 'Driver License', background: '#febbbb', backgroundImage: 'https://i.ibb.co/vxvGzg1/card.png', prop: 'prop_franklin_dl' },
  police_badge: { header: 'Police Department', kind: 'badge', background: '#1a1b1e', badge: 'examplebadge', prop: 'prop_fib_badge', jobs: ['police'] }
}

const send = (action, data) => window.postMessage({ action, data }, '*')

export function bootDevMock() {
  app.locales = flatten(en)
  const cards = Object.entries(licenses).map(([item, license]) => ({ item, label: license.header, exists: true, license }))
  const items = ['id_card', 'driver_license', 'police_badge', 'weaponlicense', 'lawyerpass', 'sheriff_badge'].map((name) => ({ name, label: name }))

  if (location.hash.startsWith('#card')) {
    const item = location.hash.slice(6) || 'id_card'
    send('card:show', {
      closeKey: 'BACK',
      card: { cardtype: item, firstname: 'John', lastname: 'Doe', birthdate: '1990-01-01', sex: 'M', nationality: 'American', citizenid: 'ABC12345', grade: 'Officer', callsign: '1-A-12', license: licenses[item] }
    })
    return
  }

  const handheld = {
    card: { prop: 'prop_franklin_dl', offset: { x: 0.1, y: 0.02, z: -0.03, rx: -90, ry: 170, rz: 79 } },
    badge: { prop: 'prop_fib_badge', offset: { x: 0.065, y: 0.029, z: -0.035, rx: 80, ry: -1.9, rz: 75 } }
  }
  send('designer:open', { cards, items, handheld })
}
