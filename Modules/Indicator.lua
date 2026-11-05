local addonName, ns = ...
local L = ns.L
local Dots = ns.Dots
local Marker = ns.Marker
local module = ns:NewModule("Indicator")

-- Panel y marcas: daño por segundo de los DoTs, tiempo de cada uno y, en las barras de vida del
-- objetivo (panel, marco de objetivo y su placa), lo que perderá por DoTs y una calavera si muere.
-- La vida del objetivo solo se entrega a Marker; aquí no se compara ni se opera con ella.
local TICK = 0.2 -- segundos entre actualizaciones mientras quedan DoTs
local WIDTH = 170
local ROW = 14
local MAX_ROWS = 6
-- Avisos de renovación (Dots.RenewPhase): iconos grandes encima del panel, uno por DoT que pide atención.
local ALERT_SIZE = 30
local ALERT_MAX = 4
local PHASE_COLOR = {
    ok = { 1, 1, 1 },
    soon = { 1, 0.72, 0.1 }, -- ámbar: prepárate, aún no
    now = { 0.25, 1, 0.25 }, -- verde: lánzalo ya
    dropped = { 1, 0.15, 0.15 }, -- rojo: se ha caído
}

local function Abbrev(n)
    return AbbreviateNumbers(math.floor(n + 0.5))
end

-- Barras de vida ajenas del objetivo: la del marco de objetivo de Blizzard y la de su placa
-- (Blizzard o Plater). Si un addon las cambia de sitio o de nombre, simplemente no se marcan.
local function TargetFrameBar()
    local content = TargetFrame and TargetFrame.TargetFrameContent
    local main = content and content.TargetFrameContentMain
    local container = main and main.HealthBarsContainer
    return container and container.HealthBar
end

local function NameplateBar()
    ---@type table? placa de Blizzard (UnitFrame) o de Plater (unitFrame)
    local plate = C_NamePlate.GetNamePlateForUnit("target")
    if not plate then
        return nil
    end
    local unitFrame = plate.UnitFrame or plate.unitFrame
    return unitFrame and unitFrame.healthBar
end

