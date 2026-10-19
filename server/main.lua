local sharedConfig = require 'config.shared'
local templates = require 'server.templates'
local upload = require 'server.upload'

local ox_inventory = exports.ox_inventory
local MAX_MUGSHOT_LENGTH = 512 * 1024

---@param mugShot any
---@return boolean
local function isBase64MugShot(mugShot)
    return type(mugShot) == 'string'
        and #mugShot <= MAX_MUGSHOT_LENGTH
        and mugShot:find('^data:image/[%w.+-]+;base64,') ~= nil
end

---@param mugShot any
---@return boolean
local function isValidMugShot(mugShot)
    if isBase64MugShot(mugShot) then return true end
    return type(mugShot) == 'string' and #mugShot <= 512 and mugShot:find('^https://[^%s"\'()\\<>]+$') ~= nil
end

---@param citizenid string
---@return string
local function mugShotName(citizenid)
    return ('mugshot_%s_%d'):format(citizenid, os.time())
end

---@param sex number
---@return string
local function getStringSex(sex)
    return sex == 1 and 'F' or 'M'
end

---Saved design for the item, falling back to its config entry
---@param itemName string
---@return { item: string, template?: table, license?: table }?
local function getCard(itemName)
    local template = templates.get(itemName)
    local license = sharedConfig.licenses[itemName]
    if not template and not license then return end
    return { item = itemName, template = template, license = license }
end

---@param player table
---@param itemName string
---@return string | table
local function getBadge(player, itemName)
    local license = sharedConfig.licenses[itemName]
    if not license or not license.badge then return 'none' end

    return {
        img = license.badge,
        grade = player.PlayerData.job.grade.name
    }
end

---@param player table
---@param itemName string
---@return table
local function createMetadata(player, itemName)
    local playerData = player.PlayerData
    local charinfo = playerData.charinfo

    return {
        cardtype = itemName,
        citizenid = playerData.citizenid,
        firstname = charinfo.firstname,
        lastname = charinfo.lastname,
        birthdate = charinfo.birthdate,
        sex = getStringSex(charinfo.gender),
        nationality = charinfo.nationality,
        job = playerData.job.label,
        grade = playerData.job.grade.name,
        callsign = playerData.metadata.callsign,
        issued = os.date('%Y-%m-%d'),
        badge = getBadge(player, itemName),
    }
end

---@param src number
---@param itemTable string | string[]
local function CreateMetaLicense(src, itemTable)
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    if type(itemTable) == 'string' then
        itemTable = { itemTable }
    end

    for i = 1, #itemTable do
        ox_inventory:AddItem(src, itemTable[i], 1, createMetadata(player, itemTable[i]))
    end
end

exports('CreateMetaLicense', CreateMetaLicense)

---@param src number
---@param itemTable string | string[]
---@return table?
local function GetMetaLicense(src, itemTable)
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    return createMetadata(player, type(itemTable) == 'table' and itemTable[1] or itemTable)
end

exports('GetMetaLicense', GetMetaLicense)

---@param src number
---@param itemName string
---@param slot number
---@param mugShot string
---@return table?
local function setMugShot(src, itemName, slot, mugShot)
    local inventoryItem = ox_inventory:GetSlot(src, slot)
    if not inventoryItem or inventoryItem.name ~= itemName then return end

    local metadata = inventoryItem.metadata or {}
    metadata.mugShot = mugShot
    ox_inventory:SetMetadata(src, slot, metadata)
    return metadata
end

---@param src number
---@param itemName string
---@param citizenid string
---@param slot? number
---@return table?
local function saveMugShot(src, itemName, citizenid, slot)
    local mugShot = lib.callback.await('um-idcard:client:callBack:getMugShot', src)
    if not isBase64MugShot(mugShot) then return end

    if not slot or ox_inventory:GetSlot(src, slot)?.name ~= itemName then
        local _, found = next(ox_inventory:Search(src, 1, itemName) or {})
        slot = found and found.slot
    end
    if not slot then return end

    return setMugShot(src, itemName, slot, upload.image(mugShot, mugShotName(citizenid)) or mugShot)
end

---@param src number
---@param target number
---@return boolean
local function isNearbyPlayer(src, target)
    if math.type(target) ~= 'integer' or target <= 0 or target == src or not GetPlayerName(target) then return false end

    if GetPlayerRoutingBucket(src) ~= GetPlayerRoutingBucket(target) then return false end

    local playerPed = GetPlayerPed(src)
    local targetPed = GetPlayerPed(target)
    if playerPed <= 0 or targetPed <= 0 then return false end

    return #(GetEntityCoords(playerPed) - GetEntityCoords(targetPed)) <= 3.0
end

