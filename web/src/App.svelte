<script>
  import './lib/theme.css'
  import '@fortawesome/fontawesome-free/css/fontawesome.min.css'
  import '@fortawesome/fontawesome-free/css/solid.min.css'
  import { onMount } from 'svelte'
  import { applyTheme } from './lib/mantine.js'
  import { fetchNui, isBrowser, onMessage } from './lib/nui.js'
  import { app, viewer, designer } from './lib/store.svelte.js'
  import { openCard } from './lib/designer/actions.svelte.js'
  import Viewer from './lib/Viewer.svelte'
  import Designer from './lib/designer/Designer.svelte'

  onMount(async () => {
    if (isBrowser) {
      const { bootDevMock } = await import('./lib/devmock.js')
      bootDevMock()
      return
    }
    const config = await fetchNui('getConfig')
    if (!config) return
    applyTheme(config.primaryColor, config.primaryShade)
    app.locales = config.locales ?? {}
  })

  onMessage('card:show', (data) => {
    viewer.card = data.card
    viewer.closeKey = data.closeKey ?? ''
    viewer.visible = true
  })

  onMessage('card:hide', () => {
    viewer.visible = false
  })

  onMessage('designer:open', (data) => {
    designer.cards = data.cards ?? []
    designer.items = data.items ?? []
    designer.handheld = data.handheld ?? {}
    designer.sample = null
    viewer.visible = false
    app.view = 'designer'
    const first = designer.cards[0]
    if (first) openCard(first.item)
  })

  onMessage('designer:sample', (data) => {
    designer.sample = data
  })

  onMessage('designer:close', () => {
    app.view = null
  })
</script>

{#if app.view === 'designer'}
  <Designer />
{/if}
<Viewer />