function module:OnEnable()
    Dots.Configure(ns.Client.isRetail)

    local frame = CreateFrame("Frame", addonName .. "Frame", UIParent)
    frame:SetSize(WIDTH, 34)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:SetDontSavePosition(true) -- la posición la guarda el addon, no el layout del cliente
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(f)
        f:StopMovingOrSizing()
        local point, _, relativePoint, x, y = f:GetPoint()
        local position = ns.db.frame
        position.point, position.relativePoint, position.x, position.y = point, relativePoint, x, y
    end)
    local background = frame:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0, 0, 0, 0.45)

    -- Barra de vida propia del panel (la calavera de su marca queda a su izquierda).
    local health = CreateFrame("StatusBar", nil, frame)
    health:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    health:SetStatusBarColor(0.15, 0.7, 0.15)
    health:SetSize(WIDTH - 24, 10)
    health:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -3)
    local healthBg = health:CreateTexture(nil, "BACKGROUND")
    healthBg:SetAllPoints()
    healthBg:SetColorTexture(0.1, 0.1, 0.1, 0.8)

    local header = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    header:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -16)
    local healthText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    healthText:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -16)

    local rows = {}
    for i = 1, MAX_ROWS do
        local row = {}
        row.icon = frame:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(ROW - 2, ROW - 2)
        row.icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -30 - (i - 1) * ROW)
        row.name = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.name:SetPoint("LEFT", row.icon, "RIGHT", 3, 0)
        row.name:SetWidth(78)
        row.name:SetJustifyH("LEFT")
        row.info = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.info:SetPoint("RIGHT", frame, "TOPRIGHT", -4, -30 - (i - 1) * ROW - (ROW - 2) / 2)
        rows[i] = row
    end

    frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
    frame:RegisterUnitEvent("UNIT_HEALTH", "target")
    frame:RegisterUnitEvent("UNIT_MAXHEALTH", "target")
    frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    -- Talentos, especialización o hechizos nuevos: los DoTs y su ritmo de ticks se recalculan solos.
    frame:RegisterEvent("SPELLS_CHANGED")
    frame:RegisterEvent("PLAYER_TALENT_UPDATE")
    frame:RegisterEvent("TRAIT_CONFIG_UPDATED")
    frame:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED")
    frame:SetScript("OnEvent", function(_, event, ...)
        module:OnEvent(event, ...)
    end)

    -- Avisos de renovación: fuera del panel (que se oculta cuando ya no queda daño, justo cuando un DoT caído
    -- más importa), anclados encima de él.
    local alert = CreateFrame("Frame", addonName .. "Alert", UIParent)
    alert:SetSize(ALERT_MAX * (ALERT_SIZE + 6), ALERT_SIZE + 16)
    alert:SetPoint("BOTTOM", frame, "TOP", 0, 4)
    alert:Hide()
    local icons = {}
    for i = 1, ALERT_MAX do
        local slot = {}
        slot.border = alert:CreateTexture(nil, "BACKGROUND")
        slot.border:SetSize(ALERT_SIZE + 4, ALERT_SIZE + 4)
        slot.border:SetPoint("TOPLEFT", alert, "TOPLEFT", (i - 1) * (ALERT_SIZE + 6), 0)
        slot.icon = alert:CreateTexture(nil, "ARTWORK")
        slot.icon:SetSize(ALERT_SIZE, ALERT_SIZE)
        slot.icon:SetPoint("CENTER", slot.border, "CENTER", 0, 0)
        slot.label = alert:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        slot.label:SetPoint("TOP", slot.border, "BOTTOM", 0, -1)
        icons[i] = slot
    end
    self.alert, self.alertIcons, self.sounded = alert, icons, {}
    self.overlays = {} -- botón de acción -> marco del aviso encima (Modules/Indicator.lua, UpdateButtons)
    -- Cambios en las barras: el mapa de botones se rehace en la siguiente actualización.
    for _, event in ipairs({
        "ACTIONBAR_SLOT_CHANGED",
        "ACTIONBAR_PAGE_CHANGED",
        "UPDATE_BONUS_ACTIONBAR",
        "UPDATE_SHAPESHIFT_FORM",
        "PLAYER_REGEN_ENABLED",
    }) do
        frame:RegisterEvent(event)
    end

    self.frame, self.header, self.healthText, self.rows = frame, header, healthText, rows
    self.panelBar = health
    self.panelMarker = Marker.New(health, 14)
    self.hostMarkers = {} -- barra anfitriona -> Marker (las placas se reciclan: una por barra)
    self:MarkerFor(TargetFrameBar()) -- fuera de combate: el marco de objetivo es de Blizzard
    Dots.Rebuild()
    Dots.OnTargetChanged()
    self:ApplySettings()
end

local REMAP = {
    ACTIONBAR_SLOT_CHANGED = true,
    ACTIONBAR_PAGE_CHANGED = true,
    UPDATE_BONUS_ACTIONBAR = true,
    UPDATE_SHAPESHIFT_FORM = true,
    PLAYER_REGEN_ENABLED = true,
    PLAYER_ENTERING_WORLD = true,
    SPELLS_CHANGED = true,
}

function module:OnEvent(event, ...)
    if REMAP[event] then
        self.buttonMap = nil -- otra ranura, página o hechizo: se vuelve a buscar qué botón tiene cada DoT
        if ns.db.renewButtons and not InCombatLockdown() then
            self:ButtonMap()
        end
    end
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        local _, _, spellID = ...
        if Dots.OnCast(spellID, GetTime()) then
            self:StartTicker()
        end
    elseif event == "PLAYER_TARGET_CHANGED" then
        Dots.OnTargetChanged()
        Dots.Prune(GetTime())
    elseif event == "PLAYER_ENTERING_WORLD" then
        Dots.Clear()
    elseif
        event == "SPELLS_CHANGED"
        or event == "PLAYER_TALENT_UPDATE"
        or event == "TRAIT_CONFIG_UPDATED"
        or event == "ACTIVE_PLAYER_SPECIALIZATION_CHANGED"
    then
        Dots.Rebuild()
    end
    self:Update()
