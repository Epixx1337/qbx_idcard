<script>
  import { FONTS, fieldValue } from './card.js'

  let { template, data, scale = 1, onelementdown = null } = $props()

  const PLACEHOLDER = `data:image/svg+xml,${encodeURIComponent(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 80"><rect width="64" height="80" fill="#c1c2c5"/><circle cx="32" cy="30" r="13" fill="#909296"/><path d="M8 80c2-17 12-24 24-24s22 7 24 24z" fill="#909296"/></svg>'
  )}`

  const box = (el) =>
    `left:${el.x}px;top:${el.y}px;width:${el.w}px;height:${el.h}px;transform:rotate(${el.rotate ?? 0}deg);opacity:${el.opacity ?? 1};`

  const frame = (el) =>
    `border-radius:${el.radius ?? 0}px;border:${el.borderWidth ?? 0}px solid ${el.borderColor ?? 'transparent'};`

  const typography = (el) =>
    `font-family:${FONTS[el.font] ?? FONTS.roboto};font-size:${el.size}px;font-weight:${el.weight};color:${el.color};` +
    `text-align:${el.align};letter-spacing:${el.spacing ?? 0}px;text-transform:${el.uppercase ? 'uppercase' : 'none'};` +
    `font-style:${el.italic ? 'italic' : 'normal'};`

  const background = $derived(
    `width:${template.width}px;height:${template.height}px;border-radius:${template.radius ?? 0}px;` +
      `background-color:${template.background ?? '#ffffff'};` +
      (template.backgroundImage ? `background-image:url(${JSON.stringify(template.backgroundImage)});` : '') +
      `transform:scale(${scale});`
  )

  function down(event) {
    const id = onelementdown && event.target.closest('[data-id]')?.dataset.id
    const element = id && template.elements.find((el) => el.id === id)
    if (!element) return
    event.stopPropagation()
    onelementdown(event, element)
  }
</script>

<div class="card" style={background} onpointerdown={down} role="presentation">
  {#each template.elements as el (el.id)}
    {#if el.type === 'text'}
      <div class="el text" style={box(el) + typography(el)} data-id={el.id}>{el.text}</div>
    {:else if el.type === 'field'}
      <div class="el field" style={box(el) + typography(el)} data-id={el.id}>
        {#if el.label}
          <span class="caption" style="font-size:{el.labelSize}px;color:{el.labelColor};font-family:{FONTS.roboto};font-style:normal;">{el.label}</span>
        {/if}
        <span class="value">{fieldValue(el.field, data, template)}</span>
      </div>
    {:else if el.type === 'photo'}
      <div class="el media" style={box(el) + frame(el)} data-id={el.id}>
        <img src={data.mugShot || PLACEHOLDER} alt="" class:grayscale={el.grayscale} />
      </div>
    {:else if el.type === 'image'}
      <div class="el media" style={box(el) + frame(el)} data-id={el.id}>
        <img src={el.src} alt="" style="object-fit:{el.fit};" />
      </div>
    {:else if el.type === 'rect'}
      <div class="el" style={box(el) + frame(el) + `background:${el.fill};`} data-id={el.id}></div>
    {/if}
  {/each}
</div>

<style>
  .card {
    position: relative;
    overflow: hidden;
    flex: none;
    transform-origin: top left;
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    color: #1a1b1e;
  }

  .el {
    position: absolute;
    box-sizing: border-box;
  }

  .text,
  .field {
    display: flex;
    flex-direction: column;
    justify-content: center;
    line-height: 1.15;
    overflow: hidden;
  }

  .text {
    white-space: pre-wrap;
    word-break: break-word;
  }

  .field span {
    display: block;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .field .caption {
    font-weight: 500;
    letter-spacing: 0.06em;
    text-transform: uppercase;
    margin-bottom: 1px;
  }

  .media {
    overflow: hidden;
  }

  .media img {
    display: block;
    width: 100%;
    height: 100%;
    object-fit: cover;
    pointer-events: none;
  }

  .grayscale {
    filter: grayscale(1);
  }
</style>
