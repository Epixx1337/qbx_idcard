export const isBrowser = !window.invokeNative

const resourceName = window.GetParentResourceName ? window.GetParentResourceName() : 'qbx_idcard'

export async function fetchNui(name, data = {}) {
  if (isBrowser) return null
  const response = await fetch(`https://${resourceName}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(data)
  })
  return response.json()
}

const handlers = new Map()

export function onMessage(action, handler) {
  handlers.set(action, handler)
}

window.addEventListener('message', (event) => {
  const { action, data } = event.data ?? {}
  handlers.get(action)?.(data)
})
