function responseField(value, fieldPath) {
  for (const key of fieldPath.split('.')) {
    if (typeof value !== 'object' || value === null) return
    value = value[key]
  }
  return typeof value === 'string' ? value : undefined
}

async function upload(dataUri, filename, provider) {
  const match = /^data:(image\/[\w.+-]+);base64,(.+)$/.exec(dataUri)
  if (!match) return { ok: false, error: 'not a base64 image' }

  const extension = match[1].split('/')[1].replace('jpeg', 'jpg')
  const form = new FormData()
  form.append(provider.field || 'file', new Blob([Buffer.from(match[2], 'base64')], { type: match[1] }), `${filename}.${extension}`)

  const res = await fetch(provider.url, {
    method: 'POST',
    headers: { Authorization: provider.apiKey },
    body: form,
    signal: AbortSignal.timeout(30_000)
  })
  if (!res.ok) return { ok: false, error: `http ${res.status}` }

  const json = await res.json().catch(() => null)
  const url = json && responseField(json, provider.responsePath || 'url')
  return url ? { ok: true, url } : { ok: false, error: 'no url in response' }
}

on('qbx_idcard:internal:upload', (id, dataUri, filename, provider) => {
  upload(String(dataUri), String(filename), provider)
    .catch((err) => ({ ok: false, error: String(err) }))
    .then((result) => emit('qbx_idcard:internal:uploaded', id, result))
})
