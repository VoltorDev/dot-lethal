-- Dots.lua: lectura de la descripción del hechizo, reparto del daño en ticks y seguimiento por
-- objetivo. Todo con números normales: la vida secreta no entra aquí.
local WowEnv = require("wow_env")

local TOC = "DoTLetal.toc"

-- Descripciones con la forma de las de Classic; las de Forever se comprueban en el cliente.
local SPELLS = {
    [172] = { "Corruption", "Corrupts the target, causing 822 Shadow damage over 18 sec." },
    [348] = { "Immolate", "Burns the enemy for 11 Fire damage and then an additional 20 Fire damage over 15 sec." },
    [980] = { "Curse of Agony", "Curses the target with agony, causing 1,200 Shadow damage over 24 sec." },
    [18265] = { "Siphon Life", "Transfers 15 health every 3 sec from the target to the caster for 30 sec." },
    [686] = { "Shadow Bolt", "Sends a shadowy bolt at the enemy, causing 13 to 18 Shadow damage." },
}

local function boot(opts)
    opts = opts or {}
    opts.spells = opts.spells or SPELLS
    opts.target = opts.target or { exists = true, attackable = true }
    return WowEnv.boot(TOC, opts)
end

describe("Dots.ParseDescription", function()
    local Dots

    setup(function()
        local _, ns = boot()
        Dots = ns.Dots
    end)

    it("DoT puro: el número antes de la duración", function()
        assert.are.same({ 822, 18 }, { Dots.ParseDescription(SPELLS[172][2]) })
    end)

    it("golpe directo más DoT: se queda con la parte del DoT", function()
        assert.are.same({ 20, 15 }, { Dots.ParseDescription(SPELLS[348][2]) })
    end)

    it("separadores de miles en inglés y en español", function()
        assert.are.same({ 1200, 24 }, { Dots.ParseDescription(SPELLS[980][2]) })
        local es = "Corrompe al objetivo y le inflige 1.234 p. de daño de Sombras durante 18 s."
        assert.are.same({ 1234, 18 }, { Dots.ParseDescription(es) })
    end)

    it("español con golpe directo y espacio duro antes de la unidad", function()
        local es = "Quema al enemigo y le inflige 11 p. de daño de Fuego y otros 20 p. de daño durante 15\194\160s."
        assert.are.same({ 20, 15 }, { Dots.ParseDescription(es) })
    end)

    it("modo tick: daño por tick por número de ticks", function()
        assert.are.same({ 150, 30 }, { Dots.ParseDescription(SPELLS[18265][2], "tick", 3) })
    end)

    it("sin duración (no es un DoT) o sin texto: nada", function()
        assert.is_nil(Dots.ParseDescription(SPELLS[686][2]))
        assert.is_nil(Dots.ParseDescription(""))
        assert.is_nil(Dots.ParseDescription(nil))
    end)
end)

describe("Dots.Remaining", function()
    local Dots

    setup(function()
        local _, ns = boot()
        Dots = ns.Dots
    end)

    it("descuenta cada tick al caer, no antes", function()
        local e = { start = 100, period = 3, ticks = 6, total = 600 }
        assert.are.same({ 600, 18 }, { Dots.Remaining(e, 100) })
        assert.are.same({ 600, 15.5 }, { Dots.Remaining(e, 102.5) })
        assert.are.same({ 500, 15 }, { Dots.Remaining(e, 103) })
        assert.are.same({ 100, 1 }, { Dots.Remaining(e, 117) })
        assert.are.same({ 0, 0 }, { Dots.Remaining(e, 118) })
    end)

    it("ticks con peso (Maldición de agonía): los últimos pesan más", function()
        local w = { 0.5, 0.5, 0.5, 0.5, 1, 1, 1, 1, 1.5, 1.5, 1.5, 1.5 }
        local e = { start = 0, period = 2, ticks = 12, total = 1200, weights = w }
        assert.are.equal(1200, (Dots.Remaining(e, 0)))
        assert.are.equal(1000, (Dots.Remaining(e, 8))) -- 4 ticks de 50
        assert.are.equal(600, (Dots.Remaining(e, 16))) -- y 4 de 100
    end)
end)

describe("seguimiento por objetivo", function()
    it("apunta el DoT lanzado sobre un enemigo y suma varios", function()
        local env, ns = boot()
        env:Cast(172)
        env:Cast(348)
        assert.are.equal(842, (ns.Dots.TargetRemaining(env.GetTime())))
    end)

    it("ignora hechizos que no son DoTs, sin objetivo atacable o con el objetivo muerto", function()
        local env, ns = boot()
        env:Cast(686)
        assert.are.equal(0, (ns.Dots.TargetRemaining(env.GetTime())))
        env:SetTarget({ exists = true, attackable = false })
        env:Cast(172)
        env:SetTarget({ exists = true, attackable = true, dead = true })
        env:Cast(172)
        env:SetTarget(nil)
        env:Cast(172)
        assert.are.equal(0, (ns.Dots.TargetRemaining(env.GetTime())))
    end)

    it("reaplicar reinicia el DoT (no se suma dos veces)", function()
        local env, ns = boot()
        env:Cast(172)
        env:Advance(9)
        env:Cast(172)
        assert.are.equal(822, (ns.Dots.TargetRemaining(env.GetTime())))
    end)

    it("con GUID legible recuerda los DoTs de cada objetivo al volver a él", function()
        local env, ns = boot()
        env:SetTarget({ exists = true }, "Creature-0-1-1-1-1-A")
        env:Cast(172)
        env:SetTarget({ exists = true }, "Creature-0-1-1-1-1-B")
        assert.are.equal(0, (ns.Dots.TargetRemaining(env.GetTime())))
        env:SetTarget({ exists = true }, "Creature-0-1-1-1-1-A")
        assert.are.equal(822, (ns.Dots.TargetRemaining(env.GetTime())))
    end)

    it("con la identidad del PNJ secreta solo sigue el objetivo actual", function()
        local env, ns = boot()
        env:SetTarget({ exists = true }, "Creature-0-1-1-1-1-A", true)
        env:Cast(172)
        assert.are.equal(822, (ns.Dots.TargetRemaining(env.GetTime())))
        env:SetTarget({ exists = true }, "Creature-0-1-1-1-1-A", true)
        assert.are.equal(0, (ns.Dots.TargetRemaining(env.GetTime())))
    end)

    it("los DoTs añadidos a mano por nombre también se siguen", function()
        local spells = { [9999] = { "Mi DoT", "Inflige 300 p. de daño durante 12 s." } }
        local env, ns = boot({ spells = spells })
        env:Cast(9999)
        assert.are.equal(0, (ns.Dots.TargetRemaining(env.GetTime())))
        env:RunSlash("/dotletal añadir 3 Mi DoT")
        env:Cast(9999)
        assert.are.equal(300, (ns.Dots.TargetRemaining(env.GetTime())))
        env:Advance(12)
        assert.are.equal(0, (ns.Dots.TargetRemaining(env.GetTime())))
    end)
end)
