local MAX_ELEMENTS = 100

local FIELDS = {
    firstname = true, lastname = true, fullname = true, birthdate = true, sex = true, nationality = true,
    citizenid = true, job = true, grade = true, callsign = true, issued = true, cardtype = true,
}
local FONTS = { roboto = true, mono = true, slab = true, oswald = true, signature = true }
local ALIGNS = { left = true, center = true, right = true }
local FITS = { cover = true, contain = true, fill = true }
local KINDS = { card = true, badge = true }

local cache = {}

local function clamp(min, max, default)
    return function(value)
        value = tonumber(value)
        if not value or value ~= value then return default end
        return math.max(min, math.min(max, value))
    end
end

local function text(max, default)
    return function(value)
        return type(value) == 'string' and value:sub(1, max) or default
    end
end

local function color(default)
    return function(value)
        if value == 'transparent' then return value end
        local hex = type(value) == 'string' and value:match('^#(%x+)$')
        local length = hex and #hex
        return (length == 3 or length == 4 or length == 6 or length == 8) and value or default
    end
end

local function oneOf(options, default)
    return function(value)
        return options[value] and value or default
    end
end

local function bool(value)
    return value == true
end

---Accepts https/nui urls and paths relative to the ui (badges/examplebadge.png)
local function imageSource(value)
    if type(value) ~= 'string' or #value > 512 or value:find('[%s"\'()\\<>]') then return end
    if value:find('^https://') or value:find('^nui://') or value:find('^[%w_%-/]+%.%a+$') then return value end
end

local common = {
    x = clamp(-1000, 2000, 0),
    y = clamp(-1000, 2000, 0),
    w = clamp(1, 2000, 100),
    h = clamp(1, 2000, 20),
    rotate = clamp(-360, 360, 0),
    opacity = clamp(0, 1, 1),
}

local typography = {
    font = oneOf(FONTS, 'roboto'),
    size = clamp(4, 200, 14),
    weight = clamp(100, 900, 400),
    color = color('#000000'),
    align = oneOf(ALIGNS, 'left'),
    spacing = clamp(-10, 50, 0),
    uppercase = bool,
    italic = bool,
}

local frame = {
    radius = clamp(0, 1000, 0),
    borderWidth = clamp(0, 50, 0),
    borderColor = color('#000000'),
}

local schemas = {
    text = { common, typography, { text = text(200, '') } },
    field = { common, typography, {
        field = oneOf(FIELDS, 'fullname'),
        label = text(60, ''),
        labelSize = clamp(4, 100, 8),
        labelColor = color('#5c5f66'),
    } },
    photo = { common, frame, { grayscale = bool } },
    image = { common, frame, { src = imageSource, fit = oneOf(FITS, 'contain') } },
    rect = { common, frame, { fill = color('#000000') } },
}

local templateSchema = {
    label = text(50, 'Card'),
    kind = oneOf(KINDS, 'card'),
    width = clamp(100, 1000, 428),
    height = clamp(100, 1000, 270),
    radius = clamp(0, 500, 14),
    background = color('#ffffff'),
    backgroundImage = imageSource,
    prop = function(value)
        return type(value) == 'string' and #value <= 64 and value:match('^[%w_]+$') or nil
    end,
}

---@param raw table
---@param index integer
---@return table?
local function sanitizeElement(raw, index)
    if type(raw) ~= 'table' then return end
    local schema = schemas[raw.type]
    if not schema then return end

    local element = {
        id = type(raw.id) == 'string' and raw.id:match('^[%w_%-]+$') and raw.id:sub(1, 24) or ('e%d'):format(index),
        type = raw.type,
    }

    for i = 1, #schema do
        for key, sanitize in pairs(schema[i]) do
            element[key] = sanitize(raw[key])
        end
    end

    if element.type == 'image' and not element.src then return end
    return element
end

---@param raw any
---@return table?
local function sanitizeOffset(raw)
    if type(raw) ~= 'table' then return end
    local position, rotation = clamp(-2, 2, 0), clamp(-360, 360, 0)
    return {
        x = position(raw.x), y = position(raw.y), z = position(raw.z),
        rx = rotation(raw.rx), ry = rotation(raw.ry), rz = rotation(raw.rz),
    }
end

---@param raw any
---@return string[]?
local function sanitizeJobs(raw)
    if type(raw) ~= 'table' then return end
    local jobs = {}
    for i = 1, math.min(#raw, 32) do
        local job = raw[i]
        if type(job) == 'string' and #job <= 50 and job:match('^[%w_]+$') then
            jobs[#jobs + 1] = job
        end
    end
    return #jobs > 0 and jobs or nil
end

local templates = {}

---@param raw any
---@return table?
function templates.sanitize(raw)
    if type(raw) ~= 'table' then return end

    local template = {}
    for key, sanitize in pairs(templateSchema) do
        template[key] = sanitize(raw[key])
    end

    template.offset = sanitizeOffset(raw.offset)
    template.jobs = sanitizeJobs(raw.jobs)
    template.elements = {}

    local elements = type(raw.elements) == 'table' and raw.elements or {}
    for i = 1, math.min(#elements, MAX_ELEMENTS) do
        template.elements[#template.elements + 1] = sanitizeElement(elements[i], i)
    end

    return template
end

---@param item string
---@return table?
function templates.get(item)
    return cache[item]
end

---@return table<string, table>
function templates.all()
    return cache
end

---@param item string
---@param template table
---@param author string
function templates.save(item, template, author)
    MySQL.query.await('INSERT INTO qbx_idcard_templates (item, template, updated_by) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE template = VALUES(template), updated_by = VALUES(updated_by)', {
        item, json.encode(template), author
    })
    cache[item] = template
end

---@param item string
function templates.delete(item)
    MySQL.query.await('DELETE FROM qbx_idcard_templates WHERE item = ?', { item })
    cache[item] = nil
end

function templates.load()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS qbx_idcard_templates (
            item VARCHAR(100) NOT NULL PRIMARY KEY,
            template LONGTEXT NOT NULL,
            updated_by VARCHAR(100) NULL,
            updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ]])

    local rows = MySQL.query.await('SELECT item, template FROM qbx_idcard_templates')
    for i = 1, #rows do
        local row = rows[i]
        local ok, decoded = pcall(json.decode, row.template)
        cache[row.item] = ok and templates.sanitize(decoded) or nil
    end
end

return templates
