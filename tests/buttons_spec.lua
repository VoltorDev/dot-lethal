---@diagnostic disable: need-check-nil
-- Aviso de renovación encima de los botones de las barras de acción (Modules/Indicator.lua, UpdateButtons): un
-- marco propio hijo del botón, sin escribir nada en el botón de Blizzard.
local WowEnv = require("wow_env")

local TOC = "DoTLetal.toc"
local SPELLS = {
    [172] = { "Corruption", "Corrupts the target, causing 822 Shadow damage over 18 sec.", 2000 },
    [348] = {
        "Immolate",
        "Burns the enemy for 11 Fire damage and then an additional 20 Fire damage over 15 sec.",
        2000,
    },
}

local function boot(opts)
    opts = opts or {}
    opts.spells = opts.spells or SPELLS
    opts.target = { exists = true, attackable = true }
    opts.health = { target = { 5000, 8000 } }
    local env, ns = WowEnv.boot(TOC, opts)
    env:SettingsRegistry().settings[env:AddonName() .. "_RenewLead"]:SetValue(1.5) -- tiempos de estos tests
    return env, ns
end

-- Botón de la barra con ese hechizo; avisa al addon de que cambió la ranura.
local function addButton(env, name, slot, spellID)
    local button = env:AddActionButton(name, slot)
    env:SetAction(slot, spellID)
    return button
end

-- Marco del aviso hijo del botón, sus 4 bordes y el texto.
local function overlayOf(env, button)
    local overlay = env:Widgets("Frame", button)[1]
    if not overlay then
        return nil
    end
    return overlay, env:Widgets("Texture", overlay), env:Widgets("FontString", overlay)[1]
end

describe("aviso en los botones de acción", function()
    it("pinta el marco y el texto encima del botón del DoT y no repite el icono sobre el panel", function()
        local env = boot()
        local button = addButton(env, "ActionButton1", 1, 348)
        local ready = overlayOf(env, button)
        assert.is_false(ready:IsShown()) -- fuera de combate ya está creado, oculto
        assert.are.same({}, env:Widgets("Frame", env.ActionButton2)) -- botones sin DoT: nada
        env:Cast(348)
        assert.is_false(ready:IsShown())
        env:Advance(12.05)
        local overlay, edges, label = overlayOf(env, button)
        assert.is_true(overlay:IsShown())
        assert.are.equal(4, #edges)
        assert.are.equal("0.9", label:GetText())
        assert.are.same({ 1, 0.72, 0.1, 1 }, { edges[1]:LastCall("SetColorTexture") })
        assert.is_false(env.DoTLetalAlert:IsShown()) -- ya está en la barra
        env:Advance(1)
        assert.are.equal("NOW!", label:GetText())
        env:Advance(2.5)
        assert.are.equal("DROPPED", label:GetText())
        env:Advance(9)
        assert.is_false(overlay:IsShown())
        assert.are.same({}, env:Missing())
    end)

    it("otro rango del mismo hechizo en la barra también vale (se empareja por nombre)", function()
        local spells = {}
        for id, s in pairs(SPELLS) do
            spells[id] = s
        end
        spells[707] = { "Immolate", SPELLS[348][2], 2000 } -- Inmolar (rango 2)
        local env = boot({ spells = spells })
        local button = addButton(env, "MultiBarBottomLeftButton3", 15, 707)
        env:Cast(348)
        env:Advance(13.05)
        local overlay, _, label = overlayOf(env, button)
        assert.is_true(overlay:IsShown())
        assert.are.equal("NOW!", label:GetText())
    end)

    it("si el botón está oculto, el aviso sale en los iconos sobre el panel", function()
        local env = boot()
        local button = addButton(env, "ActionButton2", 2, 348)
        button:Hide()
        env:Cast(348)
        env:Advance(13.05)
        local overlay = overlayOf(env, button)
        assert.is_true(overlay == nil or not overlay:IsVisible())
        assert.is_true(env.DoTLetalAlert:IsShown())
    end)

    it("las opciones: sin botones, todo a los iconos; «siempre», en los dos sitios", function()
        local env = boot()
        local settings = env:SettingsRegistry().settings
        local button = addButton(env, "ActionButton1", 1, 348)
        settings[env:AddonName() .. "_RenewButtons"]:SetValue(false)
        env:Cast(348)
        env:Advance(13.05)
        local overlay = overlayOf(env, button)
        assert.is_true(overlay == nil or not overlay:IsShown())
        assert.is_true(env.DoTLetalAlert:IsShown())
        settings[env:AddonName() .. "_RenewButtons"]:SetValue(true)
        settings[env:AddonName() .. "_RenewStrip"]:SetValue("always")
        assert.is_true(overlayOf(env, button):IsShown())
        assert.is_true(env.DoTLetalAlert:IsShown())
    end)

    it("al cambiar el hechizo de la ranura el aviso se va de ese botón", function()
        local env = boot()
        local button = addButton(env, "ActionButton1", 1, 348)
        env:Cast(348)
        env:Advance(13.05)
        assert.is_true(overlayOf(env, button):IsShown())
        env:SetAction(1, 172)
        assert.is_false(overlayOf(env, button):IsShown())
        assert.is_true(env.DoTLetalAlert:IsShown()) -- Inmolar ya no está en ninguna barra
    end)

    it("no escribe nada en el botón de Blizzard (sin taint)", function()
        local env = boot()
        local button = addButton(env, "ActionButton1", 1, 348)
        local before = {}
        for k, v in pairs(button) do
            before[k] = v
        end
        env:Cast(348)
        env:Advance(16)
        for k, v in pairs(button) do
            assert(before[k] == v, "el addon ha cambiado el campo " .. tostring(k) .. " del botón")
        end
        assert.are.same({}, button:Calls("SetAlpha"))
    end)

    it("con el panel desbloqueado, la muestra va a los iconos y no a los botones", function()
        local env = boot()
        local button = addButton(env, "ActionButton1", 1, 348)
        env:RunSlash("/dotletal " .. "mover")
        local overlay = overlayOf(env, button)
        assert.is_true(overlay == nil or not overlay:IsShown())
        assert.is_true(env.DoTLetalAlert:IsShown())
    end)
end)
