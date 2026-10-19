export function parseHex(value) {
  let hex = (value ?? '').replace('#', '')
  if (value === 'transparent') return { r: 0, g: 0, b: 0, a: 0 }
  if (hex.length === 3 || hex.length === 4) hex = [...hex].map((c) => c + c).join('')
  if (!/^[0-9a-f]{6}([0-9a-f]{2})?$/i.test(hex)) return { r: 0, g: 0, b: 0, a: 1 }
  const n = (i) => parseInt(hex.slice(i, i + 2), 16)
  return { r: n(0), g: n(2), b: n(4), a: hex.length === 8 ? n(6) / 255 : 1 }
}

export function toHex({ r, g, b, a = 1 }) {
  const h = (n) => Math.round(n).toString(16).padStart(2, '0')
  return `#${h(r)}${h(g)}${h(b)}${a < 1 ? h(a * 255) : ''}`
}

export function rgbToHsv({ r, g, b }) {
  r /= 255
  g /= 255
  b /= 255
  const max = Math.max(r, g, b)
  const d = max - Math.min(r, g, b)
  let h = 0
  if (d) {
    if (max === r) h = ((g - b) / d) % 6
    else if (max === g) h = (b - r) / d + 2
    else h = (r - g) / d + 4
  }
  return { h: (h * 60 + 360) % 360, s: max ? d / max : 0, v: max }
}

export function hsvToRgb({ h, s, v }) {
  const f = (n) => {
    const k = (n + h / 60) % 6
    return (v - v * s * Math.max(0, Math.min(k, 4 - k, 1))) * 255
  }
  return { r: f(5), g: f(3), b: f(1) }
}

export const SWATCHES = [
  '#ffffff', '#f1f3f5', '#c1c2c5', '#5c5f66', '#25262b', '#000000',
  '#c92a2a', '#e8590c', '#f08c00', '#2f9e44', '#0c8599', '#1971c2',
  '#1c3f94', '#5f3dc4', '#a61e4d', '#ebf7fd', '#febbbb', '#c7ffe5'
]
