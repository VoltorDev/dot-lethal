-- Seguimiento por enemigo: a quién va cada lanzamiento (UNIT_SPELLCAST_SENT), DoTs en placas y foco, el respaldo
-- de los DoTs que no hacen ningún tick y el modo prudente. Ideas de Does It Die (MIT), reescritas.
local WowEnv = require("wow_env")
local Secret = require("secret_mock")
Secret.registerFormatter(assert)

local TOC = "DoTLetal.toc"
local SHADOW, PHYSICAL = 32, 1
local SPELLS = {
    [172] = { "Corruption", "Corrupts the target, causing 600 Shadow damage over 18 sec." },
    [1978] = { "Serpent Sting", "Stings the target, causing 100 Nature damage over 15 sec." },
}
local A, B = "Creature-0-1-1-1-1-A", "Creature-0-1-1-1-1-B"

local function boot(extra)
    local opts = { spells = SPELLS, target = { exists = true, attackable = true }, guids = { target = A } }
    for k, v in pairs(extra or {}) do
        opts[k] = v
    end
    return WowEnv.boot(TOC, opts)
end

local function damage(env, ns)
    return ns.Dots.TargetState(env.GetTime()).damage
end

local function hit(env, unit, school, action)
    env:Fire("UNIT_COMBAT", unit, action or "WOUND", "", 0, school)
end

-- Partes de la marca colgada de una barra (ver indicator_spec.lua).
local function markShown(env, host)
    local anchor = env:Widgets("Frame", host)[2]
    return anchor ~= nil and anchor:IsShown()
end

describe("a quién va cada lanzamiento", function()
    it("DoT instantáneo y cambio de objetivo antes de que llegue: se queda en el primero", function()
        local env, ns = boot()
        env:Send(172, "", 1)
        env:SetTarget({ exists = true, attackable = true }, B)
        env:Cast(172, 1)
        assert.are.equal(0, damage(env, ns)) -- el nuevo objetivo no tiene nada
        env:SetTarget({ exists = true, attackable = true }, A)
        assert.are.equal(600, damage(env, ns))
    end)

    it("con la identidad secreta y sin placa, si el objetivo cambia por medio no se apunta a nadie", function()
        local env, ns = boot()
        env:SetTarget({ exists = true, attackable = true }, A, true)
        env:Send(172, "", 1)
        env:SetTarget({ exists = true, attackable = true }, B, true)
        env:Cast(172, 1)
        assert.are.equal(0, damage(env, ns))
    end)

    it("una macro al foco (el nombre del destino es el del foco) lo pone en el foco", function()
        local env, ns = boot({ names = { target = { "Lobo" } } })
        env:SetUnit("focus", { exists = true, attackable = true }, B, "Oso")
        env:Send(172, "Oso", 1)
        env:Cast(172, 1)
        assert.are.equal(0, damage(env, ns))
        assert.are.equal(600, ns.Dots.DamageFor(B, env.GetTime()))
    end)

    it("sin UNIT_SPELLCAST_SENT, como antes: al objetivo de ahora", function()
        local env, ns = boot()
        env:Cast(172, 7)
        assert.are.equal(600, damage(env, ns))
    end)
end)

describe("DoTs en placas y foco", function()
    it("marca la placa de otro enemigo con DoTs y la quita cuando su placa se va", function()
        local env, ns = boot({ health = { nameplate2 = { 5000, 8000 } } })
        local plate = env:AddPlate("nameplate2", nil, A, false, true)
        env:Cast(172)
        env:SetTarget({ exists = true, attackable = true }, B)
        env:SetTargetPlate(nil)
        assert.is_true(markShown(env, plate.UnitFrame.healthBar))
        env:RemovePlate("nameplate2")
        assert.is_true(ns.Dots.DamageFor(A, env.GetTime()) > 0) -- con GUID legible, no se olvida
    end)

    it("con la identidad secreta sigue a cada enemigo por su placa, y lo olvida cuando la placa se va", function()
        local env, ns = boot()
        env:AddPlate("nameplate1", nil, A, true, true)
        env:SetTarget({ exists = true, attackable = true }, A, true)
        env:Cast(172)
        assert.are.equal("plate:nameplate1", ns.Dots.UnitKey("target"))
        env:AddPlate("nameplate2", nil, B, true)
        env:SetTargetPlate("nameplate2")
        env:SetTarget({ exists = true, attackable = true }, B, true)
        assert.are.equal(0, damage(env, ns))
        assert.are.equal(600, ns.Dots.DamageFor("plate:nameplate1", env.GetTime()))
        env:SetTargetPlate("nameplate1")
        env:SetTarget({ exists = true, attackable = true }, A, true)
        assert.are.equal(600, damage(env, ns)) -- al volver, siguen ahí
        env:RemovePlate("nameplate1")
        assert.are.equal(0, ns.Dots.DamageFor("plate:nameplate1", env.GetTime()))
    end)

    it("marca el marco de foco, y no si la opción está apagada", function()
        local env = boot({ health = { focus = { 5000, 8000 } } })
        local bar = env.FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar
        env:Cast(172)
        env:SetUnit("focus", { exists = true, attackable = true }, A, "Lobo")
        env:SetTarget({ exists = true, attackable = true }, B)
        assert.is_true(markShown(env, bar))
        env:SettingsRegistry().settings[env:AddonName() .. "_FocusFrame"]:SetValue(false)
        assert.is_false(markShown(env, bar))
    end)

    it("un enemigo con placa que muere deja de contar", function()
        local env, ns = boot()
        env:AddPlate("nameplate2", nil, A, false, true)
        env:Cast(172)
        env:SetTarget({ exists = true, attackable = true }, B)
        env:SetTargetPlate(nil)
        env:SetUnit("nameplate2", { exists = true, attackable = true, dead = true }, A)
        env:Fire("UNIT_HEALTH", "target") -- dispara Indicator:Update
        assert.are.equal(0, ns.Dots.DamageFor(A, env.GetTime()))
    end)
end)

