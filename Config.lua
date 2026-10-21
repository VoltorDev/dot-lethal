local addonName, ns = ...
local L = ns.L
local module = ns:NewModule("Config")

-- Panel en Opciones > AddOns con la API nativa Settings (Blizzard_Settings_Shared).
-- Se registra en OnInitialize porque Settings.RegisterAddOnSetting escribe el valor por defecto
-- en la tabla si la clave es nil: hay que hacerlo DESPUÉS de cargar las SavedVariables.
function module:OnInitialize()
    local db = ns.db
    local category, layout = Settings.RegisterVerticalLayoutCategory(L.ADDON_TITLE)

    local function OnSettingChanged()
        ns:ApplySettings()
    end

    local enabled = Settings.RegisterAddOnSetting(
        category,
        addonName .. "_Enabled",
        "enabled",
        db,
        Settings.VarType.Boolean,
        L.OPT_ENABLED,
        ns.DEFAULTS.enabled
    )
    enabled:SetValueChangedCallback(OnSettingChanged)
    Settings.CreateCheckbox(category, enabled, L.OPT_ENABLED_TT)

    local scale = Settings.RegisterAddOnSetting(
        category,
        addonName .. "_Scale",
        "scale",
        db,
        Settings.VarType.Number,
        L.OPT_SCALE,
        ns.DEFAULTS.scale
    )
    scale:SetValueChangedCallback(OnSettingChanged)
    local sliderOptions = Settings.CreateSliderOptions(0.5, 2, 0.05)
    sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
        return ("%.2f"):format(value)
    end)
    Settings.CreateSlider(category, scale, sliderOptions, L.OPT_SCALE_TT)

    local mode = Settings.RegisterAddOnSetting(
        category,
        addonName .. "_Mode",
        "mode",
        db,
        Settings.VarType.String,
        L.OPT_MODE,
        ns.DEFAULTS.mode
    )
    mode:SetValueChangedCallback(OnSettingChanged)
    local function GetModeOptions()
        local container = Settings.CreateControlTextContainer()
        container:Add("classic", L.MODE_CLASSIC)
        container:Add("compact", L.MODE_COMPACT)
        return container:GetData()
    end
    Settings.CreateDropdown(category, mode, GetModeOptions, L.OPT_MODE_TT)

    local targetFrame = Settings.RegisterAddOnSetting(
        category,
        addonName .. "_TargetFrame",
        "targetFrame",
        db,
        Settings.VarType.Boolean,
        L.OPT_TARGETFRAME,
        ns.DEFAULTS.targetFrame
    )
    targetFrame:SetValueChangedCallback(OnSettingChanged)
    Settings.CreateCheckbox(category, targetFrame, L.OPT_TARGETFRAME_TT)

    local nameplate = Settings.RegisterAddOnSetting(
        category,
        addonName .. "_Nameplate",
        "nameplate",
        db,
        Settings.VarType.Boolean,
        L.OPT_NAMEPLATE,
        ns.DEFAULTS.nameplate
    )
    nameplate:SetValueChangedCallback(OnSettingChanged)
    Settings.CreateCheckbox(category, nameplate, L.OPT_NAMEPLATE_TT)

    -- /dotletal mover y /dotletal traza.
    local locked = Settings.RegisterAddOnSetting(
        category,
        addonName .. "_Locked",
        "locked",
        db,
        Settings.VarType.Boolean,
        L.OPT_LOCKED,
        ns.DEFAULTS.locked
    )
    locked:SetValueChangedCallback(OnSettingChanged)
    Settings.CreateCheckbox(category, locked, L.OPT_LOCKED_TT)
    local trace = Settings.RegisterAddOnSetting(
        category,
        addonName .. "_Trace",
        "debug",
        db,
        Settings.VarType.Boolean,
        L.OPT_TRACE,
        ns.DEFAULTS.debug
    )
    Settings.CreateCheckbox(category, trace, L.OPT_TRACE_TT)

    local calibrate = Settings.RegisterAddOnSetting(
        category,
        addonName .. "_Calibrate",
        "calibrate",
        db,
        Settings.VarType.Boolean,
        L.OPT_CALIBRATE,
        ns.DEFAULTS.calibrate
    )
    calibrate:SetValueChangedCallback(OnSettingChanged)
    Settings.CreateCheckbox(category, calibrate, L.OPT_CALIBRATE_TT)

    self:BuildDots(category, layout)
    self:BuildTools(layout)

    Settings.RegisterAddOnCategory(category)
    ns.settingsCategory = category
