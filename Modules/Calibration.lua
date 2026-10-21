local _, ns = ...
local L = ns.L
local Dots = ns.Dots
local module = ns:NewModule("Calibration")
ns.Calibration = module

-- Calibración con el daño real. En combate no se puede leer el daño de los DoTs: el registro de combate está
-- cerrado y el medidor de daño de Blizzard (C_DamageMeter) es secreto (SecretWhenInCombat). Al salir de combate
-- sí: por cada hechizo del jugador da el daño real (combatSpells: spellID, totalAmount). Se compara con lo que
-- el addon creía que habían hecho sus DoTs (Dots.CombatEnd, sin factor) y se guarda un factor por hechizo y
-- personaje, que multiplica el daño de cada tick a partir de entonces. Recoge críticos, maestría y lo demás que
-- la descripción del hechizo no dice.
--
-- Solo se calibra con combates fiables:
--   - un único objetivo con DoTs y sin perder la pista de ninguno (identidad secreta, cambio de zona);
--   - el medidor disponible, legible y con una sesión de duración parecida a la del combate;
--   - por hechizo: al menos MIN_TICKS ticks, sin golpe directo en la descripción (Dots.IsMixed), con daño real
--     (si es 0, el DoT no entró: inmune o resistido) y una proporción entre MIN_RATIO y MAX_RATIO.
-- El factor guardado es una media ponderada por ticks, con memoria de MEMORY ticks: se adapta al equipo nuevo.
module.MIN_TICKS = 3
module.MIN_RATIO = 0.5
module.MAX_RATIO = 3
module.MEMORY = 60
module.DELAY = 1 -- segundos tras salir de combate, para que el medidor cierre la sesión

local function Debug(...)
    ns.Debug("calibración:", ...)
end

local function Store()
    ns.charDB.calibration = ns.charDB.calibration or {}
    return ns.charDB.calibration
end

-- Daño real por hechizo (nombre de la definición de DoT) del último combate, o nil y el motivo.
function module:ReadMeter(duration)
    local meter = C_DamageMeter
    if not meter or not meter.IsDamageMeterAvailable then
        return nil, "sin C_DamageMeter"
    end
    local available, reason = meter.IsDamageMeterAvailable()
    if not available then
        return nil, "medidor no disponible: " .. tostring(reason)
    end
    local current = Enum.DamageMeterSessionType.Current
    local seconds = meter.GetSessionDurationSeconds(current)
    if type(seconds) ~= "number" or issecretvalue(seconds) then
        return nil, "sesión sin duración"
    end
    if math.abs(seconds - duration) > math.max(5, duration * 0.25) then
        return nil, ("sesión de %.0f s y combate de %.0f s"):format(seconds, duration)
    end
    local guid = UnitGUID("player")
    if guid == nil or issecretvalue(guid) then
        return nil, "GUID del jugador secreto"
    end
    local source = meter.GetCombatSessionSourceFromType(current, Enum.DamageMeterType.DamageDone, guid)
    if type(source) ~= "table" or not canaccesstable(source) or type(source.combatSpells) ~= "table" then
        return nil, "sesión ilegible"
    end
    local real = {}
    for _, spell in ipairs(source.combatSpells) do
        local id, amount = spell.spellID, spell.totalAmount
        if
            type(id) == "number"
            and type(amount) == "number"
            and not issecretvalue(id)
            and not issecretvalue(amount)
        then
            local def = Dots.Definition(id)
            if def then
                real[def.name] = (real[def.name] or 0) + amount
            end
        end
    end
    return real
end

-- Aplica un combate terminado (lo que devuelve Dots.CombatEnd). Devuelve los calibrados: { nombre = proporción }.
function module:Apply(ledger)
    if not ns.db.calibrate or not ledger then
        return {}
    end
    if ledger.dirty then
        Debug("combate descartado: se perdió la pista de algún DoT")
        return {}
    end
    local targetsWithDots = 0
    for _ in pairs(ledger.keys) do
        targetsWithDots = targetsWithDots + 1
    end
    if targetsWithDots ~= 1 then
        Debug(("combate descartado: DoTs en %d objetivos"):format(targetsWithDots))
        return {}
    end
    local real, reason = self:ReadMeter(ledger.duration)
    if not real then
        Debug(reason)
        return {}
    end
    local store, applied = Store(), {}
    for name, spell in pairs(ledger.spells) do
        local amount = real[name] or 0
        local ratio = spell.predicted > 0 and amount / spell.predicted or 0
        if spell.mixed then
            Debug(name, "tiene golpe directo: no se calibra")
        elseif spell.ticks < self.MIN_TICKS then
            Debug(name, ("solo %d ticks"):format(spell.ticks))
        elseif amount <= 0 then
            Debug(name, "sin daño en el medidor (¿inmune o resistido?)")
        elseif ratio < self.MIN_RATIO or ratio > self.MAX_RATIO then
            Debug(name, ("proporción fuera de rango: %.2f"):format(ratio))
        else
            local old = store[name] or { factor = 1, ticks = 0 }
            local weight = math.min(old.ticks or 0, self.MEMORY)
            local factor = ((old.factor or 1) * weight + ratio * spell.ticks) / (weight + spell.ticks)
            store[name] = { factor = factor, ticks = weight + spell.ticks }
            applied[name] = ratio
            Debug(
                name,
                ("real %d, previsto %d (%.2f): factor %.2f"):format(
                    math.floor(amount),
                    math.floor(spell.predicted),
                    ratio,
                    factor
                )
            )
        end
    end
    Dots.SetFactors(store)
    return applied
end

function module:Refresh()
    Dots.SetFactors(ns.db.calibrate and Store() or {})
end

function module:Reset()
    wipe(Store())
    self:Refresh()
end

-- Líneas para /dotletal calibracion y el diagnóstico: "Agonía x1,12 (45 ticks)".
function module:Describe()
    local lines = {}
    for name, f in pairs(Store()) do
        lines[#lines + 1] = L.CALIBRATION_LINE:format(name, f.factor or 1, f.ticks or 0)
    end
    table.sort(lines)
    return lines
end

function module:OnEnable()
    self:Refresh()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_REGEN_DISABLED" then
            Dots.CombatStart(GetTime())
        else
            local ledger = Dots.CombatEnd(GetTime())
            C_Timer.After(module.DELAY, function()
                module:Apply(ledger)
            end)
        end
    end)
    self.frame = frame
end

function module:ApplySettings()
    self:Refresh()
end
