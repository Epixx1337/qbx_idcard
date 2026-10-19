# Mugshot uploads

The first time a card is used, a mugshot of the holder is taken and saved on the item. By default it is stored in the item metadata as a base64 image, which can be a few hundred KB per card in your inventory table.

With an image provider configured, the mugshot is uploaded and the metadata only holds its url.

## Setup

Set `imageUpload` in `config/server.lua`. This file is never sent to clients, so the key stays on the server.

```lua
imageUpload = {
    provider = 'qbox', -- 'qbox', 'fivemanage', 'fivemerr' or 'custom'
    apiKey = 'your-api-key',

    custom = { -- only used with provider = 'custom'
        url = 'https://example.com/upload',
        field = 'file',
        responsePath = 'data.url',
    },
},
```

For `custom`, `field` is the multipart form field the file is sent in and `responsePath` is where the image url sits in the json response, dot separated.

## Behaviour

* New mugshots are uploaded as they are taken.
* Cards that already hold a base64 mugshot are uploaded and switched to the url the next time they are used.
* If an upload fails the base64 mugshot is kept and a warning is printed, the card keeps working.
* Only mugshots taken by the server are stored, a client can't put its own url on a card.