end

local function Header(layout, text)
    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(text))
end

local function Button(layout, label, buttonText, onClick, tooltip)
    layout:AddInitializer(CreateSettingsButtonInitializer(label, buttonText, onClick, tooltip, true))
end

-- Acción que borra algo: antes, el diálogo de confirmación de Blizzard.
local function Confirm(text, action)
    if StaticPopup_ShowGenericConfirmation then
        StaticPopup_ShowGenericConfirmation(text, action)
    else
        action()
    end
end

-- /dotletal lista. No hay que añadir nada: los DoTs del juego vienen en Datos/ y los talentos se detectan solos.
function module:BuildDots(_, layout)
    Header(layout, L.OPT_SECTION_DOTS)
    Button(layout, L.OPT_LIST, L.OPT_LIST_BUTTON, function()
        SlashCmdList.DOTLETAL("lista")
    end, L.OPT_LIST_TT)
    -- /dotletal calibracion y /dotletal calibracion borrar.
    Button(layout, L.OPT_CALIBRATION, L.OPT_CALIBRATION_BUTTON, function()
        SlashCmdList.DOTLETAL("calibracion")
    end, L.OPT_CALIBRATION_TT)
    Button(layout, L.OPT_CALIBRATION_RESET, L.OPT_RESET_BUTTON, function()
        Confirm(L.OPT_CALIBRATION_RESET_CONFIRM, function()
            ns.Calibration:Reset()
            ns:Print(L.CALIBRATION_RESET)
        end)
    end, L.OPT_CALIBRATION_RESET_TT)
end

-- /dotletal debug y /dotletal reset confirmar.
function module:BuildTools(layout)
    Header(layout, L.OPT_SECTION_TOOLS)
    Button(layout, L.OPT_DEBUG, L.OPT_DEBUG_BUTTON, function()
        ns:PrintDiagnostics()
    end, L.OPT_DEBUG_TT)
    Button(layout, L.OPT_RESET, L.OPT_RESET_BUTTON, function()
        Confirm(L.OPT_RESET_CONFIRM, function()
            ns:ResetDB()
            ns:ApplySettings()
            ns:Print(L.RESET_DONE)
        end)
    end, L.OPT_RESET_TT)
end

-- Abrir el panel está restringido en combate (C_SettingsUtil.OpenSettingsPanel lleva HasRestrictions).
function ns:OpenSettings()
    if InCombatLockdown() then
        self:Print(L.ERR_COMBAT)
        return
    end
    Settings.OpenToCategory(self.settingsCategory:GetID())
end

-- Compartimento de addons (botón del minimapa). Los nombres coinciden con el TOC.
-- El cliente llama a la función de clic con (addonName, buttonName) y a las de ratón
-- con (addonName, menuButtonFrame).
function DoTLetal_OnAddonCompartmentClick()
    ns:OpenSettings()
end

function DoTLetal_OnAddonCompartmentEnter(_, menuButtonFrame)
    GameTooltip:SetOwner(menuButtonFrame, "ANCHOR_LEFT")
    GameTooltip:SetText(L.ADDON_TITLE)
    GameTooltip:AddLine(L.COMPARTMENT_TOOLTIP, 1, 1, 1)
    GameTooltip:Show()
end

function DoTLetal_OnAddonCompartmentLeave()
    GameTooltip:Hide()
end
