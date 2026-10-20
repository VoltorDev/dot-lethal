local addonName, ns = ...
local L = ns.L

ns.name = addonName
ns.version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "dev"

-- SavedVariables. Solo se guardan strings, números, booleanos y tablas.
-- `schema` es la versión del formato: súbela y añade una migración cuando cambies su forma.
ns.DEFAULTS = {
    schema = 1,
    enabled = true,
    scale = 1,
    mode = "classic",
    locked = true,
    panel = true, -- panel propio con la lista de DoTs
    targetFrame = true, -- marca en la barra de vida del marco de objetivo
    nameplate = true, -- marca en la placa del objetivo
    debug = false,
    frame = { point = "CENTER", relativePoint = "CENTER", x = 0, y = -180 },
    custom = {}, -- DoTs añadidos a mano: nombre del hechizo -> segundos entre ticks
}
ns.CHAR_DEFAULTS = {
    schema = 1,
}

-- MIGRATIONS[n] convierte la base de datos de cuenta del esquema n-1 al n; CHAR_MIGRATIONS hace lo
-- mismo con la de personaje (cada una tiene su propio `schema`). Ejemplo:
-- [2] = function(db) db.newName = db.oldName; db.oldName = nil end,
local MIGRATIONS = {}
local CHAR_MIGRATIONS = {}

local function MergeDefaults(db, defaults)
    for key, value in pairs(defaults) do
        if type(value) == "table" then
            if type(db[key]) ~= "table" then
                db[key] = {}
            end
            MergeDefaults(db[key], value)
        elseif db[key] == nil then
            db[key] = value
        end
    end
end

-- Una tabla guardada con un esquema MÁS NUEVO (versión posterior del addon) no se toca:
-- el bucle no se ejecuta y solo se completan los valores por defecto que falten.
local function PrepareDB(saved, defaults, migrations)
    if type(saved) ~= "table" then
        saved = {}
    end
    if next(saved) ~= nil then
        for version = (saved.schema or 1) + 1, defaults.schema do
            local migrate = migrations[version]
            if migrate then
                migrate(saved)
            end
            saved.schema = version
        end
    end
    MergeDefaults(saved, defaults)
    return saved
end

function ns:ResetDB()
    wipe(DoTLetalDB)
    MergeDefaults(DoTLetalDB, self.DEFAULTS)
end

function ns:Print(...)
    print("|cff33ff99" .. L.ADDON_TITLE .. "|r:", ...)
end

-- Trazas para depurar (/dotletal traza). Nunca reciben secretos.
function ns.Debug(...)
    if ns.db and ns.db.debug then
        print("|cff33ff99" .. L.ADDON_TITLE .. "|r [traza]", ...)
    end
end

-- Módulos: cada fichero crea el suyo con ns:NewModule(nombre) y define, si los necesita,
-- OnInitialize (SavedVariables ya cargadas) y OnEnable (personaje en el mundo, PLAYER_LOGIN).
local modules = {}

function ns:NewModule(name)
    local module = { name = name }
    modules[#modules + 1] = module
    return module
end

local function CallModules(method)
    for _, module in ipairs(modules) do
        if module[method] then
            module[method](module)
        end
    end
end

-- Despachador de eventos globales: varios manejadores por evento, cada uno recibe (ns, evento, ...).
-- Para eventos de una unidad concreta, usa RegisterUnitEvent en un marco propio del módulo.
local eventFrame = CreateFrame("Frame")
local handlers = {}

function ns:RegisterEvent(event, handler)
    if not handlers[event] then
        handlers[event] = {}
        eventFrame:RegisterEvent(event)
    end
    table.insert(handlers[event], handler)
end

-- Quita un manejador concreto; el marco deja de escuchar el evento cuando no queda ninguno.
function ns:UnregisterEvent(event, handler)
    local list = handlers[event]
    if not list then
        return
    end
    for i = #list, 1, -1 do
        if list[i] == handler then
            table.remove(list, i)
        end
    end
    if #list == 0 then
        handlers[event] = nil
        eventFrame:UnregisterEvent(event)
    end
end

eventFrame:SetScript("OnEvent", function(_, event, ...)
    local list = handlers[event]
    if not list then
        return
    end
    -- Copia: un manejador puede desregistrarse mientras se recorre la lista.
    local snapshot = { unpack(list) }
    for i = 1, #snapshot do
        snapshot[i](ns, event, ...)
    end
end)

local function OnAddonLoaded(self, event, loadedName)
    if loadedName ~= addonName then
        return
    end
    self:UnregisterEvent(event, OnAddonLoaded)
    DoTLetalDB = PrepareDB(DoTLetalDB, self.DEFAULTS, MIGRATIONS)
    DoTLetalCharDB = PrepareDB(DoTLetalCharDB, self.CHAR_DEFAULTS, CHAR_MIGRATIONS)
    self.db = DoTLetalDB
    self.charDB = DoTLetalCharDB
    CallModules("OnInitialize")
end
ns:RegisterEvent("ADDON_LOADED", OnAddonLoaded)

local function OnPlayerLogin(self, event)
    self:UnregisterEvent(event, OnPlayerLogin)
    CallModules("OnEnable")
    self:Print(self.version, L.LOADED)
end
ns:RegisterEvent("PLAYER_LOGIN", OnPlayerLogin)

-- Notifica a los módulos que han cambiado las opciones.
function ns:ApplySettings()
    CallModules("ApplySettings")
end
