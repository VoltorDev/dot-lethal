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
    frame:SetScript("OnEvent", function(_, event, ...)
        module:OnEvent(event, ...)
    end)

    self.frame, self.header, self.healthText, self.rows = frame, header, healthText, rows
    self.panelBar = health
    self.panelMarker = Marker.New(health, 14)
    self.hostMarkers = {} -- barra anfitriona -> Marker (las placas se reciclan: una por barra)
    self:MarkerFor(TargetFrameBar()) -- fuera de combate: el marco de objetivo es de Blizzard
    Dots.Rebuild(ns.db.custom)
    Dots.OnTargetChanged()
    self:ApplySettings()
end

function module:OnEvent(event, ...)
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
local PREVIEW = { damage = 1000, dps = 125, list = { { name = "DoT", damage = 1000, seconds = 8, dps = 125 } } }

function module:Update()
    local frame = self.frame
    if not frame then
        return
    end
    local db = ns.db
    local hasTarget = UnitExists("target")
    if hasTarget and UnitIsDeadOrGhost("target") then
        Dots.OnTargetChanged() -- muerto: sus DoTs ya no cuentan
        hasTarget = false
    end
    local state = Dots.TargetState(GetTime())
    if state.damage <= 0 then
        self:StopTicker()
    end
    local active = db.enabled and hasTarget and state.damage > 0

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
    self.frame:EnableMouse(not db.locked)
    Dots.Rebuild(db.custom)
    self:Update()
end
