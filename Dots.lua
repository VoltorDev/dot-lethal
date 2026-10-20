local _, ns = ...

-- Seguimiento de los DoTs propios sobre el objetivo: daño que les queda, daño por segundo y tiempo.
--
-- Ni en Forever ni en retail (Midnight) se puede leer el registro de combate, y en combate las auras
-- del objetivo son secretas. Por eso el addon lleva su propio reloj: cuando el jugador termina de
-- lanzar un DoT (UNIT_SPELLCAST_SUCCEEDED de "player", que no es secreto) apunta la hora y lee de la
-- descripción del hechizo el daño total y la duración, que ya incluyen su poder con hechizos.
-- Todo lo que sale de aquí son números normales: el único secreto (la vida del objetivo) no entra
-- en este fichero; lo comparan las barras de Marker.lua sin que el addon lo toque.
local Dots = {}
ns.Dots = Dots

-- Catálogos: spellID que se lanza -> segundos entre ticks sin celeridad y reparto del daño.
-- El nombre se saca del cliente, así vale para todos los rangos, talentos que cambian el ID y
-- cualquier idioma. mode "tick": la descripción da el daño de cada tick.
--   weights: pesos fijos por tick (Maldición de agonía de Classic: los últimos pesan más).
--   ramp:    el daño sube un escalón por tick hasta `ramp` (Agonía de retail); reaplicarla
--            conserva el escalón.
-- Los ID y los periodos son de memoria (INFERENCIA): /dotletal lista enseña cuáles existen en el
-- cliente y /dotletal añadir completa los que falten.
local AGONY_CLASSIC = { 0.5, 0.5, 0.5, 0.5, 1, 1, 1, 1, 1.5, 1.5, 1.5, 1.5 }
-- stylua: ignore start
Dots.CATALOGS = {
    Forever = {
        [172]   = { period = 3 },                           -- Corrupción
        [980]   = { period = 2, weights = AGONY_CLASSIC },  -- Maldición de agonía
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
    },
    Retail = {
        [980]    = { period = 2, ramp = 10 },  -- Agonía
        [172]    = { period = 2 },             -- Corrupción
        [316099] = { period = 2 },             -- Aflicción inestable
        [63106]  = { period = 3 },             -- Succionar vida
        [445468] = { period = 2 },             -- Marchitar (Hellcaller)
        [386997] = { period = 2 },             -- Putrefacción de alma
        [348]    = { period = 3 },             -- Inmolar
        [589]    = { period = 2 },             -- Palabra de las Sombras: dolor
        [34914]  = { period = 3 },             -- Toque vampírico
        [335467] = { period = 3 },             -- Peste devoradora
        [8921]   = { period = 2 },             -- Fuego lunar
        [93402]  = { period = 2 },             -- Fuego solar
        [202347] = { period = 2 },             -- Bengala estelar
        [1822]   = { period = 3 },             -- Arañazo
        [106830] = { period = 3 },             -- Vapulear (felino)
        [188389] = { period = 2 },             -- Choque de llamas
        [703]    = { period = 2 },             -- Garrote
        [772]    = { period = 3 },             -- Desgarrar
        [271788] = { period = 3 },             -- Picadura de serpiente
    },
}
-- stylua: ignore end

-- Reglas del cliente. Retail: la celeridad acelera los ticks (y suma daño) y reaplicar conserva
-- hasta un 30 % de la duración (pandemia). Forever, contenido Vanilla: ni lo uno ni lo otro
-- (INFERENCIA: comprobar en el cliente si la celeridad acelera los DoTs).
local rules = { haste = false, pandemic = false, catalog = Dots.CATALOGS.Forever }
local PANDEMIC = 0.3

function Dots.Configure(isRetail)
    rules.haste = isRetail
    rules.pandemic = isRetail
    rules.catalog = isRetail and Dots.CATALOGS.Retail or Dots.CATALOGS.Forever
end

-- Números de una descripción y si van seguidos de una unidad de tiempo. "1,234" (inglés) y
-- "1.234" (español) son mil doscientos treinta y cuatro: los DoTs no tienen decimales.
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

-- Peso del tick k (1, 2, ...) de una entrada.
local function Weight(entry, k)
    if entry.weights then
        return entry.weights[k] or 1
    end
    if entry.ramp then
        return math.min(entry.level + k, entry.ramp)
    end
    return 1
end

-- Ticks que caben en la duración con la celeridad: los completos y la fracción del último.
local function TickCount(entry)
    local exact = entry.duration / entry.interval
    local full = math.floor(exact + 1e-6)
    return full, exact - full > 1e-3 and exact - full or 0
