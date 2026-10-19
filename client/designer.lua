local sharedConfig = require 'config.shared'

---@return table<string, { prop: string, offset: table }>
local function getHandheldDefaults()
    local defaults = {}
    for kind, settings in pairs(sharedConfig.handheld) do
        defaults[kind] = {
            prop = settings.prop,
            offset = { x = settings.pos.x, y = settings.pos.y, z = settings.pos.z, rx = settings.rot.x, ry = settings.rot.y, rz = settings.rot.z },
        }
    end
    return defaults
end

local function closeDesigner()
    if GetUIView() ~= 'designer' then return end
    SetUIView(nil)
    SetNuiFocus(false, false)
    SendUI('designer:close')
end

RegisterNetEvent('qbx_idcard:client:openDesigner', function(data)
    HideCard()
    if GetUIView() then return end

    SetUIView('designer')
    SetNuiFocus(true, true)
    data.handheld = getHandheldDefaults()
    SendUI('designer:open', data)

    local sample = lib.callback.await('qbx_idcard:server:getSample', false)
    if not sample or GetUIView() ~= 'designer' then return end
    sample.mugShot = exports.MugShotBase64:GetMugShotBase64(cache.ped, false)
    SendUI('designer:sample', sample)
end)

---@param name string
---@param handler fun(data: any): any
local function designerCallback(name, handler)
    RegisterNUICallback(name, function(data, cb)
        if GetUIView() ~= 'designer' then return cb(false) end
        local result = handler(data)
        cb(result == nil and false or result)
    end)
end

designerCallback('designer:close', function()
    closeDesigner()
    return true
end)

designerCallback('designer:save', function(data)
    local result = lib.callback.await('qbx_idcard:server:saveTemplate', false, data.item, data.template)
    exports.qbx_core:Notify(locale(result and 'success.saved' or 'error.save_failed'), result and 'success' or 'error')
    return result
end)

designerCallback('designer:delete', function(data)
    local result = lib.callback.await('qbx_idcard:server:deleteTemplate', false, data.item)
    if result then exports.qbx_core:Notify(locale('success.deleted'), 'success') end
    return result
end)

designerCallback('designer:give', function(data)
    local result = lib.callback.await('qbx_idcard:server:giveCard', false, data.item)
    exports.qbx_core:Notify(locale(result and 'success.given' or 'error.unknown_card'), result and 'success' or 'error')
    return result
end)

designerCallback('designer:preview', function(data)
    PlayHandheld({ kind = data.kind, prop = data.prop, offset = data.offset })
    return true
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource or GetUIView() ~= 'designer' then return end
    SetNuiFocus(false, false)
end)