---@param src number
---@param itemName string
---@param metadata table
---@param slot? number
local function sendData(src, itemName, metadata, slot)
    if type(src) ~= 'number' or not GetPlayerName(src) then return end
    if type(itemName) ~= 'string' or type(metadata) ~= 'table' then return end

    local card = getCard(itemName)
    local player = exports.qbx_core:GetPlayer(src)
    if not card or not player then return end

    local settings = card.template or card.license
    if settings.jobs and not lib.table.contains(settings.jobs, player.PlayerData.job.name) then
        return exports.qbx_core:Notify(src, locale('error.not_authorized'), 'error')
    end

    local citizenid = player.PlayerData.citizenid
    if isBase64MugShot(metadata.mugShot) and slot and upload.enabled() then
        local url = upload.image(metadata.mugShot, mugShotName(metadata.citizenid or citizenid))
        if url then metadata = setMugShot(src, itemName, slot, url) or metadata end
    elseif not isValidMugShot(metadata.mugShot) and (not metadata.citizenid or metadata.citizenid == citizenid) then
        metadata = saveMugShot(src, itemName, citizenid, slot) or metadata
    end

    local charinfo = player.PlayerData.charinfo
    local payload = {
        cardtype = itemName,
        citizenid = metadata.citizenid or player.PlayerData.citizenid,
        firstname = metadata.firstname or charinfo.firstname,
        lastname = metadata.lastname or charinfo.lastname,
        birthdate = metadata.birthdate or charinfo.birthdate,
        sex = metadata.sex or getStringSex(charinfo.gender),
        nationality = metadata.nationality or charinfo.nationality,
        job = metadata.job,
        grade = metadata.grade or type(metadata.badge) == 'table' and metadata.badge.grade or nil,
        callsign = metadata.callsign,
        issued = metadata.issued,
        mugShot = isValidMugShot(metadata.mugShot) and metadata.mugShot or nil,
        badge = metadata.badge,
        template = card.template,
        license = card.license,
    }

    lib.callback('um-idcard:client:callBack:getClosestPlayer', src, function(target)
        if not GetPlayerName(src) then return end

        target = tonumber(target)
        if target and isNearbyPlayer(src, target) then
            exports.qbx_core:Notify(src, locale('success.showing'), 'success')
        else
            target = src
        end

        TriggerClientEvent('um-idcard:client:sendData', target, payload)
    end)

    TriggerClientEvent('um-idcard:client:startAnim', src, itemName, {
        kind = settings.kind or 'card',
        prop = settings.prop,
        offset = card.template and card.template.offset,
    })
end

-- Server-only on purpose, card data must never come from a client
AddEventHandler('um-idcard:server:sendData', sendData)

---@param itemName string
local function registerCard(itemName)
    exports.qbx_core:CreateUseableItem(itemName, function(source, item)
        sendData(source, itemName, item.metadata or item.info or {}, item.slot)
    end)
end

---@param src number
---@return boolean
local function canDesign(src)
    return IsPlayerAceAllowed(src --[[@as string]], ('command.%s'):format(sharedConfig.commands.designer))
end

---@return table
local function getDesignerData()
    local cards, items = {}, {}
    local inventoryItems = ox_inventory:Items()

    for name, data in pairs(inventoryItems) do
        if not data.weapon then
            items[#items + 1] = { name = name, label = data.label }
        end
    end

    local names = {}
    for name in pairs(sharedConfig.licenses) do names[name] = true end
    for name in pairs(templates.all()) do names[name] = true end

    for name in pairs(names) do
        local card = getCard(name) --[[@as table]]
        card.label = inventoryItems[name]?.label or name
        card.exists = inventoryItems[name] ~= nil
        cards[#cards + 1] = card
    end

    table.sort(cards, function(a, b) return a.item < b.item end)
    table.sort(items, function(a, b) return a.name < b.name end)

    return { cards = cards, items = items }
end

lib.callback.register('qbx_idcard:server:saveTemplate', function(source, itemName, raw)
    if not canDesign(source) then return end
    if type(itemName) ~= 'string' or not ox_inventory:Items(itemName) then return end

    local template = templates.sanitize(raw)
    if not template then return end

    templates.save(itemName, template, GetPlayerName(source))
    registerCard(itemName)
    return getDesignerData()
end)

lib.callback.register('qbx_idcard:server:deleteTemplate', function(source, itemName)
    if not canDesign(source) or type(itemName) ~= 'string' or not templates.get(itemName) then return end

    templates.delete(itemName)
    if not sharedConfig.licenses[itemName] then
        exports.qbx_core:CreateUseableItem(itemName, nil)
    end
    return getDesignerData()
end)

lib.callback.register('qbx_idcard:server:giveCard', function(source, itemName)
    if not canDesign(source) or type(itemName) ~= 'string' or not getCard(itemName) then return false end
    CreateMetaLicense(source, itemName)
    return true
end)

lib.callback.register('qbx_idcard:server:getSample', function(source)
    if not canDesign(source) then return end
    local player = exports.qbx_core:GetPlayer(source)
    return player and createMetadata(player, 'sample')
end)

lib.addCommand(sharedConfig.commands.designer, {
    help = locale('command.designer'),
    restricted = sharedConfig.commands.restricted,
}, function(source)
    TriggerClientEvent('qbx_idcard:client:openDesigner', source, getDesignerData())
end)

lib.addCommand(sharedConfig.commands.give, {
    help = locale('command.give'),
    params = {
        { name = 'target', type = 'playerId', help = locale('command.give_target') },
        { name = 'item', type = 'string', help = locale('command.give_item') },
    },
    restricted = sharedConfig.commands.restricted,
}, function(source, args)
    if not getCard(args.item) then
        return exports.qbx_core:Notify(source, locale('error.unknown_card'), 'error')
    end
    CreateMetaLicense(args.target, args.item)
    exports.qbx_core:Notify(source, locale('success.given'), 'success')
end)

CreateThread(function()
    templates.load()

    for name in pairs(sharedConfig.licenses) do
        registerCard(name)
    end

    for name in pairs(templates.all()) do
        registerCard(name)
    end
end)

lib.versionCheck('Qbox-project/qbx_idcard')
