-- Panel de opciones (Config.lua) con la API Settings: se registra DESPUÉS de cargar las
-- SavedVariables, queda enlazado a esa misma tabla y cada cambio se guarda y se aplica.
local WowEnv = require("wow_env")

local TOC = "DoTLetal.toc"

local function countKeys(t)
    local n = 0
    for _ in pairs(t) do
        n = n + 1
    end
    return n
end

describe("opciones en Settings", function()
    it("no registra nada al cargar los ficheros; sí tras el ADDON_LOADED propio", function()
        local env = WowEnv.new()
        env.DoTLetalDB = { schema = 1, scale = 1.25 }
        local ns = env:LoadToc(TOC) or error("el addon no cargó")
        local registry = env:SettingsRegistry()
        assert.are.equal(0, countKeys(registry.settings))

        env:Fire("ADDON_LOADED", env:AddonName(), false)
        assert.are.equal(3, countKeys(registry.settings))
        assert.are.equal(1, #registry.addOnCategories)
        assert.are.equal(ns.settingsCategory, registry.addOnCategories[1])
        assert.are.equal(ns.L.ADDON_TITLE, ns.settingsCategory:GetName())

        local expected = {
            Enabled = { "enabled", "boolean" },
            Scale = { "scale", "number" },
            Mode = { "mode", "string" },
        }
        for suffix, info in pairs(expected) do
            local setting = registry.settings[env:AddonName() .. "_" .. suffix]
            assert(setting ~= nil, "falta el ajuste " .. suffix)
            assert.are.equal(env.DoTLetalDB, setting.variableTbl) -- la tabla ya cargada, no otra
            assert.are.equal(info[1], setting.variableKey)
            assert.are.equal(info[2], setting:GetVariableType())
        end
        assert.are.equal(1.25, registry.settings[env:AddonName() .. "_Scale"]:GetValue()) -- no pisa lo guardado
    end)

    it("crea un control por ajuste: casilla, deslizador y desplegable", function()
        local env = WowEnv.boot(TOC)
        local kinds = {}
        for _, control in ipairs(env:SettingsRegistry().controls) do
            kinds[#kinds + 1] = control.kind
        end
        assert.are.same({ "Checkbox", "Slider", "Dropdown" }, kinds)
    end)

    it("el desplegable ofrece el modo por defecto y el deslizador formatea con dos decimales", function()
        local env, ns = WowEnv.boot(TOC)
        local controls = env:SettingsRegistry().controls
        local values = {}
        for _, option in ipairs(controls[3].options()) do
            values[option.value] = true
        end
        assert.is_true(values[ns.DEFAULTS.mode])
        local slider = controls[2].options
        assert.are.equal(0.5, slider.minValue)
        assert.are.equal(2, slider.maxValue)
        local label = slider.formatters[env.MinimalSliderWithSteppersMixin.Label.Right]
        assert.are.equal("1.50", label(1.5))
    end)

    it("cambiar una opción la guarda y la aplica al marco", function()
        local env = WowEnv.boot(TOC)
        local settings = env:SettingsRegistry().settings
        local frame = env.DoTLetalFrame

        settings[env:AddonName() .. "_Scale"]:SetValue(1.5)
        assert.are.equal(1.5, env.DoTLetalDB.scale)
        assert.are.equal(1.5, frame:GetScale())

        env.DoTLetalDB.locked = false -- desbloqueado se ve aunque no haya DoTs
        settings[env:AddonName() .. "_Enabled"]:SetValue(true)
        assert.is_true(frame:IsShown())
        settings[env:AddonName() .. "_Enabled"]:SetValue(false)
        assert.is_false(env.DoTLetalDB.enabled)
        assert.is_false(frame:IsShown())

        settings[env:AddonName() .. "_Enabled"]:SetValue(true)
        local text = env:Widgets("FontString", frame)[1]
        assert.is_true(text:IsShown())
        settings[env:AddonName() .. "_Mode"]:SetValue("compact")
        assert.is_false(text:IsShown())
    end)

    it("un valor de otro tipo se rechaza, como en el cliente", function()
        local env = WowEnv.boot(TOC)
        local scale = env:SettingsRegistry().settings[env:AddonName() .. "_Scale"]
        assert.has_error(function()
            scale:SetValue("2")
        end)
        assert.are.equal(1, env.DoTLetalDB.scale)
    end)
end)
