return {
    -- Mugshot uploads. Without an apiKey mugshots are stored in the item metadata as base64.
    imageUpload = {
        provider = 'qbox', -- 'qbox', 'fivemanage', 'fivemerr' or 'custom'
        apiKey = '',

        custom = { -- only used with provider = 'custom'
            url = '',
            field = 'file',
            responsePath = 'data.url', -- where the image url lives in the json response
        },
    },
}