describe("respaldo: DoT que no hace ningún tick", function()
    it("si llegan golpes al addon pero ninguno cuando tocaba un tick, a los dos ticks se quita", function()
        local env, ns = boot()
        env:Cast(172)
        hit(env, "target", PHYSICAL) -- un golpe de la mascota: prueba de que UNIT_COMBAT llega, no es el tick
        env:Advance(7)
        env:Fire("UNIT_HEALTH", "target") -- dispara Indicator:Update
        assert.are.equal(0, damage(env, ns))
        assert.are.equal("dropped", ns.Dots.TargetState(env.GetTime()).alerts[1].phase)
    end)

    it("un tick visto a su hora lo confirma", function()
        local env, ns = boot()
        env:Cast(172)
        env:Advance(3.1)
        hit(env, "target", SHADOW)
        env:Advance(6)
        env:Fire("UNIT_HEALTH", "target") -- dispara Indicator:Update
        assert.is_true(damage(env, ns) > 0)
    end)

    it("sin ningún UNIT_COMBAT reciente no quita nada (podría ser que no llegan)", function()
        local env, ns = boot()
        env:Cast(172)
        env:Advance(9)
        env:Fire("UNIT_HEALTH", "target") -- dispara Indicator:Update
        assert.is_true(damage(env, ns) > 0)
    end)

    it("un enemigo fuera de la vista (sin placa ni objetivo) no pierde sus DoTs", function()
        local env, ns = boot()
        env:Cast(172)
        env:SetTarget({ exists = true, attackable = true }, B)
        for _ = 1, 4 do
            hit(env, "target", PHYSICAL)
            env:Advance(2)
            env:Fire("UNIT_HEALTH", "target") -- dispara Indicator:Update
        end
        assert.are.equal(600 - 2 * 100, ns.Dots.DamageFor(A, env.GetTime()))
    end)

    it("proyectil: el primer tick puede llegar tarde y aún cuenta", function()
        local env, ns = boot()
        env:Cast(1978)
        hit(env, "target", PHYSICAL)
        env:Advance(3.9) -- el tick de los 3 s llega a los 3,9 por el viaje del proyectil
        hit(env, "target", 8)
        env:Advance(6)
        env:Fire("UNIT_HEALTH", "target") -- dispara Indicator:Update
        assert.is_true(damage(env, ns) > 0)
    end)
end)

describe("modo prudente", function()
    it("la calibración puede bajar el daño previsto pero no subirlo", function()
        local env, ns = boot()
        ns.Dots.SetFactors({ Corruption = { factor = 1.5, ticks = 20 } })
        ns.Dots.CAUTIOUS = true
        env:Cast(172)
        assert.are.equal(600, damage(env, ns))
        ns.Dots.SetFactors({ Corruption = { factor = 0.8, ticks = 20 } })
        env:Cast(172)
        assert.are.equal(480, damage(env, ns))
    end)

    it("la opción lo enciende", function()
        local env, ns = boot()
        local setting = env:SettingsRegistry().settings[env:AddonName() .. "_Cautious"]
        setting:SetValue(true)
        assert.is_true(ns.Dots.CAUTIOUS)
        setting:SetValue(false)
        assert.is_false(ns.Dots.CAUTIOUS)
        assert.are.same({}, env:Missing())
    end)
end)
