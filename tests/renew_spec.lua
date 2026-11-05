-- Aviso de renovación (Dots.RenewPhase, Dots.TargetState().alerts y los iconos de Modules/Indicator.lua): cuándo
-- volver a lanzar cada DoT para no perder daño. Todo sale del reloj propio, con números normales.
local WowEnv = require("wow_env")
local Secret = require("secret_mock")
Secret.registerFormatter(assert)

local TOC = "DoTLetal.toc"
local RETAIL_BUILD = { "12.1.5", "99999", "Oct 1 2026", 120105 }

-- { nombre, descripción, tiempo de lanzamiento en ms }.
local SPELLS = {
    [172] = { "Corruption", "Corrupts the target, causing 822 Shadow damage over 18 sec.", 2000 },
    [348] = {
        "Immolate",
        "Burns the enemy for 11 Fire damage and then an additional 20 Fire damage over 15 sec.",
        2000,
    },
    [980] = { "Curse of Agony", "Curses the target with agony, causing 1,200 Shadow damage over 24 sec.", 0 },
}
local RETAIL_SPELLS = {
    [172] = { "Corrupción", "Corrompe al objetivo y le inflige 1.400 p. de daño de Sombras durante 14 s.", 0 },
}

local function boot(opts)
    opts = opts or {}
    opts.spells = opts.spells or SPELLS
    opts.target = opts.target or { exists = true, attackable = true }
    opts.health = opts.health or { target = { 5000, 8000 } }
    local env, ns = WowEnv.boot(TOC, opts)
    -- Los tiempos de estos tests cuentan con 1,5 s de aviso previo (el de serie, 3 s, tiene su test).
    if not opts.defaultLead then
        env:SettingsRegistry().settings[env:AddonName() .. "_RenewLead"]:SetValue(1.5)
    end
    return env, ns
end

local function bootRetail(opts)
    opts = opts or {}
    opts.client, opts.build, opts.locale = "retail", RETAIL_BUILD, "esES"
    opts.spells = opts.spells or RETAIL_SPELLS
    return boot(opts)
end

local function near(expected, actual)
    assert(math.abs(expected - actual) < 1e-6, ("se esperaba %s y salió %s"):format(expected, actual))
end

-- Fase del DoT con ese nombre en el estado actual (lista o, si se ha caído, avisos).
local function phaseOf(env, ns, name)
    local state = ns.Dots.TargetState(env.GetTime())
    for _, dot in ipairs(state.list) do
        if dot.name == name then
            return dot.phase, dot.wait
        end
    end
    for _, a in ipairs(state.alerts) do
        if a.name == name then
            return a.phase, a.wait
        end
    end
    return nil
end

