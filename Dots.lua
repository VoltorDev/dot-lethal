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

-- Datos de todos los DoTs que puede tener un jugador: Datos/Retail.lua y Datos/Forever.lua, generados por
-- tools/generar_datos.py con las tablas del cliente (wago.tools). Por hechizo: periodo de tick, si la celeridad
-- lo acelera, y familia y máscara de clase, con las que se ven los talentos que cambian el ritmo (ritmos). El
-- daño y la duración salen de la descripción del hechizo, que ya trae los talentos y el poder con hechizos.
-- Encima, lo que las tablas no dicen, aplicado por nombre (vale para todos los rangos):
--   weights: pesos fijos por tick (Maldición de agonía de Classic: los últimos pesan más).
--   ramp:    el daño sube un escalón por tick hasta `ramp` (Agonía de retail); reaplicarla conserva el escalón.
--   mode "tick": la descripción da el daño de cada tick (Succionar vida de Classic).
--   mode "max":  el daño es el mayor número antes de la duración (Putrefacción de alma: objetivo principal).
local AGONY_CLASSIC = { 0.5, 0.5, 0.5, 0.5, 1, 1, 1, 1, 1.5, 1.5, 1.5, 1.5 }
--   physical: sangrado (daño físico). Se puede esquivar o parar, y sus ticks no se distinguen de los golpes cuerpo
--             a cuerpo; ver Dots.OnCombat.
--   travel:   proyectil: el DoT empieza al impactar, así que el primer tick puede llegar hasta `travel` segundos
--             tarde (Does It Die midió 3,6-3,9 s en vez de 3 en Picadura de serpiente). Solo afecta a Dots.Housekeep.
local BLEED = { physical = true }
local PROJECTILE = { travel = 1.5 }
Dots.SPECIALS = {
    Forever = {
        [980] = { weights = AGONY_CLASSIC },
        [18265] = { mode = "tick" },
        [772] = BLEED, -- Desgarrar
        [703] = BLEED, -- Garrote
        [1943] = BLEED, -- Ruptura
        [1822] = BLEED, -- Arañazo
        [1079] = BLEED, -- Destripar
        [133] = PROJECTILE, -- Bola de Fuego
        [11366] = PROJECTILE, -- Piroexplosión
        [1978] = PROJECTILE, -- Picadura de serpiente
    },
    Retail = {
        [980] = { ramp = 8 },
        [386997] = { mode = "max" },
        [772] = BLEED,
        [703] = BLEED,
        [1943] = BLEED,
        [1822] = BLEED,
        [1079] = BLEED,
    },
}

-- Reglas del cliente. Retail: reaplicar conserva hasta un 30 % de la duración (pandemia). La celeridad acelera
-- los ticks de los DoTs que el juego marca así (en retail, todos; en Forever, ninguno).
local rules = { pandemic = false, data = { dots = {}, ritmos = {} }, specials = {} }
local PANDEMIC = 0.3

function Dots.Configure(isRetail)
    rules.pandemic = isRetail
    local key = isRetail and "Retail" or "Forever"
    rules.data = (ns.DATOS and ns.DATOS[key]) or { dots = {}, ritmos = {} }
    rules.specials = Dots.SPECIALS[key] or {}
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
        list[#list + 1] = {
            value = tonumber((digits:gsub("[%.,]", ""))),
            time = isTime,
            percent = spaced:match("^%%") ~= nil, -- "un 30 % del daño": no es daño
        }
    end
    return list
end

