local addonName, ns = ...
local L = ns.L
local Dots = ns.Dots
local module = ns:NewModule("Indicator")

-- Indicador: ¿matan al objetivo los DoTs que le quedan?
--
-- La vida del objetivo es SIEMPRE secreta: no se puede comparar con el daño de los DoTs. La
-- comparación la hace una barra de estado, que acepta el secreto en SetValue y lo recorta a su
-- rango: con SetMinMaxValues(R, R + 1) y SetValue(vida), la barra está vacía si vida <= R (los
-- DoTs la matan) y llena si vida >= R + 1. Debajo de la barra hay un cuadro verde con el visto
-- bueno; si la barra se llena, lo tapa de rojo. El addon nunca sabe cuál de los dos se ve: solo
-- lo ve el jugador. Ver secretos-y-restricciones.md de la skill wow-addons.
local TICK = 0.2 -- segundos entre actualizaciones mientras quedan DoTs (los ticks cambian R)
local SIZE = 28
local BAR_WIDTH = 120

local function SolidBar(parent, r, g, b, a)
    local bar = CreateFrame("StatusBar", nil, parent)
    bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
    bar:SetStatusBarColor(r, g, b, a)
    return bar
end

function module:OnEnable()
    local frame = CreateFrame("Frame", addonName .. "Frame", UIParent)
    frame:SetSize(SIZE + 6 + BAR_WIDTH, SIZE)
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

    -- Veredicto. Capa inferior: verde con visto bueno (muere).
    local verdict = CreateFrame("Frame", nil, frame)
    verdict:SetSize(SIZE, SIZE)
    verdict:SetPoint("LEFT")
    local yes = verdict:CreateTexture(nil, "BACKGROUND")
    yes:SetAllPoints()
    yes:SetColorTexture(0.05, 0.45, 0.1, 0.9)
    local check = verdict:CreateTexture(nil, "ARTWORK")
    check:SetPoint("CENTER")
    check:SetSize(SIZE - 6, SIZE - 6)
    check:SetAtlas("common-icon-checkmark")

    -- Capa superior: barra roja opaca, llena (lo tapa todo) cuando el objetivo sobrevive. No lleva
    -- icono: la barra recorta su textura de relleno y estropearía las coordenadas de un atlas.
    local cover = SolidBar(verdict, 0.6, 0.08, 0.08, 1)
    cover:SetAllPoints()
    cover:SetFrameLevel(verdict:GetFrameLevel() + 1)

    -- Detalle: vida del objetivo (gris) y, encima, el daño de los DoTs en la misma escala (verde).
    -- Si lo verde pasa del final de lo gris, los DoTs lo matan.
    local health = SolidBar(frame, 0.35, 0.35, 0.35, 1)
    health:SetSize(BAR_WIDTH, 10)
    health:SetPoint("TOPLEFT", verdict, "TOPRIGHT", 6, 0)
    local healthBg = health:CreateTexture(nil, "BACKGROUND")
    healthBg:SetAllPoints()
    healthBg:SetColorTexture(0, 0, 0, 0.6)
    local damage = SolidBar(frame, 0.2, 0.9, 0.2, 0.55)
    damage:SetAllPoints(health)
    damage:SetFrameLevel(health:GetFrameLevel() + 1)

    local dotText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    dotText:SetPoint("BOTTOMLEFT", verdict, "BOTTOMRIGHT", 6, 0)
    local healthText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    healthText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

    frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
    frame:RegisterUnitEvent("UNIT_HEALTH", "target")
    frame:RegisterUnitEvent("UNIT_MAXHEALTH", "target")
    frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:SetScript("OnEvent", function(_, event, ...)
        module:OnEvent(event, ...)
    end)

    self.frame, self.cover = frame, cover
    self.health, self.damage = health, damage
    self.dotText, self.healthText = dotText, healthText
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

-- Daño que se pinta: el real o, con el marco desbloqueado para moverlo, uno de muestra.
local PREVIEW = 1000

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
    local remaining, seconds = Dots.TargetRemaining(GetTime())
    if remaining <= 0 then
        self:StopTicker()
    end
    local preview = not db.locked
    if not db.enabled or (not preview and (remaining <= 0 or not hasTarget)) then
        frame:Hide()
        return
    end
    local shown = remaining > 0 and math.floor(remaining) or PREVIEW
    -- El objetivo muere si vida <= shown. La vida solo se entrega a las barras y al texto.
    local life, lifeMax = PREVIEW + 1, PREVIEW * 2
    if hasTarget then
        life, lifeMax = UnitHealth("target"), UnitHealthMax("target")
    end
    self.cover:SetMinMaxValues(shown, shown + 1)
    self.cover:SetValue(life)
    self.health:SetMinMaxValues(0, lifeMax)
    self.health:SetValue(life)
    self.damage:SetMinMaxValues(0, lifeMax)
    self.damage:SetValue(shown)
    local detail = db.mode == "classic"
    self.dotText:SetShown(detail)
    self.healthText:SetShown(detail)
    if detail then
        self.dotText:SetFormattedText(L.DOTS_LEFT, AbbreviateNumbers(shown), seconds)
        self.healthText:SetText(AbbreviateNumbers(life))
    end
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
