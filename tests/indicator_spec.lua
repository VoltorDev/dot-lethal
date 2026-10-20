-- Indicador (Modules/Indicator.lua) con la vida del objetivo secreta, como en Forever: la vida se
-- entrega a las barras sin compararla y el veredicto sale del recorte de la barra a su rango.
local WowEnv = require("wow_env")
local Secret = require("secret_mock")
Secret.registerFormatter(assert)

local TOC = "DoTLetal.toc"
local INDICATOR = "Modules/Indicator.lua"
local SPELLS = {
    [172] = { "Corruption", "Corrupts the target, causing 600 Shadow damage over 18 sec." },
}

local function contains(text, fragment)
    assert(text:find(fragment, 1, true), "no aparece «" .. fragment .. "» en:\n" .. text)
end

local function boot(health, extra)
    local opts = {
        spells = SPELLS,
        target = { exists = true, attackable = true },
        health = { target = health },
        secretMaxHealth = true,
    }
    for k, v in pairs(extra or {}) do
        opts[k] = v
    end
    return WowEnv.boot(TOC, opts)
end

-- Lo que vería el jugador: la barra roja tapa el visto bueno si la vida llega a su máximo.
local function seesLethal(env)
    local cover = env:Widgets("StatusBar", env:Widgets("Frame", env.DoTLetalFrame)[1])[1]
    local lo, hi = cover:GetMinMaxValues()
    local life = Secret.reveal(cover:GetValue())
    assert.are.equal(lo + 1, hi)
    return life <= lo
end

describe("indicador con vida secreta", function()
    it("oculto sin DoTs; aparece al lanzar uno y no lee globales sin simular", function()
        local env = boot({ 5000, 8000 })
        assert.is_false(env.DoTLetalFrame:IsShown())
        env:Cast(172)
        assert.is_true(env.DoTLetalFrame:IsShown())
        assert.are.same({}, env:Missing())
    end)

    it("vida por encima del daño restante: no muere", function()
        local env = boot({ 5000, 8000 })
        env:Cast(172)
        assert.is_false(seesLethal(env))
    end)

    it("vida igual o menor que el daño restante: muere", function()
        local env = boot({ 600, 8000 })
        env:Cast(172)
        assert.is_true(seesLethal(env))
        env:SetHealth("target", 599, 8000)
        assert.is_true(seesLethal(env))
    end)

    it("al caer los ticks el veredicto cambia sin que cambie la vida", function()
        local env = boot({ 450, 8000 })
        env:Cast(172)
        assert.is_true(seesLethal(env)) -- 600 restante
        env:Advance(6.1) -- dos ticks: quedan 400; nadie más le pega
        assert.is_false(seesLethal(env))
    end)

    it("entrega los secretos a barras y texto sin calcular con ellos", function()
        local env = boot({ 5000, 8000 })
        env:Cast(172)
        local frame = env.DoTLetalFrame
        for _, bar in ipairs(env:Widgets("StatusBar", frame)) do
            local _, hi = bar:GetMinMaxValues()
            assert.is_true(Secret.is(hi))
        end
        local texts = env:Widgets("FontString", frame)
        contains(texts[1]:GetText(), "600")
        assert.is_true(Secret.is(texts[2]:GetText()))
        assert.are.equal("5000", Secret.reveal(texts[2]:GetText()))
    end)

    it("se oculta al terminar los DoTs y para el temporizador", function()
        local env = boot({ 5000, 8000 })
        env:Cast(172)
        env:Advance(18.5)
        assert.is_false(env.DoTLetalFrame:IsShown())
        assert.are.equal(0, env:PendingTimers())
    end)

    it("se oculta si el objetivo muere o se cambia de objetivo", function()
        local env = boot({ 5000, 8000 })
        env:Cast(172)
        env:SetTarget({ exists = true, dead = true })
        assert.is_false(env.DoTLetalFrame:IsShown())
        env:SetTarget({ exists = true })
        assert.is_false(env.DoTLetalFrame:IsShown())
    end)

    it("/dotletal mover lo muestra de muestra para colocarlo y guarda la posición", function()
        local env = boot({ 5000, 8000 })
        env:RunSlash("/dotletal mover")
        local frame = env.DoTLetalFrame
        assert.is_true(frame:IsShown())
        frame:ClearAllPoints()
        frame:SetPoint("TOP", env.UIParent, "TOP", 10, -40)
        frame:GetScript("OnDragStop")(frame)
        assert.are.same({ point = "TOP", relativePoint = "TOP", x = 10, y = -40 }, env.DoTLetalDB.frame)
        env:RunSlash("/dotletal mover")
        assert.is_false(frame:IsShown())
        Secret.assertNoSecretKeys(env.DoTLetalDB, "DoTLetalDB")
    end)

    it("las SavedVariables no guardan secretos tras un combate", function()
        local env = boot({ 5000, 8000 })
        env:Cast(172)
        env:Advance(20)
        Secret.assertNoSecretKeys(env.DoTLetalDB, "DoTLetalDB")
        Secret.assertNoSecretKeys(env.DoTLetalCharDB, "DoTLetalCharDB")
    end)
end)

describe("mutaciones del indicador (deben fallar)", function()
    local function bootMutated(old, new)
        return pcall(function()
            local env = boot({ 5000, 8000 }, {
                patch = {
                    [INDICATOR] = function(source)
                        return WowEnv.replace(source, old, new)
                    end,
                },
            })
            env:Cast(172)
        end)
    end

    it("comparar la vida con el daño en Lua falla en esa línea", function()
        local original = "self.cover:SetValue(life)"
        local line = WowEnv.lineOf(INDICATOR, original)
        local ok, err = bootMutated(original, "self.cover:SetValue(life <= shown and 0 or 1)")
        assert.is_false(ok)
        contains(err, INDICATOR .. ":" .. line .. ":")
    end)

    it("restar el daño a la vida falla en esa línea", function()
        local original = "self.health:SetValue(life)"
        local line = WowEnv.lineOf(INDICATOR, original)
        local ok, err = bootMutated(original, "self.health:SetValue(life - shown)")
        assert.is_false(ok)
        contains(err, INDICATOR .. ":" .. line .. ": secret value: la aritmética")
    end)

    it("el original, cargado por el mismo camino, no falla (control)", function()
        local original = "self.cover:SetValue(life)"
        local ok, err = bootMutated(original, original)
        assert(ok, tostring(err))
    end)
end)
