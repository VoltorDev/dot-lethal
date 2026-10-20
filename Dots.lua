local _, ns = ...

-- Seguimiento de los DoTs propios sobre el objetivo y del daño que les queda por hacer.
--
-- En Forever no se puede leer el registro de combate y, en combate, las auras del objetivo son
-- secretas. Por eso el addon lleva su propio reloj: cuando el jugador termina de lanzar un DoT
-- (UNIT_SPELLCAST_SUCCEEDED de "player", que no es secreto) apunta la hora y lee de la descripción
-- del hechizo el daño total y la duración, que ya incluyen el poder con hechizos actual.
-- Todo lo que sale de aquí son números normales: el único secreto (la vida del objetivo) no entra
-- en este fichero; lo compara la barra de estado del indicador sin que el addon lo toque.
local Dots = {}
ns.Dots = Dots

-- Catálogo: spellID del rango 1 (el nombre se saca del cliente, así vale para todos los rangos y
-- cualquier idioma), segundos entre ticks y, si los ticks no son iguales, su peso relativo.
-- mode "tick": la descripción da el daño de cada tick ("15 de vida cada 3 s durante 30 s").
-- Los ID son los de Classic Era (INFERENCIA: comprobar en el cliente de Forever con /dotletal lista).
local AGONY_WEIGHTS = { 0.5, 0.5, 0.5, 0.5, 1, 1, 1, 1, 1.5, 1.5, 1.5, 1.5 }
-- stylua: ignore start
Dots.CATALOG = {
    [172]   = { period = 3 },                           -- Corrupción
    [980]   = { period = 2, weights = AGONY_WEIGHTS },  -- Maldición de agonía
    [348]   = { period = 3 },                           -- Inmolar
    [18265] = { period = 3, mode = "tick" },            -- Succionar vida
    [589]   = { period = 3 },                           -- Palabra de las Sombras: dolor
    [2944]  = { period = 3 },                           -- Peste devoradora
    [8921]  = { period = 3 },                           -- Fuego lunar
    [5570]  = { period = 2 },                           -- Enjambre de insectos
    [1822]  = { period = 3 },                           -- Arañazo
    [1978]  = { period = 3 },                           -- Picadura de serpiente
    [8050]  = { period = 3 },                           -- Choque de llamas
    [772]   = { period = 3 },                           -- Desgarrar
    [703]   = { period = 3 },                           -- Garrote
    [11366] = { period = 3 },                           -- Piroexplosión
}
-- stylua: ignore end