-- Devuelve daño total y duración (segundos) de un DoT a partir de su descripción, o nil. Los
-- porcentajes no cuentan como daño.
--   total: el número justo antes de la primera duración ("y otros 20 de daño durante 15 s" -> 20).
--   max:   el mayor número antes de la primera duración ("hasta 4 objetivos [...]; el principal
--          recibe 32 y los secundarios, 16, durante 8 s" -> 32).
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
            elseif not tick and not n.percent then
                tick = n.value
            end
        end
        if tick and duration and period and period > 0 then
            return tick * math.floor(duration / period + 0.5), duration
        end
        return nil
    end
    local largest, last
    for _, n in ipairs(numbers) do
        if n.time then
            local damage = (mode == "max") and largest or last
            if damage then
                return damage, n.value
            end
            return nil
        elseif not n.percent then
            largest = math.max(largest or n.value, n.value)
            last = n.value
        end
    end
    return nil
end

-- ¿Hay más de un número de daño antes de la duración? Un golpe directo ("inflige 200 y otros 1.800 durante
-- 18 s") o el daño de los objetivos secundarios. El medidor de daño suma ese daño con el del DoT, así que esos
-- hechizos no se calibran.
function Dots.IsMixed(text, mode)
    if mode == "tick" or type(text) ~= "string" then
        return false
    end
    local count = 0
    for _, n in ipairs(Numbers(text)) do
        if n.time then
            return count > 1
        elseif not n.percent then
            count = count + 1
        end
    end
    return false
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
    -- Al reaplicar con más celeridad que antes, el origen puede quedar en el futuro: aún no ha caído ninguno.
    local done = math.max(0, math.floor((now - entry.start) / entry.interval + 1e-6))
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
-- Con rampa, la descripción da el máximo ("hasta"): todos los ticks en el escalón más alto.
local function TickUnit(def, total, duration)
    if not def.ramp and not def.weights then
        -- Ticks iguales: el total entre los ticks exactos, con el último parcial si la duración no es un
        -- múltiplo del periodo (un talento de ritmo deja 14 s / 1,8 s = 7,78 ticks).
        return total / math.max(duration / def.period, 1)
    end
    local ticks = math.max(1, math.floor(duration / def.period + 0.5))
    if def.ramp then
        return total / (ticks * def.ramp)
    end
    local sum = 0
    for k = 1, ticks do
        sum = sum + Weight({ weights = def.weights }, k)
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
    local interval = def.period / (1 + (def.haste and haste or 0))
    -- Origen de los ticks: caen en start + k * interval. Lanzado de cero, el primero llega un intervalo después.
    local start = now
    if previous then
        local _, secs, _, done = Dots.Remaining(previous, now)
        if rules.pandemic and secs > 0 then
            duration = duration + math.min(secs, PANDEMIC * base)
            -- Reaplicar no reinicia el reloj de los ticks: el siguiente cae cuando tocaba y solo cambia el final,
            -- con un último tick parcial (dot_t::refresh de SimulationCraft). Con start = now, el addon restaba
            -- cada tick hasta un intervalo tarde y la franja naranja se quedaba entera mientras la vida bajaba.
            -- El origen pasa a ser el siguiente tick menos un intervalo, y la duración se cuenta desde ahí.
            local nextTick = previous.start + (done + 1) * previous.interval
            start = nextTick - interval
            duration = duration + (now - start)
        end
        if def.ramp and secs > 0 then
            level = math.min(previous.level + done, def.ramp - 1)
        end
    end
    local factor = Dots.Factor(def.name)
    if Dots.CAUTIOUS then
        -- Modo prudente: la calibración solo puede bajar el daño. Lo que la sube (críticos, sobre todo) no se
        -- da por hecho, y la calavera sale solo si los DoTs bastan sin ello.
        factor = math.min(factor, 1)
    end
    local entry = {
        start = start,
        duration = duration,
        base = base, -- duración de la descripción, sin lo arrastrado: mide la ventana de pandemia
        interval = interval,
        unit = TickUnit(def, total, base) * factor,
        weights = def.weights,
        ramp = def.ramp,
        level = level,
        -- Calibración (Modules/Calibration.lua): factor aplicado, daño total previsto con él y lo ya
        -- apuntado en el combate, sin el factor y en ticks.
        factor = factor,
        calName = def.name,
        calibrate = not Dots.IsMixed(description, def.mode),
        credited = 0,
        creditedTicks = 0,
        -- Respaldo de los fallos (Dots.Housekeep): si no se ve ningún tick, el DoT no entró.
        seen = false,
        missed = 0,
        checked = 0,
        travel = def.travel or 0,
    }
    entry.total = Dots.Remaining(entry, now)
    return entry
end

-- Renovación -----------------------------------------------------------------------------------------------
-- Cuándo volver a lanzar un DoT para no perder daño. Todo sale del reloj propio (números normales): las auras
-- del objetivo, secretas en combate, no se leen.
--   Forever (Vanilla): reaplicar sustituye al DoT entero, sin pandemia, y los ticks vuelven a empezar. Si el nuevo
--   llega antes del último tick del viejo, ese tick (y los que falten) se pierden; si llega tarde, solo se pierde
--   el rato sin DoT. Lo bueno es que llegue justo después del último tick: empezar a lanzarlo cuando le queden
--   `tiempo de lanzamiento` segundos (instantáneo: al caer).
--   Retail: hasta un 30 % de la duración se conserva (pandemia); basta con que llegue dentro de esa ventana.
-- Fases: "ok" (aún no), "soon" (prepárate: queda menos de LEAD para lanzarlo), "now" (lánzalo ya) y "dropped"
-- (se ha caído y sigues con el objetivo: relánzalo).
Dots.LEAD = 3 -- segundos de aviso previo (ámbar); lo cambia la opción renewLead
Dots.LATENCY = 0.1 -- margen para que el nuevo no llegue un pelo antes del último tick (Forever)
Dots.DROPPED_HOLD = 8 -- segundos que se avisa de un DoT caído si no se relanza
Dots.CAUTIOUS = false -- modo prudente (opción cautious): ver NewEntry

-- Fase de renovación de una entrada: fase y segundos que faltan para empezar a lanzarlo (0 si ya toca).
function Dots.RenewPhase(entry, now, castTime)
    local _, secs = Dots.Remaining(entry, now)
    if secs <= 0 then
        return "dropped", 0
    end
    -- Lo que le quedará al viejo cuando llegue el nuevo, si se empieza a lanzar ahora.
    local landing = secs - (castTime or 0)
    local open = rules.pandemic and PANDEMIC * (entry.base or entry.duration) or Dots.LATENCY
    local wait = landing - open
    if wait <= 0 then
        return "now", 0
    elseif wait <= Dots.LEAD then
        return "soon", wait
    end
    return "ok", wait
end

-- Tiempo de lanzamiento de un hechizo en segundos (C_Spell.GetSpellInfo().castTime, en milisegundos; ya trae los
-- talentos como Corrupción mejorada). Si llegara secreto, el último leído.
local castTimes = {}

function Dots.CastTime(spellID)
    if not spellID then
        return 0
    end
    local info = C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(spellID)
    local ms = info and info.castTime
    if type(ms) == "number" and not issecretvalue(ms) then
        castTimes[spellID] = math.max(ms, 0) / 1000
    end
    return castTimes[spellID] or 0
end

-- Calibración ----------------------------------------------------------------------------------------------
-- Por hechizo (nombre localizado): { factor, ticks } que guarda Modules/Calibration.lua por personaje. El factor
-- multiplica el daño de cada tick: recoge críticos, maestría y lo demás que la descripción no dice.
local factors = {}

function Dots.SetFactors(tbl)
    factors = tbl or {}
end

function Dots.Factor(name)
    local f = name and factors[name]
    return (f and type(f.factor) == "number" and f.factor > 0) and f.factor or 1
end

-- Lo que el addon cree que han hecho sus DoTs en el combate en curso, por hechizo, sin factor: { [nombre] =
-- { predicted, ticks, mixed } }. keys: objetivos distintos con DoTs; dirty: se perdió la pista de alguno.
local ledger = { active = false, spells = {}, keys = {} }

-- Ticks que tiene una entrada en total (el último parcial cuenta como uno).
local function LastTick(entry)
    local full, partial = TickCount(entry)
    return partial > 0 and full + 1 or full
end

-- Apunta en el combate lo que una entrada ha hecho desde la última vez. Fuera de combate solo avanza la marca,
-- para que lo hecho antes de entrar no cuente.
local function Credit(entry, now, key)
    if not entry.total then
        return
    end
    local left, _, _, done = Dots.Remaining(entry, now)
    -- Terminado, han caído todos, también el parcial del final (cae al acabar, antes de su intervalo entero).
    done = left <= 0 and LastTick(entry) or math.min(done, LastTick(entry))
    local raw = (entry.total - left) / entry.factor
    local delta, ticks = raw - entry.credited, done - entry.creditedTicks
    entry.credited, entry.creditedTicks = raw, done
    if not ledger.active or delta <= 1e-9 then
        return
    end
    local spell = ledger.spells[entry.calName or "?"]
    if not spell then
        spell = { predicted = 0, ticks = 0, mixed = false }
        ledger.spells[entry.calName or "?"] = spell
    end
    spell.predicted = spell.predicted + delta
    spell.ticks = spell.ticks + ticks
    spell.mixed = spell.mixed or not entry.calibrate
    ledger.keys[key or "?"] = true
end

-- Celeridad del jugador. En combate puede ser secreta: entonces se usa la última leída.
local lastHaste = 0

function Dots.Haste()
    local percent = UnitSpellHaste("player")
    if percent ~= nil and not issecretvalue(percent) then
        lastHaste = percent / 100
    end
    return lastHaste
end

-- Estado: DoTs por enemigo (Dots.UnitKey). La clave es el GUID cuando se puede leer. Si la identidad del PNJ es
-- secreta (mazmorras), la de su placa ("plate:nameplate3"), que no cambia mientras la placa está; si tampoco
-- tiene placa, solo se sigue el objetivo actual ("current") y se olvida al cambiarlo.
local CURRENT = "current"
local byID = {} -- spellID que se lanza -> definición
local byName = {} -- nombre localizado -> definición (otros rangos y variantes con otro ID)
local targets = {} -- clave -> { [nombre] = entrada }
local currentKey
-- DoTs que se han caído del objetivo actual sin relanzarlos: [nombre] = { name, icon, spellID, at }.
local dropped = {}
local pending -- último DoT lanzado cuyo resultado aún no se sabe: { key, name, entry, previous, at, landed }
local lastOutcome -- último resultado sobre un enemigo: { key, avoided, action, school, at }
-- Enemigo al que iba cada lanzamiento, apuntado al pulsarlo (UNIT_SPELLCAST_SENT) por castGUID. Un DoT instantáneo
-- da UNIT_SPELLCAST_SUCCEEDED un viaje al servidor después, y quien cambia de objetivo enseguida ya tiene otro: el
-- DoT acababa en el nuevo. Idea de Does It Die (MIT), reescrita.
local sent = {} -- castGUID -> { key, gen, at }; key = false si iba a algo que no se puede seguir
local SENT_SECONDS = 10
local targetGen = 0 -- sube con cada cambio de objetivo: "current" deja de ser el mismo enemigo
local seenSig, seenAt = {}, nil -- resultados ya tratados en este fotograma (llegan para target, placa y foco)
local feedAt -- último UNIT_COMBAT legible: prueba de que los golpes llegan al addon (ver Dots.Housekeep)

-- ¿Tiene el jugador ese hechizo o talento? C_SpellBook.IsSpellKnown (el IsPlayerSpell de siempre es ahora un
-- alias suyo, Deprecated_SpellBook.lua:11-14). INFERENCIA: comprobar en el cliente que ve los talentos pasivos.
local function Known(spellID)
    return C_SpellBook ~= nil and C_SpellBook.IsSpellKnown ~= nil and C_SpellBook.IsSpellKnown(spellID) == true
end
Dots.IsKnown = Known

-- ¿Comparten algún bit dos máscaras de 32 bits (pueden venir negativas)? Sin la librería bit, que el Lua de
-- los tests no tiene.
local function Common(a, b)
    a, b = (a or 0) % 4294967296, (b or 0) % 4294967296
    while a > 0 and b > 0 do
        if a % 2 == 1 and b % 2 == 1 then
            return true
        end
        a, b = math.floor(a / 2), math.floor(b / 2)
    end
    return false
end

local function Overlap(m1, m2)
    for i = 1, 4 do
        if Common(m1[i], m2[i]) then
            return true
        end
    end
    return false
end

-- Rehace las definiciones con los talentos actuales: periodo base por los talentos de ritmo que tenga el
-- jugador (misma familia de clase y máscara que se cruza), y lo especial por nombre.
function Dots.Rebuild()
    wipe(byID)
    wipe(byName)
    local talents = {}
    for _, r in ipairs(rules.data.ritmos or {}) do
        if Known(r.talento) then
            talents[#talents + 1] = r
        end
    end
    local specialByName = {}
    for spellID, special in pairs(rules.specials) do
        local name = C_Spell.GetSpellName(spellID)
        if name then
            specialByName[name] = special
        end
    end
    for spellID, d in pairs(rules.data.dots or {}) do
        local name = C_Spell.GetSpellName(spellID)
        if name then
            local def = {
                spellID = spellID,
                name = name,
                aura = d.aura,
                base = d.periodo,
                period = d.periodo,
                haste = d.prisa == true,
            }
            for _, r in ipairs(talents) do
                if r.familia == d.familia and Overlap(r.mascara, d.mascara) then
                    def.period = def.period * (1 + r.pct / 100)
                end
            end
            for key, value in pairs(specialByName[name] or {}) do
                def[key] = value
            end
            byID[spellID] = def
            if not byName[name] or (Known(spellID) and not Known(byName[name].spellID)) then
                byName[name] = def
            end
        end
    end
end

-- DoTs que tiene el personaje, por nombre y con su periodo actual: { "Corrupción (2s)", ... }.
function Dots.Known()
    local list, seen = {}, {}
    for spellID, def in pairs(byID) do
        if not seen[def.name] and Known(spellID) then
            seen[def.name] = true
            list[#list + 1] = ("%s (%ss)"):format(def.name, math.floor(def.period * 100 + 0.5) / 100)
        end
    end
    table.sort(list)
    return list
end

-- Definición de un DoT por su ID (o por su nombre), o nil.
function Dots.Definition(spellID)
    return byID[spellID] or byName[C_Spell.GetSpellName(spellID) or ""]
end

-- Token de la placa de un enemigo ("nameplate3"), o nil.
local function PlateToken(unit)
    if unit:match("^nameplate%d+$") then
        return unit
    end
    local plate = C_NamePlate and C_NamePlate.GetNamePlateForUnit and C_NamePlate.GetNamePlateForUnit(unit)
    if type(plate) ~= "table" then
        return nil
    end
    ---@type table?
    local unitFrame = plate.UnitFrame
    local token = plate.namePlateUnitToken or (unitFrame and unitFrame.unit)
    if type(token) ~= "string" or issecretvalue(token) or not token:match("^nameplate%d+$") then
        return nil
    end
    return token
end

-- Clave estable del enemigo detrás de una unidad, o nil si no se puede seguir (ver «Estado» arriba).
function Dots.UnitKey(unit)
    if type(unit) ~= "string" or not UnitExists(unit) then
        return nil
    end
    local guid = UnitGUID(unit)
    if guid ~= nil and not issecretvalue(guid) then
        return guid
    end
    local token = PlateToken(unit)
    if token then
        return "plate:" .. token
    end
    return unit == "target" and CURRENT or nil
end

local function TargetKey()
    return Dots.UnitKey("target") or CURRENT
end

-- Olvida los DoTs de un enemigo que ya no se puede seguir (su placa se ha ido o ha muerto). Si aún les quedaba daño,
-- el combate deja de servir para calibrar, salvo si ha muerto (dead): entonces sus DoTs ya no hacen nada.
function Dots.ForgetKey(key, now, dead)
    local dots = key and targets[key]
    if not dots then
        return
    end
    for _, entry in pairs(dots) do
        Credit(entry, now, key)
        if not dead and ledger.active and Dots.Remaining(entry, now) > 0 then
            ledger.dirty = true
        end
    end
    targets[key] = nil
    if pending and pending.key == key then
        pending = nil
    end
end

-- Con la identidad del PNJ secreta no se puede seguir al objetivo anterior: sus DoTs se olvidan. Si aún les quedaba
-- daño, el combate deja de servir para calibrar (el medidor contará ticks que el addon ya no ve).
function Dots.OnTargetChanged(now)
    now = now or GetTime()
    for _, entry in pairs(targets[CURRENT] or {}) do
        Credit(entry, now, CURRENT)
        if ledger.active and Dots.Remaining(entry, now) > 0 then
            ledger.dirty = true
        end
    end
    targets[CURRENT] = nil
    wipe(dropped)
    targetGen = targetGen + 1
    if pending and pending.key == CURRENT then
        pending = nil
    end
    currentKey = UnitExists("target") and TargetKey() or nil
end

-- El objetivo ha muerto: sus DoTs dejan de hacer daño ahora, no cuando el reloj del addon los daba por acabados.
function Dots.TargetDied(now)
    if currentKey and targets[currentKey] then
        for _, entry in pairs(targets[currentKey]) do
            Credit(entry, now, currentKey)
        end
        targets[currentKey] = nil
    end
    Dots.OnTargetChanged(now)
end

local function ReadableName(unit)
    local name = UnitName(unit)
    if type(name) == "string" and not issecretvalue(name) and name ~= "" then
        return name
    end
    return nil
end

-- ¿Se le puede poner un DoT a esa unidad? (existe, se puede atacar y no está muerta)
local function Hostile(unit)
    if not UnitExists(unit) or UnitIsDeadOrGhost(unit) then
        return false
    end
    local attackable = UnitCanAttack("player", unit)
    return issecretvalue(attackable) or attackable == true
end

-- A qué unidad va un lanzamiento. UNIT_SPELLCAST_SENT solo da el nombre: si coincide con el foco y no con el
-- objetivo (macro /cast [@focus]) va al foco, y si coincide con el enemigo suave (lanzar al ratón o al objetivo
-- suave) va a ese. Con un objetivo amistoso, el lanzamiento va al enemigo suave.
local function SentUnit(targetName)
    local attackable = UnitExists("target") and UnitCanAttack("player", "target")
    local default = (not issecretvalue(attackable) and attackable == false) and "softenemy" or "target"
    if type(targetName) ~= "string" or issecretvalue(targetName) or targetName == "" then
        return default
    end
    if ReadableName("target") == targetName then
        return default
    end
    for _, unit in ipairs({ "focus", "softenemy" }) do
        if ReadableName(unit) == targetName then
            return unit
        end
    end
    return default
end

-- El jugador pulsa un hechizo (UNIT_SPELLCAST_SENT): se apunta a qué enemigo va.
function Dots.OnCastSent(targetName, castGUID, now)
    for guid, info in pairs(sent) do
        if now - info.at > SENT_SECONDS then
            sent[guid] = nil
        end
    end
    if type(castGUID) ~= "string" or issecretvalue(castGUID) then
        return
    end
    local unit = SentUnit(targetName)
    local key = Hostile(unit) and Dots.UnitKey(unit) or false
    sent[castGUID] = { key = key, gen = targetGen, at = now }
end

-- Devuelve true si el hechizo era un DoT y se ha apuntado.
function Dots.OnCast(spellID, now, castGUID)
    if issecretvalue(spellID) then
        return false
    end
    local info = type(castGUID) == "string" and not issecretvalue(castGUID) and sent[castGUID]
    local key
    if info then
        sent[castGUID] = nil
        -- Iba a algo que no se puede seguir, o a "current" y desde entonces el objetivo es otro.
        if not info.key or (info.key == CURRENT and info.gen ~= targetGen) then
            return false
        end
        key = info.key
    else
        if not Hostile("target") then
            return false
        end
        currentKey = currentKey or TargetKey()
        key = currentKey
    end
    local def = Dots.Definition(spellID)
    if not def then
        return false
    end
    local name = C_Spell.GetSpellName(spellID) or def.name
    local dots = targets[key] or {}
    -- La descripción del hechizo lanzado; si no la entiende, la del aura que pone (Fuego lunar -> su DoT).
    local description = C_Spell.GetSpellDescription(spellID)
    local entry = Dots.NewEntry(def, description, now, Dots.Haste(), dots[name])
    if not entry and def.aura and def.aura ~= spellID then
        description = C_Spell.GetSpellDescription(def.aura)
        entry = Dots.NewEntry(def, description, now, Dots.Haste(), dots[name])
    end
    if not entry then
        ns.Debug("descripción no reconocida:", name, description)
        return false
    end
    entry.name, entry.icon, entry.spellID = name, C_Spell.GetSpellTexture(spellID), spellID
    entry.physical = def.physical == true
    if key == currentKey then
        dropped[name] = nil
    end
    local previous = dots[name]
    if previous then
        Credit(previous, now, key) -- lo que hizo la aplicación anterior hasta ahora
    end
    targets[key] = dots
    dots[name] = entry
    pending = { key = key, name = name, entry = entry, previous = previous, at = now }
    -- El resultado puede llegar un instante antes que UNIT_SPELLCAST_SUCCEEDED.
    local last = lastOutcome
    if last and last.avoided and last.key == key and now - last.at <= Dots.OUTCOME_LOOKBACK then
        Dots.OnCombat(key, last.action, last.school, now, true)
    end
    return true
end

-- Fallos ----------------------------------------------------------------------------------------------------
-- Un DoT fallado (fallo, resistido, inmune...) dispara UNIT_SPELLCAST_SUCCEEDED igual que uno que entra: el addon
-- lo daba por puesto y contaba su daño. Sin registro de combate, el aviso es UNIT_COMBAT sobre el objetivo, cuyo
-- tipo de resultado (MISS, RESIST, IMMUNE...) y escuela se leen también en combate; la cantidad es secreta y aquí
-- no se usa. UNIT_COMBAT no dice de qué ataque es el resultado, pero el del propio hechizo llega casi a la vez que
-- el lanzamiento: el primer resultado sobre el objetivo en esa ventana decide. Idea tomada de Does It Die (Joe
-- Greive, MIT), reescrita para este addon.
--   - Si un fallo de otro (tu mascota, otro jugador) cae en ese mismo instante, el DoT se quita aunque esté
--     puesto: el error es por lo bajo, nunca anuncia una muerte que no llega.
--   - Un hechizo no se esquiva ni se para: DODGE, PARRY y DEFLECT solo cuentan para los sangrados. Un fallo en
--     escuela física junto a un DoT de hechizo es un golpe cuerpo a cuerpo de otro.
--   - Con parte directa (Inmolar, Arañazo), si esa parte acierta solo un IMMUNE posterior quita el DoT (un
--     sangrado sobre un PNJ inmune a sangrados).
Dots.OUTCOME_WINDOW = 0.4
Dots.OUTCOME_LOOKBACK = 0.25
local AVOIDED = {
    MISS = true,
    RESIST = true,
    IMMUNE = true,
    EVADE = true,
    REFLECT = true,
    DODGE = true,
    PARRY = true,
    DEFLECT = true,
}
local MELEE_ONLY = { DODGE = true, PARRY = true, DEFLECT = true }
local PHYSICAL = 1 -- máscara de escuela física

-- ¿Ese resultado puede ser del DoT? `school` puede faltar o ser secreta: entonces no descarta nada.
local function CouldBeDot(entry, action, school)
    local known = type(school) == "number" and not issecretvalue(school)
    if entry.physical then
        return not known or school == PHYSICAL
    end
    if MELEE_ONLY[action] then
        return false
    end
    return not known or school ~= PHYSICAL
end

-- Segundos a cada lado de la hora prevista de un tick en los que un golpe cuenta como suyo (Does It Die midió en
-- Forever el primer tick a ~0,1 s de lo previsto).
Dots.TICK_WINDOW = 0.45

-- Un golpe (WOUND o ABSORB) sobre el enemigo `key`: si cae cuando tocaba un tick de un DoT aún sin ver, está puesto.
local function SeeTick(key, school, now)
    for _, entry in pairs(targets[key] or {}) do
        if not entry.seen and CouldBeDot(entry, "WOUND", school) then
            local k = math.floor((now - entry.start) / entry.interval + 0.5)
            local due = entry.start + math.max(k, 1) * entry.interval
            local late = now - due
            if late >= -Dots.TICK_WINDOW and late <= Dots.TICK_WINDOW + (k <= 1 and entry.travel or 0) then
                entry.seen = true
            end
        end
    end
end

-- Resultado de un ataque sobre un enemigo (UNIT_COMBAT; `key` = Dots.UnitKey de su unidad). Devuelve true si ha
-- quitado un DoT. `early`: un resultado guardado que llegó antes que el lanzamiento (no se vuelve a guardar).
function Dots.OnCombat(key, action, school, now, early)
    if not key or issecretvalue(action) or type(action) ~= "string" then
        return false
    end
    local avoided = AVOIDED[action] == true
    if not avoided and action ~= "WOUND" and action ~= "ABSORB" then
        return false
    end
    if not early then
        -- El mismo golpe llega para target, su placa, el foco...: se trata una vez.
        if seenAt ~= now then
            seenSig, seenAt = {}, now
        end
        local readable = type(school) == "number" and not issecretvalue(school)
        local sig = key .. ":" .. action .. ":" .. (readable and school or "?")
        if seenSig[sig] then
            return false
        end
        seenSig[sig] = true
        feedAt = now
        lastOutcome = { key = key, avoided = avoided, action = action, school = school, at = now }
        if not avoided then
            SeeTick(key, school, now)
        end
    end
    local cast = pending
    if not cast or cast.key ~= key then
        return false
    end
    if now - cast.at > Dots.OUTCOME_WINDOW then
        pending = nil
        return false
    end
    if not avoided then
        -- La parte directa del hechizo ha entrado (en un sangrado puede ser un golpe de otro: no se distinguen).
        if CouldBeDot(cast.entry, action, school) then
            cast.landed = true
        end
        return false
    end
    if (cast.landed and action ~= "IMMUNE") or not CouldBeDot(cast.entry, action, school) then
        return false
    end
    pending = nil
    local dots = targets[cast.key]
    if not dots or dots[cast.name] ~= cast.entry then
        return false
    end
    if cast.previous and Dots.Remaining(cast.previous, now) > 0 then
        dots[cast.name] = cast.previous -- relanzado y fallado: sigue el de antes
    else
        dots[cast.name] = nil
        if next(dots) == nil then
            targets[cast.key] = nil
        end
        if cast.key == currentKey then
            dropped[cast.name] = { name = cast.name, icon = cast.entry.icon, spellID = cast.entry.spellID, at = now }
        end
    end
    ns.Debug("DoT fallado:", cast.name, action)
    return true
end

-- Respaldo de los fallos que no se avisan: un DoT del que no se ha visto ningún tick tras MISSED_TICKS ticks que se
-- podían ver no está puesto. Solo cuentan los ticks de enemigos a la vista (`observed[clave]`: objetivo, foco y
-- placas visibles), porque UNIT_COMBAT solo llega para unidades: el de un enemigo sin placa cae sin que se vea.
Dots.MISSED_TICKS = 2
-- Un tick sin ver solo cuenta si hace poco llegó algún UNIT_COMBAT legible: si el cliente dejara de mandarlos (o
-- en un rato sin golpes de nadie), quitar los DoTs por no ver sus ticks sería un error.
Dots.FEED_SECONDS = 15

function Dots.Housekeep(now, observed)
    for key, dots in pairs(targets) do
        for name, entry in pairs(dots) do
            if not entry.seen then
                local due = 0 -- ticks cuya hora (más el margen) ya ha pasado
                local total = LastTick(entry)
                while due < total do
                    local k = due + 1
                    local limit = entry.start + k * entry.interval + Dots.TICK_WINDOW + (k == 1 and entry.travel or 0)
                    if limit >= now then
                        break
                    end
                    due = k
                end
                if due > entry.checked then
                    local feeding = feedAt and now - feedAt <= Dots.FEED_SECONDS
                    if feeding and observed and observed[key] then
                        entry.missed = entry.missed + (due - entry.checked)
                    end
                    entry.checked = due
                end
                if entry.missed >= Dots.MISSED_TICKS then
                    dots[name] = nil
                    Credit(entry, now, key)
                    if key == currentKey then
                        dropped[name] = { name = name, icon = entry.icon, spellID = entry.spellID, at = now }
                    end
                    ns.Debug("DoT sin ticks, quitado:", name)
                end
            end
            -- Terminado en un enemigo que no es el objetivo (el del objetivo lo borra TargetState, que avisa de
            -- que ha caído): fuera, para que el reloj del addon no siga en marcha por nada.
            if dots[name] and key ~= currentKey then
                Credit(entry, now, key)
                if Dots.Remaining(entry, now) <= 0 then
                    dots[name] = nil
                end
            end
        end
        if next(dots) == nil then
            targets[key] = nil
        end
    end
end

-- Daño que les queda a los DoTs propios sobre el enemigo `key` (para las placas y el foco). Borra lo terminado.
function Dots.DamageFor(key, now)
    local dots = key and targets[key]
    if not dots then
        return 0
    end
    local damage = 0
    for name, entry in pairs(dots) do
        Credit(entry, now, key)
        local left = Dots.Remaining(entry, now)
        if left <= 0 then
            dots[name] = nil
        else
            damage = damage + left
        end
    end
    if next(dots) == nil then
        targets[key] = nil
    end
    return damage
end

-- ¿Queda algún DoT propio apuntado en algún enemigo?
function Dots.HasAny()
    return next(targets) ~= nil
end

-- Estado de los DoTs propios sobre el objetivo actual:
--   damage: daño que les queda en total; dps: daño por segundo ahora; list: uno por DoT
--   { name, icon, damage, seconds, dps, phase, wait }, de menos a más tiempo (phase y wait: Dots.RenewPhase).
--   alerts: los que piden atención, de más a menos urgente: { name, icon, phase, wait }; incluye los caídos.
-- Borra lo que ya ha terminado (y lo apunta como caído).
local URGENCY = { dropped = 1, now = 2, soon = 3 }

function Dots.TargetState(now)
    local state = { damage = 0, dps = 0, list = {}, alerts = {} }
    local dots = currentKey and targets[currentKey]
    for name, entry in pairs(dots or {}) do
        Credit(entry, now, currentKey)
        local left, secs, dps = Dots.Remaining(entry, now)
        if left <= 0 then
            dots[name] = nil
            local ended = entry.start + entry.duration
            dropped[name] = { name = name, icon = entry.icon, spellID = entry.spellID, at = ended }
        else
            local phase, wait = Dots.RenewPhase(entry, now, Dots.CastTime(entry.spellID))
            state.damage = state.damage + left
            state.dps = state.dps + dps
            local item = {
                name = name,
                icon = entry.icon,
                damage = left,
                seconds = secs,
                dps = dps,
                phase = phase,
                wait = wait,
            }
            state.list[#state.list + 1] = item
            if phase ~= "ok" then
                state.alerts[#state.alerts + 1] = item
            end
        end
    end
    for name, drop in pairs(dropped) do
        if now - drop.at > Dots.DROPPED_HOLD then
            dropped[name] = nil
        else
            state.alerts[#state.alerts + 1] = { name = name, icon = drop.icon, phase = "dropped", wait = 0 }
        end
    end
    table.sort(state.list, function(a, b)
        return a.seconds < b.seconds
    end)
    table.sort(state.alerts, function(a, b)
        if URGENCY[a.phase] ~= URGENCY[b.phase] then
            return URGENCY[a.phase] < URGENCY[b.phase]
        end
        if a.wait ~= b.wait then
            return a.wait < b.wait
        end
        return a.name < b.name
    end)
    if dots and next(dots) == nil then
        targets[currentKey] = nil
    end
    return state
end

-- Olvida los objetivos cuyos DoTs ya han terminado (los GUID de enemigos que no volvemos a ver).
function Dots.Prune(now)
    for key, dots in pairs(targets) do
        for name, entry in pairs(dots) do
            Credit(entry, now, key)
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
    if ledger.active and next(targets) ~= nil then
        ledger.dirty = true
    end
    wipe(targets)
    wipe(dropped)
    wipe(sent)
    pending, lastOutcome, feedAt = nil, nil, nil
    currentKey = nil
end

-- Combate: al entrar empieza la cuenta (lo hecho antes no cuenta); al salir se apunta lo que falte de cada DoT y se
-- devuelve { spells, keys, dirty, duration } para compararlo con el medidor de daño.
function Dots.CombatStart(now)
    ledger.active = false
    for key, dots in pairs(targets) do
        for _, entry in pairs(dots) do
            Credit(entry, now, key)
        end
    end
    ledger = { active = true, started = now, spells = {}, keys = {}, dirty = false }
end

function Dots.CombatEnd(now)
    if not ledger.active then
        return nil
    end
    for key, dots in pairs(targets) do
        for _, entry in pairs(dots) do
            Credit(entry, now, key)
        end
    end
    ledger.active = false
    ledger.duration = now - ledger.started
    return ledger
end
