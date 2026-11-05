-- Modules/Tooltip.lua: daño por segundo del DoT en la descripción del hechizo.
local WowEnv = require("wow_env")

local TOC = "DoTLetal.toc"
local RETAIL_BUILD = { "12.1.5", "99999", "Oct 1 2026", 120105 }

local SPELLS = {
    [172] = { "Corruption", "Corrupts the target, causing 822 Shadow damage over 18 sec." },
    [348] = { "Immolate", "Burns the enemy for 11 Fire damage and then an additional 20 Fire damage over 15 sec." },
    [18265] = { "Siphon Life", "Transfers 15 health every 3 sec from the target to the caster for 30 sec." },
    [686] = { "Shadow Bolt", "Sends a shadowy bolt at the enemy, causing 13 to 18 Shadow damage." },
}

local function boot(opts)
    opts = opts or {}
    opts.spells = opts.spells or SPELLS
    return WowEnv.boot(TOC, opts)
end

describe("DPS del DoT en el tooltip", function()
    it("DoT puro: total entre duración", function()
        local _, ns = boot()
        assert.are.same({ 822, 18, 822 / 18 }, { ns.Tooltip.DotInfo(172) })
        assert.are.equal("Damage per second: 45.7 (822 over 18 sec)", ns.Tooltip.Line(172))
    end)

    it("golpe directo más DoT: solo cuenta la parte en el tiempo", function()
        local _, ns = boot()
        assert.are.equal("Damage per second: 1.3 (20 over 15 sec)", ns.Tooltip.Line(348))
    end)

    it("daño por tick (Succionar vida): ticks por la duración", function()
        local _, ns = boot()
        assert.are.equal("Damage per second: 5 (150 over 30 sec)", ns.Tooltip.Line(18265))
    end)

    it("un hechizo que no es DoT no lleva línea", function()
        local _, ns = boot()
        assert.is_nil(ns.Tooltip.Line(686))
        assert.is_nil(ns.Tooltip.Line(999999))
    end)

    it("en español usa coma decimal y separador de miles", function()
        local _, ns = boot({
            client = "retail",
            build = RETAIL_BUILD,
            locale = "esES",
            spells = {
                [172] = {
                    "Corrupción",
                    "Corrompe al objetivo y le inflige 1.400 p. de daño de Sombras durante 14 s.",
                },
            },
        })
        local line = ns.Tooltip.Line(172)
        assert(line:find("^Daño por segundo: 100 %(1[%.,]?400 en 14 s%)$"), line)
        assert.are.equal("12,5", ns.Tooltip.FormatNumber(12.5))
    end)

    it("añade la línea al tooltip solo con la opción activada", function()
        local _, ns = boot()
        local lines = {}
        local tooltip = {
            AddLine = function(_, text)
                lines[#lines + 1] = text
            end,
        }
        ns.Tooltip.OnSpellTooltip(tooltip, { id = 172 })
        assert.are.equal(1, #lines)
        ns.db.tooltipDps = false
        ns.Tooltip.OnSpellTooltip(tooltip, { id = 172 })
        assert.are.equal(1, #lines)
    end)
end)
