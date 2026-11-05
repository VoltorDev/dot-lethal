-- Panel y marcas (Modules/Indicator.lua, Marker.lua) con la vida del objetivo secreta, como en
-- Forever y retail: la vida se entrega a barras y curvas sin compararla.
local WowEnv = require("wow_env")
local Secret = require("secret_mock")
Secret.registerFormatter(assert)

local TOC = "DoTLetal.toc"
local INDICATOR = "Modules/Indicator.lua"
local MARKER = "Marker.lua"
local SPELLS = {
    [172] = { "Corruption", "Corrupts the target, causing 600 Shadow damage over 18 sec." },
    [348] = { "Immolate", "Burns the enemy for 11 Fire damage and then an additional 300 Fire damage over 15 sec." },
}

local function contains(text, fragment)
    assert(text:find(fragment, 1, true), "no aparece «" .. fragment .. "» en:\n" .. text)
end

local function boot(health, extra)
    local opts = {
        spells = SPELLS,
        target = { exists = true, attackable = true },
        health = { target = health },
        targetFrame = true,
        nameplate = true,
    }
    for k, v in pairs(extra or {}) do
        opts[k] = v
    end
    return WowEnv.boot(TOC, opts)
end

local function targetBar(env)
    return env.TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar
end

-- Partes de la marca colgada de una barra: [1] marco que recorta (pérdida), [2] ancla (calavera).
local function markerParts(env, host)
    local frames = env:Widgets("Frame", host)
    local clip, anchor = frames[1], frames[2]
    local loss = env:Widgets("StatusBar", clip)[1]
    local skull = env:Widgets("Texture", anchor)[1]
    local gate = env:Widgets("StatusBar", anchor)[1]
    return { clip = clip, anchor = anchor, loss = loss, skull = skull, gate = gate }
end

-- Lo que vería el jugador: ¿se ve la calavera?
local function seesSkull(env, host)
    local p = markerParts(env, host)
    if not p.anchor:IsShown() then
        return false
    end
    if p.skull:IsShown() then
        return Secret.reveal(p.skull:GetAlpha()) == 1
    end
    local lo, hi = p.gate:GetMinMaxValues()
    assert.are.equal(lo + 1, hi)
    return Secret.reveal(p.gate:GetValue()) <= lo
end

describe("marcas en la barra de vida del objetivo", function()
    it("no aparecen sin DoTs; con un DoT se cuelgan del marco de objetivo y de la placa", function()
        local env = boot({ 5000, 8000 })
        assert.is_false(markerParts(env, targetBar(env)).anchor:IsShown())
        env:Cast(172)
        assert.is_true(markerParts(env, targetBar(env)).anchor:IsShown())
        local plate = env.C_NamePlate.GetNamePlateForUnit("target")
        assert.is_true(markerParts(env, plate.UnitFrame.healthBar).anchor:IsShown())
        assert.are.same({}, env:Missing())
    end)

    it("la pérdida es el daño restante, con el máximo de vida y anclada al final del relleno", function()
        local env = boot({ 5000, 8000 }, { secretMaxHealth = true })
        env:Cast(172)
        env:Cast(348)
        local bar = targetBar(env)
        local loss = markerParts(env, bar).loss
        local lo, hi = loss:GetMinMaxValues()
        assert.are.equal(0, lo)
        assert.is_true(Secret.is(hi))
        assert.are.equal(900, loss:GetValue())
        local _, relativeTo = loss:GetPoint(1)
        assert.are.equal(bar:GetStatusBarTexture(), relativeTo)
        assert.are.same({ true }, { loss:LastCall("SetReverseFill") })
    end)

    it("vida máxima legible: calavera por curva solo si los DoTs bastan", function()
        local env = boot({ 5000, 8000 })
        env:Cast(172)
        assert.is_false(seesSkull(env, targetBar(env)))
        env:SetHealth("target", 600, 8000)
        assert.is_true(seesSkull(env, targetBar(env)))
        env:SetHealth("target", 601, 8000)
        assert.is_false(seesSkull(env, targetBar(env)))
    end)

    it("vida máxima secreta: calavera por la barra compuerta", function()
        local env = boot({ 5000, 8000 }, { secretMaxHealth = true })
        env:Cast(172)
        local parts = markerParts(env, targetBar(env))
        assert.is_false(parts.skull:IsShown())
        assert.is_false(seesSkull(env, targetBar(env)))
        env:SetHealth("target", 600, 8000)
        assert.is_true(seesSkull(env, targetBar(env)))
    end)

    it("al caer los ticks aparece la calavera sin que cambie la vida", function()
        local env = boot({ 450, 8000 })
        env:Cast(172)
        assert.is_true(seesSkull(env, targetBar(env))) -- 600 restante
        env:Advance(6.1) -- dos ticks: quedan 400
        assert.is_false(seesSkull(env, targetBar(env)))
    end)

    it("se quitan al terminar los DoTs, al cambiar de objetivo o si las opciones lo desactivan", function()
        local env = boot({ 5000, 8000 })
        env:Cast(172)
        env:Advance(18.5)
        assert.is_false(markerParts(env, targetBar(env)).anchor:IsShown())
        env:Advance(9) -- el aviso de DoT caído (renew_spec.lua) mantiene el reloj 8 s más
        assert.are.equal(0, env:PendingTimers())
        env:Cast(172)
        env:SetTarget({ exists = true })
        assert.is_false(markerParts(env, targetBar(env)).anchor:IsShown())
        env:Cast(172)
        env:SettingsRegistry().settings[env:AddonName() .. "_TargetFrame"]:SetValue(false)
        assert.is_false(markerParts(env, targetBar(env)).anchor:IsShown())
    end)

    it("sin marco de objetivo ni placa no falla", function()
        local env = boot({ 5000, 8000 }, { targetFrame = false, nameplate = false, globals = { TargetFrame = false } })
        env:Cast(172)
        assert.is_true(env.DoTLetalFrame:IsShown())
        assert.are.same({}, env:Missing())
    end)
end)