-- Números de una descripción, con la posición donde acaban. "1,234" (inglés) y "1.234" (español)
-- son mil doscientos treinta y cuatro: los DoTs no tienen decimales.
local function Numbers(text)
    local list = {}
    for token, finish in text:gmatch("(%d[%d%.,]*)()") do
        local digits = token:gsub("[%.,]+$", "")
        local after = text:sub(finish - (#token - #digits))
        -- Unidad de tiempo detrás del número: "sec", "seg", "s" suelta (también tras espacio duro).
        local spaced = after:match("^[%s\194\160]*(.*)$")
        local isTime = spaced:match("^se[cg]") ~= nil or spaced:match("^s[^%a]") ~= nil or spaced == "s"
        list[#list + 1] = { value = tonumber((digits:gsub("[%.,]", ""))), time = isTime }
    end
    return list
end

-- Devuelve daño total y duración (segundos) de un DoT a partir de su descripción, o nil.
--   total: el número justo antes de la primera duración ("y otros 20 de daño durante 15 s" -> 20).
--   tick:  el primer número es el daño de cada tick; la duración, la última que aparezca.
function Dots.ParseDescription(text, mode, period)
    if type(text) ~= "string" or text == "" then
        return nil
    end
    local numbers = Numbers(text)
    if mode == "tick" then
        local tick, duration
        for _, n in ipairs(numbers) do
            if n.time then
                duration = n.value
            elseif not tick then
                tick = n.value
            end
        end
        if tick and duration and period and period > 0 then
            return tick * math.floor(duration / period + 0.5), duration
        end
        return nil
    end
    for i, n in ipairs(numbers) do
        if n.time then
            local before = numbers[i - 1]
            if before and not before.time then
                return before.value, n.value
            end
            return nil
        end
    end
    return nil
end

-- Daño y tiempo que le quedan a un DoT en `now`. Los ticks caen en start + k * period.
function Dots.Remaining(entry, now)
    local done = math.floor((now - entry.start) / entry.period + 1e-6)
    if done >= entry.ticks then
        return 0, 0
    end
    local left, all = 0, 0
    for k = 1, entry.ticks do
        local w = entry.weights and entry.weights[k] or 1
        all = all + w
        if k > done then
            left = left + w
        end
    end
    return entry.total * left / all, entry.start + entry.ticks * entry.period - now
end

-- Construye la entrada de un hechizo recién lanzado o nil si no es un DoT conocido o no se
-- entiende su descripción.
function Dots.NewEntry(def, description, now)
    local total, duration = Dots.ParseDescription(description, def.mode, def.period)
    if not total or total <= 0 or not duration or duration <= 0 then
        return nil
    end
    local ticks = math.floor(duration / def.period + 0.5)
    if ticks < 1 then
        return nil
    end
    return { start = now, period = def.period, ticks = ticks, total = total, weights = def.weights }
end

-- Estado: DoTs por objetivo. La clave es el GUID cuando se puede leer; si la identidad del PNJ es
-- secreta (no se puede usar de clave), solo se sigue el objetivo actual y se olvida al cambiarlo.
local CURRENT = "current"
local byName = {} -- nombre localizado -> definición
local targets = {} -- clave -> { [nombre] = entrada }
local currentKey

function Dots.Rebuild(custom)
    wipe(byName)
    for spellID, def in pairs(Dots.CATALOG) do
        local name = C_Spell.GetSpellName(spellID)
        if name then
            byName[name] = def
        end
    end
    for name, period in pairs(custom or {}) do
        byName[name] = { period = period }
    end
end

function Dots.Known()
    local list = {}
    for name, def in pairs(byName) do
        list[#list + 1] = ("%s (%ss)"):format(name, def.period)
    end
    table.sort(list)
    return list
end

local function TargetKey()
    local guid = UnitGUID("target")
    if guid == nil or issecretvalue(guid) then
        return CURRENT
    end
    return guid
end

function Dots.OnTargetChanged()
    targets[CURRENT] = nil
    currentKey = UnitExists("target") and TargetKey() or nil
end

-- Devuelve true si el hechizo era un DoT y se ha apuntado.
function Dots.OnCast(spellID, now)
    if issecretvalue(spellID) or not UnitExists("target") or UnitIsDeadOrGhost("target") then
        return false
    end
    local attackable = UnitCanAttack("player", "target")
    if not issecretvalue(attackable) and not attackable then
        return false
    end
    local name = C_Spell.GetSpellName(spellID)
    local def = name and byName[name]
    if not def then
        return false
    end
    local entry = Dots.NewEntry(def, C_Spell.GetSpellDescription(spellID), now)
    if not entry then
        ns.Debug("descripción no reconocida:", name, C_Spell.GetSpellDescription(spellID))
        return false
    end
    currentKey = currentKey or TargetKey()
    targets[currentKey] = targets[currentKey] or {}
    targets[currentKey][name] = entry -- reaplicar reinicia el DoT: los ticks pendientes se pierden
    return true
end

-- Daño que les queda a los DoTs propios sobre el objetivo actual y cuánto dura el último.
-- Borra lo que ya ha terminado.
function Dots.TargetRemaining(now)
    local dots = currentKey and targets[currentKey]
    if not dots then
        return 0, 0
    end
    local damage, longest = 0, 0
    for name, entry in pairs(dots) do
        local left, secs = Dots.Remaining(entry, now)
        if left <= 0 then
            dots[name] = nil
        else
            damage = damage + left
            longest = math.max(longest, secs)
        end
    end
    if next(dots) == nil then
        targets[currentKey] = nil
    end
    return damage, longest
end

-- Olvida los objetivos cuyos DoTs ya han terminado (los GUID de enemigos que no volvemos a ver).
function Dots.Prune(now)
    for key, dots in pairs(targets) do
        for name, entry in pairs(dots) do
            if Dots.Remaining(entry, now) <= 0 then
                dots[name] = nil
            end
        end
        if next(dots) == nil then
            targets[key] = nil
        end
    end
end

function Dots.Clear()
    wipe(targets)
    currentKey = nil
end
