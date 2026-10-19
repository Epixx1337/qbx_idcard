local sharedConfig = require 'config.shared'

local currentView = nil
local shownAt = 0
local holding = false
local closeKeybind

---@param action string
---@param data any
function SendUI(action, data)
    SendNUIMessage({ action = action, data = data })
end

---@return string?
function GetUIView()
    return currentView
end

---@param view string?
function SetUIView(view)
    currentView = view
end

function HideCard()
    if currentView ~= 'card' then return end
    currentView = nil
    closeKeybind:disable(true)
    SendUI('card:hide')
end

closeKeybind = lib.addKeybind({
    name = 'closeidcard',
    description = locale('keybind.close'),
    defaultKey = sharedConfig.idCardSettings.closeKey,
    disabled = true,
    onPressed = HideCard,
})

---Holds the card or badge prop in hand for the configured duration
---@param handheld { kind: string, prop?: string, offset?: table }
function PlayHandheld(handheld)
    if holding then return end

    local settings = sharedConfig.handheld[handheld.kind] or sharedConfig.handheld.card
    local model = joaat(handheld.prop or settings.prop)
    if not IsModelInCdimage(model) then return end

    holding = true
    lib.requestAnimDict(settings.dict)
    lib.requestModel(model)

    local coords = GetEntityCoords(cache.ped)
    local prop = CreateObject(model, coords.x, coords.y, coords.z + 0.2, true, true, false)
    local offset = handheld.offset
    local pos = offset and vec3(offset.x, offset.y, offset.z) or settings.pos
    local rot = offset and vec3(offset.rx, offset.ry, offset.rz) or settings.rot

    AttachEntityToEntity(prop, cache.ped, GetPedBoneIndex(cache.ped, settings.bone), pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, true, true, false, true, 1, true)
    TaskPlayAnim(cache.ped, settings.dict, settings.clip, 3.0, -1, -1, 50, 0, false, false, false)
    SetModelAsNoLongerNeeded(model)
    RemoveAnimDict(settings.dict)

    SetTimeout(settings.duration, function()
        DeleteEntity(prop)
        StopAnimTask(cache.ped, settings.dict, settings.clip, 1.0)
        holding = false
    end)
end

RegisterNetEvent('um-idcard:client:sendData', function(playerData)
    if currentView and currentView ~= 'card' then return end

    currentView = 'card'
    closeKeybind:disable(false)
    SendUI('card:show', { card = playerData, closeKey = closeKeybind.currentKey })

    local autoClose = sharedConfig.idCardSettings.autoClose
    if not autoClose.status then return end

    local token = GetGameTimer()
    shownAt = token
    SetTimeout(autoClose.time, function()
        if shownAt == token then HideCard() end
    end)
end)

RegisterNetEvent('um-idcard:client:startAnim', function(cardType, handheld)
    local license = sharedConfig.licenses[cardType]
    PlayHandheld(handheld or { kind = license?.kind or 'card', prop = license?.prop })
end)

lib.callback.register('um-idcard:client:callBack:getClosestPlayer', function()
    local player = lib.getClosestPlayer(GetEntityCoords(cache.ped), 2.0, false)
    return player and GetPlayerServerId(player) or 0
end)

lib.callback.register('um-idcard:client:callBack:getMugShot', function()
    return exports.MugShotBase64:GetMugShotBase64(cache.ped, false)
end)

RegisterNUICallback('getConfig', function(_, cb)
    cb({
        primaryColor = GetConvar('ox:primaryColor', 'blue'),
        primaryShade = GetConvarInt('ox:primaryShade', 8),
        locales = lib.getLocales(),
    })
end)

RegisterNUICallback('closeIdCard', function(_, cb)
    cb(1)
    HideCard()
end)

exports.ox_inventory:displayMetadata({
    firstname = locale('metadata.firstname'),
    lastname = locale('metadata.lastname'),
    nationality = locale('metadata.nationality'),
    birthdate = locale('metadata.birthdate'),
    citizenid = locale('metadata.citizenid'),
})