describe("cuándo relanzar en Forever (sin pandemia: el nuevo sustituye al viejo)", function()
    it("instantáneo: ok, luego cuenta atrás de un tiempo global y «ya» justo al acabar el último tick", function()
        local env, ns = boot()
        env:Cast(980) -- Maldición de agonía, 24 s, instantánea
        assert.are.equal("ok", phaseOf(env, ns, "Curse of Agony"))
        env:Advance(22.4) -- quedan 1,6 s: lanzarla ahora perdería el último tick (el más fuerte)
        assert.are.equal("ok", phaseOf(env, ns, "Curse of Agony"))
        env:Advance(0.6) -- quedan 1,0 s
        local phase, wait = phaseOf(env, ns, "Curse of Agony")
        assert.are.equal("soon", phase)
        near(0.9, wait) -- 1,0 s - margen de 0,1 s
        env:Advance(0.95) -- quedan 0,05 s
        assert.are.equal("now", phaseOf(env, ns, "Curse of Agony"))
    end)

    it("con tiempo de lanzamiento: «ya» cuando quedan esos segundos, para que llegue tras el último tick", function()
        local env, ns = boot()
        env:Cast(348) -- Inmolar, 15 s, 2 s de lanzamiento
        env:Advance(11) -- quedan 4 s: el nuevo llegaría con 2 s de sobra
        assert.are.equal("ok", phaseOf(env, ns, "Immolate"))
        env:Advance(1) -- quedan 3 s
        local phase, wait = phaseOf(env, ns, "Immolate")
        assert.are.equal("soon", phase)
        near(0.9, wait)
        env:Advance(0.95) -- quedan 2,05 s: llegaría 0,05 s antes del final (dentro del margen)
        assert.are.equal("now", phaseOf(env, ns, "Immolate"))
    end)

    it("al caerse: «caído» entre los avisos durante 8 s; relanzarlo lo quita", function()
        local env, ns = boot()
        env:Cast(172)
        env:Advance(18.5)
        local state = ns.Dots.TargetState(env.GetTime())
        assert.are.equal(0, #state.list)
        assert.are.equal(1, #state.alerts)
        assert.are.equal("dropped", state.alerts[1].phase)
        assert.are.equal(136172, state.alerts[1].icon)
        env:Advance(8)
        assert.are.equal(0, #ns.Dots.TargetState(env.GetTime()).alerts)
        env:Cast(172)
        env:Advance(18.5)
        assert.are.equal("dropped", phaseOf(env, ns, "Corruption"))
        env:Cast(172)
        assert.are.equal("ok", phaseOf(env, ns, "Corruption"))
        assert.are.equal(0, #ns.Dots.TargetState(env.GetTime()).alerts)
    end)

    it("cambiar de objetivo o matarlo olvida los caídos", function()
        local env, ns = boot()
        env:Cast(172)
        env:Advance(18.5)
        assert.are.equal("dropped", phaseOf(env, ns, "Corruption"))
        env:SetTarget({ exists = true, attackable = true })
        assert.is_nil(phaseOf(env, ns, "Corruption"))
        env:Cast(172)
        env:Advance(18.5)
        ns.Dots.TargetDied(env.GetTime())
        assert.is_nil(phaseOf(env, ns, "Corruption"))
    end)

    it("avisos de más a menos urgente: caído, ya, pronto", function()
        local env, ns = boot()
        env:Cast(172) -- 18 s, 2 s de lanzamiento
        env:Advance(4)
        env:Cast(348) -- 15 s desde t = 4: acaba en t = 19
        env:Advance(2)
        env:Cast(980) -- 24 s desde t = 6: acaba en t = 30
        env:Advance(13.95) -- t = 19,95
        local alerts = ns.Dots.TargetState(env.GetTime()).alerts
        assert.are.equal("dropped", alerts[1].phase) -- Corrupción, acabó en t = 18
        assert.are.equal("Corruption", alerts[1].name)
        assert.are.equal("dropped", alerts[2].phase) -- Inmolar, en t = 19
        env:Cast(172)
        env:Cast(348)
        env:Advance(13.5) -- t = 33,45: Agonía caída; Corrupción con 4,5 s e Inmolar con 1,5 s
        alerts = ns.Dots.TargetState(env.GetTime()).alerts
        assert.are.same({ "Curse of Agony", "Immolate" }, { alerts[1].name, alerts[2].name })
        assert.are.same({ "dropped", "now" }, { alerts[1].phase, alerts[2].phase })
    end)

    it("tiempo de lanzamiento secreto: el último legible, o instantáneo si no hubo ninguno", function()
        local opts = { secretCastTime = true }
        local env, ns = boot(opts)
        env:Cast(348)
        env:Advance(13.5) -- quedan 1,5 s; tomado por instantáneo aún toca esperar
        local phase = phaseOf(env, ns, "Immolate")
        assert.are.equal("soon", phase)
        opts.secretCastTime = false
        env:Cast(348)
        env:Advance(13.5) -- lee 2 s: con 1,5 s restantes ya llega tarde
        assert.are.equal("now", phaseOf(env, ns, "Immolate"))
        opts.secretCastTime = true
        assert.are.equal("now", phaseOf(env, ns, "Immolate"))
    end)
end)

describe("aviso previo", function()
    it("de serie, 3 s de ámbar antes del «¡YA!»; la opción lo cambia y el «¡YA!» no se mueve", function()
        local env, ns = boot({ defaultLead = true })
        assert.are.equal(3, env.DoTLetalDB.renewLead)
        env:Cast(980) -- instantánea, 24 s
        env:Advance(20.8) -- quedan 3,2 s: aún no
        assert.are.equal("ok", phaseOf(env, ns, "Curse of Agony"))
        env:Advance(0.4) -- quedan 2,8 s
        local phase, wait = phaseOf(env, ns, "Curse of Agony")
        assert.are.equal("soon", phase)
        near(2.7, wait)
        env:SettingsRegistry().settings[env:AddonName() .. "_RenewLead"]:SetValue(5)
        env:Cast(980)
        env:Advance(18.8) -- quedan 5,2 s: faltan 5,1 para el «¡YA!», aún no
        assert.are.equal("ok", phaseOf(env, ns, "Curse of Agony"))
        env:Advance(0.2) -- quedan 5 s: con 5 s de aviso, ya ámbar
        assert.are.equal("soon", phaseOf(env, ns, "Curse of Agony"))
        env:Advance(4.95) -- quedan 0,05 s
        assert.are.equal("now", phaseOf(env, ns, "Curse of Agony"))
    end)
end)

describe("cuándo relanzar en retail (pandemia del 30 %)", function()
    it("«ya» desde que el nuevo llegaría dentro del 30 % de la duración; antes, cuenta atrás", function()
        local env, ns = bootRetail()
        env:Cast(172) -- 14 s: ventana de 4,2 s
        env:Advance(8) -- quedan 6 s
        assert.are.equal("ok", phaseOf(env, ns, "Corrupción"))
        env:Advance(1) -- quedan 5 s
        local phase, wait = phaseOf(env, ns, "Corrupción")
        assert.are.equal("soon", phase)
        near(0.8, wait)
        env:Advance(1) -- quedan 4 s
        assert.are.equal("now", phaseOf(env, ns, "Corrupción"))
    end)

    it("la ventana se mide con la duración base, no con lo arrastrado", function()
        local env, ns = bootRetail()
        env:Cast(172)
        env:Advance(10) -- quedan 4 s
        env:Cast(172) -- 14 + 4 = 18 s
        env:Advance(13) -- quedan 5 s: con 18 s la ventana sería 5,4 s; con la base, 4,2 s
        assert.are.equal("soon", phaseOf(env, ns, "Corrupción"))
    end)
end)

describe("iconos de renovación", function()
    local function alertParts(env)
        local alert = env.DoTLetalAlert
        local textures = env:Widgets("Texture", alert)
        local labels = env:Widgets("FontString", alert)
        return alert, { border = textures[1], icon = textures[2], label = labels[1] }, labels[2]
    end

    it("aparecen encima del panel con el color y el texto de cada fase", function()
        local env = boot()
        env:Cast(348)
        local alert, slot = alertParts(env)
        assert.is_false(alert:IsShown())
        env:Advance(12.05) -- quedan 2,95 s (el panel se repinta cada 0,2 s: el último, en t = 12)
        assert.is_true(alert:IsShown())
        assert.is_true(slot.icon:IsShown())
        assert.are.equal("0.9", slot.label:GetText())
        assert.are.same({ 1, 0.72, 0.1 }, { slot.label:LastCall("SetTextColor") })
        env:Advance(1) -- quedan 2 s
        assert.are.equal("NOW!", slot.label:GetText())
        env:Advance(2.5)
        assert.are.equal("DROPPED", slot.label:GetText())
        assert.are.same({ 1, 0.15, 0.15 }, { slot.label:LastCall("SetTextColor") })
        assert.is_false(env.DoTLetalFrame:IsShown()) -- sin daño el panel se va; el aviso se queda
        assert.is_true(alert:IsShown())
        assert.are.same({}, env:Missing())
    end)

    it("el reloj sigue mientras haya un caído y se para después", function()
        local env = boot()
        env:Cast(172)
        env:Advance(18.5)
        assert.is_true(env:PendingTimers() > 0)
        env:Advance(9)
        assert.is_false(env.DoTLetalAlert:IsShown())
        assert.are.equal(0, env:PendingTimers())
    end)

    it("en el modo clásico la fila del DoT toma el color de su fase", function()
        local env = boot()
        env:Cast(348)
        env:Advance(13.05) -- último repintado en t = 13: quedan 2 s, ya toca
        local name = env:Widgets("FontString", env.DoTLetalFrame)[3]
        assert.are.equal("Immolate", name:GetText())
        assert.are.same({ 0.25, 1, 0.25 }, { name:LastCall("SetTextColor") })
    end)

    it("la opción los quita; el sonido, apagado de serie, suena una vez por DoT", function()
        local env = boot()
        local settings = env:SettingsRegistry().settings
        env:Cast(980)
        env:Advance(24.5)
        assert.are.equal(0, #env:Sounds())
        env:Cast(980)
        settings[env:AddonName() .. "_RenewSound"]:SetValue(true)
        env:Advance(24.5) -- pasa a «ya» y luego a caído: un solo sonido
        assert.are.equal(1, #env:Sounds())
        assert.are.equal(8959, env:Sounds()[1][1])
        settings[env:AddonName() .. "_RenewStrip"]:SetValue("never")
        env:Advance(0.4)
        assert.is_false(env.DoTLetalAlert:IsShown())
    end)

    it("desbloqueado para moverlo enseña un aviso de muestra", function()
        local env = boot()
        env:RunSlash("/dotletal mover")
        local alert, slot = alertParts(env)
        assert.is_true(alert:IsShown())
        assert.are.equal("NOW!", slot.label:GetText())
        env:RunSlash("/dotletal mover")
        assert.is_false(alert:IsShown())
    end)

    it("las SavedVariables no guardan secretos con el aviso activo", function()
        local env = boot({ secretMaxHealth = true, secretCastTime = true })
        env:AddActionButton("ActionButton1", 1)
        env:SetAction(1, 172)
        env:Cast(172)
        env:Advance(20)
        Secret.assertNoSecretKeys(env.DoTLetalDB, "DoTLetalDB")
    end)

    it("con la vida y el tiempo de lanzamiento secretos (sin botones) tampoco", function()
        local env = boot({ secretMaxHealth = true, secretCastTime = true })
        env:Cast(172)
        env:Advance(20)
        Secret.assertNoSecretKeys(env.DoTLetalDB, "DoTLetalDB")
    end)
end)
