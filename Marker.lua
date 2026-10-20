local _, ns = ...

-- Marca sobre una barra de vida ajena (marco de objetivo, placa) o propia (panel):
--   1. Pérdida: el trozo final de la vida actual que se llevarán los DoTs, en naranja.
--   2. Calavera: visible solo si los DoTs bastan para matarlo.
--
-- La vida es SIEMPRE secreta: aquí no se compara ni se resta. Se entrega a barras y curvas:
--   - Pérdida: una barra de relleno inverso anclada al final del relleno de la barra anfitriona,
--     con el mismo máximo y valor = daño de los DoTs. Es la técnica de la predicción de curación de
--     Blizzard (StatusBarOverlaySegment.lua). Un marco que recorta a sus hijos corta lo que sobre
--     por la izquierda si los DoTs hacen más daño que la vida que le queda.
--   - Calavera con vida máxima legible: curva escalonada sobre el porcentaje de vida
--     (UnitHealthPercent con curva), alfa 1 por debajo de (daño + 1) / máximo.
--   - Calavera con vida máxima secreta (PNJ en Forever): barra "compuerta" con rango
--     [daño, daño + 1] y valor = vida, que se recorta a vacía si vida <= daño. La calavera vive en
--     un marco que recorta y va del final del relleno de la compuerta a su borde derecho: ancho
--     completo con la compuerta vacía, cero con ella llena.
local Marker = {}
Marker.__index = Marker
ns.Marker = Marker

local WHITE = "Interface\\Buttons\\WHITE8X8"
local SKULL = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8"

local curve -- una sola curva para todas las marcas; se rehace en cada actualización

local function SkullCurve(threshold)
    if not curve then
        curve = C_CurveUtil.CreateColorCurve()
        curve:SetType(Enum.LuaCurveType.Step)
    end
    curve:ClearPoints()
    curve:AddPoint(0, CreateColor(1, 1, 1, 1))
    if threshold <= 1 then
        curve:AddPoint(threshold, CreateColor(1, 1, 1, 0))
    end
    return curve
end

-- host: StatusBar de la vida. size: lado de la calavera (por defecto, el alto de la barra + 8).
function Marker.New(host, size)
    local self = setmetatable({ host = host }, Marker)
    local clip = CreateFrame("Frame", nil, host)
    clip:SetAllPoints(host)
    clip:SetClipsChildren(true)
    clip:SetFrameLevel(host:GetFrameLevel() + 2)
    local loss = CreateFrame("StatusBar", nil, clip)
    loss:SetStatusBarTexture(WHITE)
    loss:SetStatusBarColor(1, 0.55, 0.1, 0.75)
    loss:SetReverseFill(true)
    local fill = host:GetStatusBarTexture()
    loss:SetPoint("TOPRIGHT", fill, "TOPRIGHT")
    loss:SetPoint("BOTTOMRIGHT", fill, "BOTTOMRIGHT")

    local side = size or math.max(16, (host:GetHeight() or 8) + 8)
    local anchor = CreateFrame("Frame", nil, host)
    anchor:SetSize(side, side)
    anchor:SetPoint("RIGHT", host, "LEFT", -2, 0)
    anchor:SetFrameLevel(host:GetFrameLevel() + 3)

    -- Calavera de la curva (vida máxima legible).
    local skull = anchor:CreateTexture(nil, "OVERLAY")
    skull:SetAllPoints()
    skull:SetTexture(SKULL)

    -- Compuerta (vida máxima secreta): relleno invisible y calavera dentro de un marco que recorta.
    local gate = CreateFrame("StatusBar", nil, anchor)
    gate:SetAllPoints()
    gate:SetStatusBarTexture(WHITE)
    gate:SetStatusBarColor(0, 0, 0, 0)
    local window = CreateFrame("Frame", nil, gate)
    window:SetClipsChildren(true)
    window:SetPoint("TOPLEFT", gate:GetStatusBarTexture(), "TOPRIGHT")
    window:SetPoint("BOTTOMRIGHT", gate, "BOTTOMRIGHT")
    local gated = window:CreateTexture(nil, "OVERLAY")
    gated:SetAllPoints(gate)
    gated:SetTexture(SKULL)

    self.clip, self.loss, self.anchor = clip, loss, anchor
    self.skull, self.gate, self.gated = skull, gate, gated
    self:Hide()
    return self
end

-- damage: daño que les queda a los DoTs (número normal). life, lifeMax: los de UnitHealth y
-- UnitHealthMax de `unit`, quizá secretos.
function Marker:Update(unit, damage, life, lifeMax)
    local width = self.host:GetWidth()
    if width and not issecretvalue(width) then
        self.loss:SetWidth(width)
    end
    self.loss:SetMinMaxValues(0, lifeMax)
    self.loss:SetValue(damage)
    self.clip:Show()

    if not issecretvalue(lifeMax) and lifeMax > 0 then
        self.gate:Hide()
        self.skull:Show()
        -- Con una curva de color, el resultado es un color (la anotación admite también un número).
        local color = UnitHealthPercent(unit, false, SkullCurve((damage + 1) / lifeMax)) --[[@as colorRGBA]]
        local _, _, _, alpha = color:GetRGBA()
        self.skull:SetAlpha(alpha)
    else
        self.skull:Hide()
        self.gate:Show()
        self.gate:SetMinMaxValues(damage, damage + 1)
        self.gate:SetValue(life)
    end
    self.anchor:Show()
end

function Marker:Hide()
    self.clip:Hide()
    self.anchor:Hide()
end
