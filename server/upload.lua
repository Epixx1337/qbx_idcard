local config = require 'config.server'

local imageProviders = {
    qbox = { url = 'https://api.qbox.re/v1/file', field = 'file', responsePath = 'data.url' },
    fivemanage = { url = 'https://api.fivemanage.com/api/v3/file', field = 'file', responsePath = 'data.url' },
    fivemerr = { url = 'https://api.fivemerr.com/v1/media/images', field = 'file', responsePath = 'url' },
}

local pending = {}
local counter = 0

AddEventHandler('qbx_idcard:internal:uploaded', function(id, result)
    local p = pending[id]
    if not p then return end
    pending[id] = nil
    p:resolve(result)
end)

---@return table?
local function imageProvider()
    local cfg = config.imageUpload
    if not cfg or not cfg.apiKey or cfg.apiKey == '' then return end

    local provider = cfg.provider == 'custom' and cfg.custom or imageProviders[cfg.provider]
    if not provider or not provider.url or provider.url == '' then return end

    return {
        url = provider.url,
        field = provider.field or 'file',
        responsePath = provider.responsePath or 'url',
        apiKey = cfg.apiKey,
    }
end

local upload = {}

---@return boolean
function upload.enabled()
    return imageProvider() ~= nil
end

---Uploads a base64 data uri, returns the cdn url or nil when uploads are off or failed
---@param dataUri string
---@param filename string
---@return string?
function upload.image(dataUri, filename)
    local provider = imageProvider()
    if not provider then return end

    counter += 1
    local id = counter
    local p = promise.new()
    pending[id] = p
    TriggerEvent('qbx_idcard:internal:upload', id, dataUri, filename, provider)
    SetTimeout(35000, function()
        if not pending[id] then return end
        pending[id] = nil
        p:resolve({ ok = false, error = 'timeout' })
    end)

    local result = Citizen.Await(p)
    if result.ok then return result.url end
    lib.print.warn(('mugshot upload failed: %s'):format(result.error))
end

return upload
