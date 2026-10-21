-- Modules/Calibration.lua y la cuenta de Dots.lua: al salir de combate se compara el daño real de cada DoT
-- (medidor de daño simulado en wow_env, secreto en combate) con lo que el addon creía que había hecho.
local WowEnv = require("wow_env")

local TOC = "DoTLetal.toc"
local RETAIL_BUILD = { "12.1.5", "99999", "Oct 1 2026", 120105 }
local SPELLS = {
    -- 1400 en 14 s: 7 ticks de 200 cada 2 s.
    [172] = { "Corrupción", "Corrompe al objetivo y le inflige 1.400 p. de daño de Sombras durante 14 s." },
    -- Golpe directo y DoT: el medidor los suma, no se calibra.
    [8921] = {
        "Fuego lunar",
        "Un rápido haz de luz lunar quema al objetivo y le inflige 200 p. de daño Arcano más 1.800 p. de daño "
            .. "Arcano adicional durante 18 s.",
    },
}

local function boot(opts)
    opts = opts or {}
    opts.client, opts.build, opts.locale = "retail", RETAIL_BUILD, "esES"
    opts.spells = opts.spells or SPELLS
    opts.target = opts.target or { exists = true, attackable = true }
    local env, ns = WowEnv.boot(TOC, opts)
    return env, ns, opts
end

local function near(expected, actual, what)
    assert(
        math.abs(expected - actual) < 1e-6,
        ("%s: esperaba %s y salió %s"):format(what or "valor", expected, actual)
    )
end

local function remaining(env, ns)
    return ns.Dots.TargetState(env.GetTime()).damage
end

-- Un combate: entra, lanza, deja pasar `seconds` y sale con el medidor diciendo `real` para Corrupción.
local function fight(env, ns, seconds, real, spellID)
    spellID = spellID or 172
    env:SetCombat(true)
    env:Cast(spellID)
    env:Advance(seconds)
    env:SetMeter({ duration = seconds, spells = { { spellID, real } } })
    env:SetCombat(false)
    env:Advance(ns.Calibration.DELAY + 0.01)
end

local function factor(env, name)
    local f = env.DoTLetalCharDB.calibration[name]
    return f and f.factor, f and f.ticks
end