describe("panel", function()
    it("enseña daño por segundo, daño restante y cada DoT con su tiempo", function()
        local env = boot({ 5000, 8000 })
        env:Cast(172)
        env:Cast(348)
        local frame = env.DoTLetalFrame
        assert.is_true(frame:IsShown())
        local texts = env:Widgets("FontString", frame)
        contains(texts[1]:GetText(), "DoTs 53/s") -- 600/18 + 300/15 = 53,3
        contains(texts[1]:GetText(), "900")
        assert.is_true(Secret.is(texts[2]:GetText())) -- vida del objetivo: secreta, solo se pinta
        assert.are.equal("Immolate", texts[3]:GetText())
        contains(texts[4]:GetText(), "15s · 20/s")
        assert.are.equal("Corruption", texts[5]:GetText())
        contains(texts[6]:GetText(), "18s · 33/s")
    end)

    it("modo compacto: solo los totales", function()
        local env = boot({ 5000, 8000 })
        env:SettingsRegistry().settings[env:AddonName() .. "_Mode"]:SetValue("compact")
        env:Cast(172)
        local texts = env:Widgets("FontString", env.DoTLetalFrame)
        assert.is_true(texts[1]:IsShown())
        assert.is_false(texts[3]:IsShown())
    end)

    it("/dotletal mover lo enseña de muestra para colocarlo y guarda la posición", function()
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
        local env = boot({ 5000, 8000 }, { secretMaxHealth = true })
        env:Cast(172)
        env:Advance(20)
        Secret.assertNoSecretKeys(env.DoTLetalDB, "DoTLetalDB")
        Secret.assertNoSecretKeys(env.DoTLetalCharDB, "DoTLetalCharDB")
    end)

    it("en retail funciona igual", function()
        local env = boot({ 500, 8000 }, {
            client = "retail",
            build = { "12.1.5", "99999", "Oct 1 2026", 120105 },
            haste = 20,
        })
        env:Cast(172)
        assert.is_true(env.DoTLetalFrame:IsShown())
        assert.is_true(seesSkull(env, targetBar(env))) -- 600 * 1,2 = 720 >= 500
        assert.are.same({}, env:Missing())
    end)
end)

describe("mutaciones (deben fallar)", function()
    local function bootMutated(file, old, new)
        return pcall(function()
            local env = boot({ 5000, 8000 }, {
                secretMaxHealth = true,
                patch = {
                    [file] = function(source)
                        return WowEnv.replace(source, old, new)
                    end,
                },
            })
            env:Cast(172)
        end)
    end

    it("comparar la vida con el daño en Lua falla en esa línea", function()
        local original = "self.gate:SetValue(life)"
        local line = WowEnv.lineOf(MARKER, original)
        local ok, err = bootMutated(MARKER, original, "self.gate:SetValue(life <= damage and 0 or 1)")
        assert.is_false(ok)
        contains(err, MARKER .. ":" .. line .. ":")
    end)

    it("restar el daño a la vida falla en esa línea", function()
        local original = "self.panelBar:SetValue(life)"
        local line = WowEnv.lineOf(INDICATOR, original)
        local ok, err = bootMutated(INDICATOR, original, "self.panelBar:SetValue(life - damage)")
        assert.is_false(ok)
        contains(err, INDICATOR .. ":" .. line .. ": secret value: la aritmética")
    end)

    it("el original, cargado por el mismo camino, no falla (control)", function()
        local original = "self.gate:SetValue(life)"
        local ok, err = bootMutated(MARKER, original, original)
        assert(ok, tostring(err))
    end)
end)