end

function module:StartTicker()
    if not self.ticker then
        self.ticker = C_Timer.NewTicker(TICK, function()
            module:Update()
        end)
    end
end

function module:StopTicker()
    if self.ticker then
        self.ticker:Cancel()
        self.ticker = nil
    end
end

function module:HostBars()
    local db, bars = ns.db, {}
    if db.targetFrame then
        bars[#bars + 1] = TargetFrameBar()
    end
    if db.nameplate then
        bars[#bars + 1] = NameplateBar()
    end
    return bars
end

function module:MarkerFor(bar)
    if type(bar) ~= "table" or type(bar.GetStatusBarTexture) ~= "function" then
        return nil
    end
    local marker = self.hostMarkers[bar]
    if not marker then
        marker = Marker.New(bar)
        self.hostMarkers[bar] = marker
    end
    return marker
end

-- Daño de muestra con el marco desbloqueado para moverlo.
local PREVIEW = {
    damage = 1000,
    dps = 125,
    list = { { name = "DoT", damage = 1000, seconds = 8, dps = 125, phase = "ok" } },
    alerts = { { name = "DoT", phase = "now", wait = 0 } },
}

-- Botones de las barras de acción ------------------------------------------------------------------------------
-- El aviso se pinta encima del botón de cada DoT: un marco de color y un texto, en un marco propio hijo del botón
-- (se oculta con él) que no toca nada del botón: no se escribe ningún campo suyo ni se llama a ningún método que
-- lo cambie, así que no hay taint. Botones de Blizzard (ActionButtonUtil.ActionBarButtonNames): cada uno guarda
-- su ranura en `.action` (ActionButton.lua:545), y C_ActionBar.GetSpell(ranura) da el hechizo, sin secretos.
-- Los rangos: se empareja por nombre, como el resto del addon.
local BUTTON_NAMES = {
    "ActionButton",
    "MultiBarBottomLeftButton",
    "MultiBarBottomRightButton",
    "MultiBarLeftButton",
    "MultiBarRightButton",
    "MultiBar5Button",
    "MultiBar6Button",
    "MultiBar7Button",
}
local EDGE = 2 -- grosor del marco en píxeles

local function SlotSpellName(slot)
    if type(slot) ~= "number" or issecretvalue(slot) or slot <= 0 then
        return nil
    end
    if not C_ActionBar.HasAction(slot) then
        return nil
    end
    local spellID = C_ActionBar.GetSpell(slot)
    if spellID == nil or issecretvalue(spellID) then
        return nil
    end
    -- Solo interesan los DoTs (cualquier rango: Dots.Definition también busca por nombre).
    if not Dots.Definition(spellID) then
        return nil
    end
    return C_Spell.GetSpellName(spellID)
end

-- nombre del DoT -> lista de botones que lo tienen. Se rehace cuando cambian las barras (map = nil). Fuera de
-- combate deja ya creados (ocultos) los marcos de aviso de esos botones, para no crearlos en pleno combate.
function module:ButtonMap()
    if self.buttonMap then
        return self.buttonMap
    end
    local map = {}
    local names = (ActionButtonUtil and ActionButtonUtil.ActionBarButtonNames) or BUTTON_NAMES
    local prepare = not InCombatLockdown()
    for _, prefix in ipairs(names) do
        for i = 1, 12 do
            local button = _G[prefix .. i]
            local name = type(button) == "table" and SlotSpellName(button.action)
            if name then
                map[name] = map[name] or {}
                table.insert(map[name], button)
                if prepare then
                    self:OverlayFor(button)
                end
            end
        end
    end
    self.buttonMap = map
    return map
end

function module:OverlayFor(button)
    local overlay = self.overlays[button]
    if overlay then
        return overlay
    end
    overlay = CreateFrame("Frame", nil, button)
    overlay:SetAllPoints(button)
    overlay:SetFrameLevel(button:GetFrameLevel() + 10)
    overlay.edges = {}
    local sides = {
        { "TOPLEFT", "TOPRIGHT", nil, EDGE },
        { "BOTTOMLEFT", "BOTTOMRIGHT", nil, EDGE },
        { "TOPLEFT", "BOTTOMLEFT", EDGE, nil },
        { "TOPRIGHT", "BOTTOMRIGHT", EDGE, nil },
    }
    for i, side in ipairs(sides) do
        local edge = overlay:CreateTexture(nil, "OVERLAY")
        edge:SetPoint(side[1], overlay, side[1], 0, 0)
        edge:SetPoint(side[2], overlay, side[2], 0, 0)
        if side[3] then
            edge:SetWidth(side[3])
        else
            edge:SetHeight(side[4])
        end
        overlay.edges[i] = edge
    end
    overlay.label = overlay:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    overlay.label:SetPoint("CENTER", overlay, "CENTER", 0, 0)
    overlay:Hide()
    self.overlays[button] = overlay
    return overlay
end

local function PaintOverlay(overlay, a, now)
    local color = PHASE_COLOR[a.phase] or PHASE_COLOR.ok
    local blink = a.phase == "dropped" and math.floor(now * 3) % 2 == 1
    for _, edge in ipairs(overlay.edges) do
        edge:SetColorTexture(color[1], color[2], color[3], blink and 0.35 or 1)
    end
    overlay.label:SetTextColor(color[1], color[2], color[3])
    if a.phase == "soon" then
        overlay.label:SetFormattedText("%.1f", a.wait)
    else
        overlay.label:SetText(a.phase == "dropped" and L.RENEW_DROPPED or L.RENEW_NOW)
    end
    overlay:Show()
end

-- Pinta los avisos en los botones y devuelve los que no se han podido poner en ninguno visible.
function module:UpdateButtons(alerts, show, now)
    local painted, missing = {}, {}
    local map = (show and ns.db.renewButtons) and self:ButtonMap() or {}
    for _, a in ipairs(show and alerts or {}) do
        local onButton = false
        for _, button in ipairs(map[a.name] or {}) do
            if button:IsVisible() then
                local overlay = self:OverlayFor(button)
                PaintOverlay(overlay, a, now)
                painted[overlay] = true
                onButton = true
            end
        end
        if not onButton then
            missing[#missing + 1] = a
        end
    end
    for _, overlay in pairs(self.overlays) do
        if not painted[overlay] then
            overlay:Hide()
        end
    end
    return missing
end

-- Avisos de renovación: en los botones de acción y, según la opción, en los iconos sobre el panel (siempre, solo
-- los DoTs que no están en ninguna barra visible, o nunca). Los caídos parpadean; con el sonido activado, suena
-- una vez cuando un DoT pasa a «ya» o se cae (no vuelve a sonar hasta que se relanza).
function module:UpdateAlerts(alerts, show, now, preview)
    local db = ns.db
    local urgent = {}
    local missing = self:UpdateButtons(alerts, show and not preview, now)
    local strip = (db.renewStrip == "always" or preview) and alerts or (db.renewStrip == "fallback" and missing) or {}
    local shown = show and math.min(#strip, ALERT_MAX) or 0
    for i, slot in ipairs(self.alertIcons) do
        local a = i <= shown and strip[i]
        if a then
            local color = PHASE_COLOR[a.phase] or PHASE_COLOR.ok
            local blink = a.phase == "dropped" and math.floor(now * 3) % 2 == 1
            slot.border:SetColorTexture(color[1], color[2], color[3], blink and 0.35 or 0.9)
            slot.icon:SetTexture(a.icon or 134400)
            slot.label:SetTextColor(color[1], color[2], color[3])
            if a.phase == "soon" then
                slot.label:SetFormattedText("%.1f", a.wait)
            else
                slot.label:SetText(a.phase == "dropped" and L.RENEW_DROPPED or L.RENEW_NOW)
            end
        end
        slot.border:SetShown(a and true or false)
        slot.icon:SetShown(a and true or false)
        slot.label:SetShown(a and true or false)
    end
    for _, a in ipairs(show and not preview and alerts or {}) do
        if a.phase == "now" or a.phase == "dropped" then
            urgent[a.name] = true
        end
    end
    local fresh = false
    for name in pairs(urgent) do
        if not self.sounded[name] then
            fresh = true
        end
    end
    if fresh and db.renewSound then
        PlaySound(SOUNDKIT.RAID_WARNING, "Master")
    end
    self.sounded = urgent
    self.alert:SetShown(shown > 0)
end

function module:Update()
    local frame = self.frame
    if not frame then
        return
    end
    local db = ns.db
    local hasTarget = UnitExists("target")
    if hasTarget and UnitIsDeadOrGhost("target") then
        Dots.TargetDied(GetTime()) -- muerto: sus DoTs ya no cuentan ni hacen daño
        hasTarget = false
    end
    local now = GetTime()
    local state = Dots.TargetState(now)
    -- Un DoT caído se sigue avisando un rato aunque ya no quede daño: el reloj sigue mientras haya avisos.
    if state.damage <= 0 and #state.alerts == 0 then
        self:StopTicker()
    end
    local active = db.enabled and hasTarget and state.damage > 0
    local previewing = db.enabled and not db.locked and not active
    if previewing and #state.alerts == 0 then
        self:UpdateAlerts(PREVIEW.alerts, true, now, true)
    else
        self:UpdateAlerts(state.alerts, db.enabled and hasTarget, now)
    end

    -- Marcas en las barras ajenas: solo con DoTs reales.
    local used = {}
    if active then
        local damage = math.floor(state.damage)
        for _, bar in ipairs(self:HostBars()) do
            local marker = self:MarkerFor(bar)
            if marker then
                marker:Update("target", damage, UnitHealth("target"), UnitHealthMax("target"))
                used[marker] = true
            end
        end
    end
    for _, marker in pairs(self.hostMarkers) do
        if not used[marker] then
            marker:Hide()
        end
    end

    -- Panel.
    local preview = db.enabled and not db.locked and not active
    if not db.panel or not (active or preview) then
        frame:Hide()
        return
    end
    if preview then
        state = PREVIEW
    end
    local damage = math.floor(state.damage)
    if hasTarget then
        local life, lifeMax = UnitHealth("target"), UnitHealthMax("target")
        self.panelBar:SetMinMaxValues(0, lifeMax)
        self.panelBar:SetValue(life)
        self.panelMarker:Update("target", damage, life, lifeMax)
        self.healthText:SetText(AbbreviateNumbers(life))
    else
        self.panelBar:SetMinMaxValues(0, damage * 2)
        self.panelBar:SetValue(damage * 1.5)
        self.panelMarker:Hide()
        self.healthText:SetText("")
    end
    self.header:SetFormattedText(L.HEADER, Abbrev(state.dps), Abbrev(damage))

    local detail = db.mode == "classic"
    local shownRows = detail and math.min(#state.list, MAX_ROWS) or 0
    for i, row in ipairs(self.rows) do
        local dot = i <= shownRows and state.list[i]
        if dot then
            row.icon:SetTexture(dot.icon or 134400) -- interrogación si no hay icono
            row.name:SetText(dot.name)
            local color = PHASE_COLOR[dot.phase] or PHASE_COLOR.ok
            row.name:SetTextColor(color[1], color[2], color[3])
            row.info:SetTextColor(color[1], color[2], color[3])
            row.info:SetFormattedText(L.ROW, dot.seconds, Abbrev(dot.dps))
        end
        row.icon:SetShown(dot and true or false)
        row.name:SetShown(dot and true or false)
        row.info:SetShown(dot and true or false)
    end
    frame:SetHeight(30 + shownRows * ROW + 2)
    frame:Show()
end

function module:ApplySettings()
    if not self.frame then
        return
    end
    local db = ns.db
    local position = db.frame
    self.frame:ClearAllPoints()
    self.frame:SetPoint(position.point, UIParent, position.relativePoint, position.x, position.y)
    self.frame:SetScale(db.scale)
    self.alert:SetScale(db.scale)
    self.buttonMap = nil
    Dots.LEAD = db.renewLead
    self.frame:EnableMouse(not db.locked)
    Dots.Rebuild()
    self:Update()
end