end

-- Daño que le queda a un DoT en `now`, segundos hasta que acaba, daño por segundo del tick
-- siguiente y ticks ya caídos. Los ticks caen en start + k * interval; si la duración no es un
-- múltiplo exacto, el último es parcial (como en retail con celeridad).
function Dots.Remaining(entry, now)
    local done = math.floor((now - entry.start) / entry.interval + 1e-6)
    local full, partial = TickCount(entry)
    local last = partial > 0 and full + 1 or full
    if done >= last or now >= entry.start + entry.duration then
        return 0, 0, 0, done
    end
    local left = 0
    for k = done + 1, last do
        local share = (k > full) and partial or 1
        left = left + entry.unit * Weight(entry, k) * share
    end
    local dps = entry.unit * Weight(entry, done + 1) / entry.interval
    return left, entry.start + entry.duration - now, dps, done
end

-- Daño de un tick con peso 1: el total de la descripción repartido entre sus ticks sin celeridad.
local function TickUnit(def, total, duration, level)
    local ticks = math.max(1, math.floor(duration / def.period + 0.5))
    local sum = 0
    for k = 1, ticks do
        sum = sum + Weight({ weights = def.weights, ramp = def.ramp, level = level }, k)
    end
    return total / sum
end

-- Entrada de un hechizo recién lanzado, o nil si no se entiende su descripción.
--   haste:    celeridad en tanto por uno (0.25 = 25 %).
--   previous: la entrada que sustituye al reaplicar, para la pandemia y la rampa.
function Dots.NewEntry(def, description, now, haste, previous)
    local total, duration = Dots.ParseDescription(description, def.mode, def.period)
    if not total or total <= 0 or not duration or duration <= 0 then
        return nil
    end
    local level = 0
    local base = duration
    if previous then
        local _, secs, _, done = Dots.Remaining(previous, now)
        if rules.pandemic and secs > 0 then
            duration = duration + math.min(secs, PANDEMIC * base)
        end
        if def.ramp and secs > 0 then
            level = math.min(previous.level + done, def.ramp - 1)
        end
    end
    return {
        start = now,
        duration = duration,
        interval = def.period / (1 + (haste or 0)),
        unit = TickUnit(def, total, base, 0),
        weights = def.weights,
        ramp = def.ramp,
        level = level,
    }
end

-- Celeridad del jugador. En combate puede ser secreta: entonces se usa la última leída.
local lastHaste = 0

function Dots.Haste()
    if not rules.haste then
        return 0
    end
    local percent = UnitSpellHaste("player")
    if percent ~= nil and not issecretvalue(percent) then
        lastHaste = percent / 100
    end
    return lastHaste
end

-- Estado: DoTs por objetivo. La clave es el GUID cuando se puede leer; si la identidad del PNJ es
-- secreta (no se puede usar de clave), solo se sigue el objetivo actual y se olvida al cambiarlo.
local CURRENT = "current"
local byName = {} -- nombre localizado -> definición
local targets = {} -- clave -> { [nombre] = entrada }
local currentKey

function Dots.Rebuild(custom)
    wipe(byName)
    for spellID, def in pairs(rules.catalog) do
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
    currentKey = currentKey or TargetKey()
    local dots = targets[currentKey] or {}
    local description = C_Spell.GetSpellDescription(spellID)
    local entry = Dots.NewEntry(def, description, now, Dots.Haste(), dots[name])
    if not entry then
        ns.Debug("descripción no reconocida:", name, description)
        return false
    end
    entry.name, entry.icon = name, C_Spell.GetSpellTexture(spellID)
    targets[currentKey] = dots
    dots[name] = entry
    return true
end

-- Estado de los DoTs propios sobre el objetivo actual:
--   damage: daño que les queda en total; dps: daño por segundo ahora; list: uno por DoT
--   { name, icon, damage, seconds, dps }, de menos a más tiempo. Borra lo que ya ha terminado.
function Dots.TargetState(now)
    local state = { damage = 0, dps = 0, list = {} }
    local dots = currentKey and targets[currentKey]
    if not dots then
        return state
    end
    for name, entry in pairs(dots) do
        local left, secs, dps = Dots.Remaining(entry, now)
        if left <= 0 then
            dots[name] = nil
        else
            state.damage = state.damage + left
            state.dps = state.dps + dps
            state.list[#state.list + 1] = { name = name, icon = entry.icon, damage = left, seconds = secs, dps = dps }
        end
    end
    table.sort(state.list, function(a, b)
        return a.seconds < b.seconds
    end)
    if next(dots) == nil then
        targets[currentKey] = nil
    end
    return state
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
