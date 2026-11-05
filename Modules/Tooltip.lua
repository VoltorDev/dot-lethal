local _, ns = ...
local L = ns.L
local module = ns:NewModule("Tooltip")

-- Daño por segundo de los DoTs en la descripción del hechizo (libro, barras de acción, enlaces).
-- Sale de lo mismo que usa el seguimiento (Dots.lua): la definición del DoT y la descripción del
-- hechizo, que ya trae el poder con hechizos y los talentos. Solo hechizos que el addon conoce como
-- DoT: así un «aturde durante 4 s» no se confunde con daño en el tiempo.
local Tooltip = {}
ns.Tooltip = Tooltip

-- "12,5" en español, "12.5" en inglés; desde 100, sin decimales y con separador de miles.
function Tooltip.FormatNumber(value)
    if value >= 100 then
        local rounded = math.floor(value + 0.5)
        return BreakUpLargeNumbers and BreakUpLargeNumbers(rounded) or tostring(rounded)
    end
    local text = ("%.1f"):format(value):gsub("%.0$", "")
    return (text:gsub("%.", L.DECIMAL_SEPARATOR))
end

-- Daño total, duración y daño por segundo del DoT de un hechizo, o nil si no es un DoT conocido
-- o su descripción no se entiende (aún sin cargar, o secreta).
function Tooltip.DotInfo(spellID)
    if type(spellID) ~= "number" or issecretvalue(spellID) then
        return nil
    end
    local def = ns.Dots.Definition(spellID)
    if not def then
        return nil
    end
    -- La del hechizo y, si no se entiende, la del aura que pone (Fuego lunar -> su DoT), como en Dots.OnCast.
    for _, id in ipairs({ spellID, def.aura }) do
        local text = C_Spell.GetSpellDescription(id)
        if type(text) == "string" and not issecretvalue(text) then
            local total, duration = ns.Dots.ParseDescription(text, def.mode, def.period)
            if total and total > 0 and duration and duration > 0 then
                return total, duration, total / duration
            end
        end
    end
    return nil
end

-- Línea lista para el tooltip, o nil.
function Tooltip.Line(spellID)
    local total, duration, dps = Tooltip.DotInfo(spellID)
    if not dps then
        return nil
    end
    return L.TOOLTIP_DOT_DPS:format(
        Tooltip.FormatNumber(dps),
        Tooltip.FormatNumber(total),
        Tooltip.FormatNumber(duration)
    )
end

local function OnSpellTooltip(tooltip, data)
    if not ns.db or not ns.db.tooltipDps or not data then
        return
    end
    local line = Tooltip.Line(data.id)
    if line then
        tooltip:AddLine(line, 1, 0.82, 0, true)
    end
end

function module:OnEnable()
    if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum.TooltipDataType then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, OnSpellTooltip)
    end
end

Tooltip.OnSpellTooltip = OnSpellTooltip