describe("calibración con el medidor de daño", function()
    it("tras un combate, el factor es el daño real entre el previsto y se aplica a los siguientes DoTs", function()
        local env, ns = boot()
        fight(env, ns, 14.1, 1680) -- 7 ticks: previsto 1400, real 1680
        local f, ticks = factor(env, "Corrupción")
        near(1.2, f, "factor")
        assert.are.equal(7, ticks)
        env:Cast(172)
        near(1680, remaining(env, ns), "daño previsto con el factor")
    end)

    it("el siguiente combate se compara sin el factor y se promedia por ticks", function()
        local env, ns = boot()
        fight(env, ns, 14.1, 1680) -- 1,2 con 7 ticks
        fight(env, ns, 14.1, 1400) -- 1,0 con 7 ticks (lo previsto sin factor sigue siendo 1400)
        local f, ticks = factor(env, "Corrupción")
        near(1.1, f, "factor")
        assert.are.equal(14, ticks)
    end)

    it("la memoria tiene un tope: el equipo nuevo pesa", function()
        local env, ns = boot()
        env.DoTLetalCharDB.calibration["Corrupción"] = { factor = 1, ticks = 500 }
        fight(env, ns, 14.1, 2800) -- 2,0 con 7 ticks contra 60 de memoria
        near((60 + 2 * 7) / 67, (factor(env, "Corrupción")), "factor")
    end)

    it("en combate el medidor es secreto y no se lee: se espera a salir", function()
        local env, ns = boot()
        env:SetCombat(true)
        env:Cast(172)
        env:Advance(14.1)
        env:SetMeter({ duration = 14.1, spells = { { 172, 1680 } } })
        assert.are.equal(0, env:MeterCalls())
        env:SetCombat(false)
        assert.are.equal(0, env:MeterCalls()) -- aún no: espera a que el medidor cierre la sesión
        env:Advance(ns.Calibration.DELAY + 0.01)
        assert.are.equal(1, env:MeterCalls())
    end)

    it("si el objetivo muere, sus DoTs dejan de contar ese momento", function()
        local env, ns, opts = boot()
        env:SetCombat(true)
        env:Cast(172)
        env:Advance(6.1) -- 3 ticks: 600
        opts.target.dead = true
        env:SetHealth("target", 0, 1000)
        env:Advance(8) -- el reloj del addon habría seguido hasta 1400
        env:SetMeter({ duration = 14.1, spells = { { 172, 720 } } })
        env:SetCombat(false)
        env:Advance(ns.Calibration.DELAY + 0.01)
        local f, ticks = factor(env, "Corrupción")
        near(1.2, f, "factor")
        assert.are.equal(3, ticks)
    end)

    it("reaplicar a mitad cuenta lo que hizo cada aplicación", function()
        local env, ns = boot()
        env:SetCombat(true)
        env:Cast(172)
        env:Advance(4.5) -- 2 ticks
        env:Cast(172) -- 9 ticks y uno parcial de 0,35 (dots_spec)
        env:Advance(18.4)
        local predicted = 200 * (2 + 9.35)
        env:SetMeter({ duration = 22.9, spells = { { 172, predicted * 1.1 } } })
        env:SetCombat(false)
        env:Advance(ns.Calibration.DELAY + 0.01)
        local f, ticks = factor(env, "Corrupción")
        near(1.1, f, "factor")
        assert.are.equal(12, ticks)
    end)

    it("lo hecho antes de entrar en combate no cuenta", function()
        local env, ns = boot()
        env:Cast(172)
        env:Advance(6.1) -- 3 ticks fuera de combate
        env:SetCombat(true)
        env:Advance(8) -- los 4 que quedan
        env:SetMeter({ duration = 8, spells = { { 172, 960 } } })
        env:SetCombat(false)
        env:Advance(ns.Calibration.DELAY + 0.01)
        local f, ticks = factor(env, "Corrupción")
        near(1.2, f, "factor")
        assert.are.equal(4, ticks)
    end)

    it("no calibra un hechizo con golpe directo, con pocos ticks ni sin daño en el medidor", function()
        local env, ns = boot()
        fight(env, ns, 18.1, 2400, 8921) -- Fuego lunar: el medidor suma el golpe directo
        assert.is_nil(factor(env, "Fuego lunar"))
        fight(env, ns, 4.1, 480) -- 2 ticks
        assert.is_nil(factor(env, "Corrupción"))
        fight(env, ns, 14.1, 0) -- inmune: el DoT no entró
        assert.is_nil(factor(env, "Corrupción"))
        fight(env, ns, 14.1, 14000) -- proporción 10: algo raro (otro objetivo, otra cosa con el mismo nombre)
        assert.is_nil(factor(env, "Corrupción"))
    end)

    it("descarta el combate con DoTs en dos objetivos o si se perdió la pista de uno", function()
        local env, ns = boot()
        env:SetCombat(true)
        env:SetTarget({ exists = true, attackable = true }, "Creature-0-1")
        env:Cast(172)
        env:SetTarget({ exists = true, attackable = true }, "Creature-0-2")
        env:Cast(172)
        env:Advance(14.1)
        env:SetMeter({ duration = 14.1, spells = { { 172, 3360 } } })
        env:SetCombat(false)
        env:Advance(ns.Calibration.DELAY + 0.01)
        assert.is_nil(factor(env, "Corrupción"))

        -- Identidad del PNJ secreta: al cambiar de objetivo con el DoT vivo, el addon lo olvida.
        env:SetCombat(true)
        env:SetTarget({ exists = true, attackable = true }, "Creature-0-3", true)
        env:Cast(172)
        env:Advance(2.1)
        env:SetTarget({ exists = true, attackable = true }, "Creature-0-4", true)
        env:Advance(12)
        env:SetMeter({ duration = 14.1, spells = { { 172, 1680 } } })
        env:SetCombat(false)
        env:Advance(ns.Calibration.DELAY + 0.01)
        assert.is_nil(factor(env, "Corrupción"))
    end)

    it("sin medidor disponible o con una sesión que no cuadra con el combate, no hace nada", function()
        local env, ns = boot()
        env:SetCombat(true)
        env:Cast(172)
        env:Advance(14.1)
        env:SetMeter({ available = false, reason = "disabled" })
        env:SetCombat(false)
        env:Advance(ns.Calibration.DELAY + 0.01)
        assert.is_nil(factor(env, "Corrupción"))

        env:SetCombat(true)
        env:Cast(172)
        env:Advance(14.1)
        env:SetMeter({ duration = 60, spells = { { 172, 1680 } } }) -- otra pelea más larga
        env:SetCombat(false)
        env:Advance(ns.Calibration.DELAY + 0.01)
        assert.is_nil(factor(env, "Corrupción"))
    end)

    it("con la opción apagada no aprende ni aplica; /dotletal calibracion lista y borra", function()
        local env, ns = boot()
        fight(env, ns, 14.1, 1680)
        env:ClearPrinted()
        env:RunSlash("/dotletal calibracion")
        assert(env:Printed():find(ns.L.CALIBRATION_LINE:format("Corrupción", 1.2, 7), 1, true), env:Printed())

        ns.db.calibrate = false
        ns:ApplySettings()
        env:Cast(172)
        near(1400, remaining(env, ns), "sin factor")
        fight(env, ns, 14.1, 2800)
        near(1.2, (factor(env, "Corrupción")), "no aprende")

        ns.db.calibrate = true
        ns:ApplySettings()
        env:RunSlash("/dotletal calibracion borrar")
        assert.is_nil(factor(env, "Corrupción"))
        env:Advance(30)
        env:Cast(172)
        near(1400, remaining(env, ns), "borrado")
    end)
end)
