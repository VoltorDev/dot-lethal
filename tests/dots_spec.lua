-- Dots.lua: lectura de la descripción del hechizo, reparto del daño en ticks, celeridad, pandemia y
-- seguimiento por objetivo. Todo con números normales: la vida secreta no entra aquí.
local WowEnv = require("wow_env")

local TOC = "DoTLetal.toc"
local RETAIL_BUILD = { "12.1.5", "99999", "Oct 1 2026", 120105 }

-- Descripciones con la forma de las del juego; las reales se comprueban en el cliente.
local SPELLS = {
    [172] = { "Corruption", "Corrupts the target, causing 822 Shadow damage over 18 sec." },
    [348] = { "Immolate", "Burns the enemy for 11 Fire damage and then an additional 20 Fire damage over 15 sec." },
    [980] = { "Curse of Agony", "Curses the target with agony, causing 1,200 Shadow damage over 24 sec." },
    [18265] = { "Siphon Life", "Transfers 15 health every 3 sec from the target to the caster for 30 sec." },
    [686] = { "Shadow Bolt", "Sends a shadowy bolt at the enemy, causing 13 to 18 Shadow damage." },
}
local RETAIL_SPELLS = {
    [172] = { "Corrupción", "Corrompe al objetivo y le inflige 1.400 p. de daño de Sombras durante 14 s." },
    [980] = { "Agonía", "Inflige agonía al objetivo y le causa hasta 1.800 p. de daño de Sombras durante 18 s." },
}

local function boot(opts)
    opts = opts or {}
    opts.spells = opts.spells or SPELLS
    opts.target = opts.target or { exists = true, attackable = true }
    return WowEnv.boot(TOC, opts)
end

local function bootRetail(opts)
    opts = opts or {}
    opts.client, opts.build, opts.locale = "retail", RETAIL_BUILD, "esES"
    opts.spells = opts.spells or RETAIL_SPELLS
    return boot(opts)
end

local function remaining(env, ns)
    return ns.Dots.TargetState(env.GetTime()).damage
end

describe("Dots.ParseDescription", function()
    local Dots

    setup(function()
        local _, ns = boot()
        Dots = ns.Dots
    end)

    it("DoT puro: el número antes de la duración", function()
        assert.are.same({ 822, 18 }, { Dots.ParseDescription(SPELLS[172][2]) })
    end)

    it("golpe directo más DoT: se queda con la parte del DoT", function()
        assert.are.same({ 20, 15 }, { Dots.ParseDescription(SPELLS[348][2]) })
    end)

    it("separadores de miles en inglés y en español", function()
        assert.are.same({ 1200, 24 }, { Dots.ParseDescription(SPELLS[980][2]) })
        assert.are.same({ 1400, 14 }, { Dots.ParseDescription(RETAIL_SPELLS[172][2]) })
    end)

    it("español con golpe directo y espacio duro antes de la unidad", function()
        local es = "Quema al enemigo y le inflige 11 p. de daño de Fuego y otros 20 p. de daño durante 15\194\160s."
        assert.are.same({ 20, 15 }, { Dots.ParseDescription(es) })
    end)

    it("modo tick: daño por tick por número de ticks", function()
        assert.are.same({ 150, 30 }, { Dots.ParseDescription(SPELLS[18265][2], "tick", 3) })
    end)

    it("sin duración (no es un DoT) o sin texto: nada", function()
        assert.is_nil(Dots.ParseDescription(SPELLS[686][2]))
        assert.is_nil(Dots.ParseDescription(""))
        assert.is_nil(Dots.ParseDescription(nil))
    end)
end)

-- Textos reales de retail en español (Wowhead, 20-10-2026, 12.1.5) con números en lugar de las
-- fórmulas de poder con hechizos, como los da GetSpellDescription en el cliente.
describe("descripciones reales de retail en español", function()
    local Dots

    setup(function()
        local _, ns = boot()
        Dots = ns.Dots
    end)

    local cases = {
        {
            "Corrupción",
            "Corrompe al objetivo, que recibe 1.200 p. de daño de las Sombras y 7.900 p. más de daño de las Sombras"
                .. " durante 14 s.",
            { 7900, 14 },
        },
        {
            "Inmolar",
            "Quema al enemigo, lo que inflige 2.800 p. de daño de Fuego inmediatamente y 10.500 p. de daño de Fuego"
                .. " extras durante 18 s. El daño periódico genera 1 trozo de fragmento de alma.",
            { 10500, 18 },
        },
        {
            "Agonía",
            "Provoca una agonía creciente en el objetivo que inflige hasta 20.100 p. de daño de las Sombras durante"
                .. " 18 s. El daño empieza siendo bajo y aumenta progresivamente.",
            { 20100, 18 },
        },
        {
            "Toque vampírico",
            "Un toque de la oscuridad que inflige 49 p. de daño de las Sombras durante 21 s y te sana una cantidad de"
                .. " salud equivalente al 30% del daño infligido. Si Toque vampírico se disipa, el disipador huye"
                .. " horrorizado durante 3 s.",
            { 49, 21 },
        },
        {
            "Succionar vida",
            "Succiona la esencia vital del objetivo, lo que le inflige 25 p. de daño de las Sombras durante 15 s y te"
                .. " sana un 30% del daño infligido.",
            { 25, 15 },
        },
        {
            "Choque de llamas",
            "Abrasa al objetivo y le inflige 670 p. de daño Volcánico y 3.600 p. de daño Volcánico más a lo largo de"
                .. " 18 s.",
            { 3600, 18 },
        },
        {
            "un porcentaje justo antes de la duración no es el daño",
            "Inflige 500 p. de daño y reduce la velocidad de movimiento un 20% durante 12 s.",
            { 500, 12 },
        },
    }
    for _, case in ipairs(cases) do
        it(case[1], function()
            assert.are.same(case[3], { Dots.ParseDescription(case[2]) })
        end)
    end

    it("Putrefacción de alma: el daño del objetivo principal, no el de los secundarios ni el 4", function()
        local text = "Marchita la fuerza vital de tu objetivo actual y de hasta 4 objetivos adicionales cercanos, lo"
            .. " que provoca que el objetivo principal reciba 32 p. de daño de las Sombras y los objetivos"
            .. " secundarios, 16 p. de daño de las Sombras durante 8 s."
        assert.are.same({ 32, 8 }, { Dots.ParseDescription(text, "max") })
    end)
end)

describe("Dots.Remaining", function()
    local Dots

    setup(function()
        local _, ns = boot()
        Dots = ns.Dots
    end)

    local function entry(fields)
        local e = { start = 100, duration = 18, interval = 3, unit = 100, level = 0 }
        for k, v in pairs(fields or {}) do
            e[k] = v
        end
        return e
    end

    it("descuenta cada tick al caer, no antes; da segundos y daño por segundo", function()
        local e = entry()
        assert.are.same({ 600, 18, 100 / 3, 0 }, { Dots.Remaining(e, 100) })
        assert.are.same({ 600, 15.5, 100 / 3, 0 }, { Dots.Remaining(e, 102.5) })
        assert.are.same({ 500, 15, 100 / 3, 1 }, { Dots.Remaining(e, 103) })
        assert.are.equal(100, (Dots.Remaining(e, 117)))
        assert.are.equal(0, (Dots.Remaining(e, 118)))
    end)

    it("con celeridad el último tick es parcial", function()
        local e = entry({ duration = 14, interval = 2 / 1.25, unit = 200 }) -- 8,75 ticks
        local left = Dots.Remaining(e, 100)
        assert.is_true(math.abs(left - 200 * 8.75) < 1e-6)
        assert.is_true(math.abs(select(3, Dots.Remaining(e, 100)) - 125) < 1e-6)
    end)

    it("ticks con peso (Maldición de agonía de Classic): los últimos pesan más", function()
        local w = { 0.5, 0.5, 0.5, 0.5, 1, 1, 1, 1, 1.5, 1.5, 1.5, 1.5 }
        local e = entry({ start = 0, duration = 24, interval = 2, weights = w })
        assert.are.equal(1200, (Dots.Remaining(e, 0)))
        assert.are.equal(1000, (Dots.Remaining(e, 8)))
        assert.are.equal(600, (Dots.Remaining(e, 16)))
    end)
end)

describe("seguimiento por objetivo", function()
    it("apunta el DoT lanzado sobre un enemigo, suma varios y da su daño por segundo", function()
        local env, ns = boot()
        env:Cast(172)
        env:Cast(348)
        local state = ns.Dots.TargetState(env.GetTime())
        assert.are.equal(842, state.damage)
        assert.are.equal(2, #state.list)
        assert.are.equal("Immolate", state.list[1].name) -- el que antes acaba, primero
        assert.are.equal(15, state.list[1].seconds)
        assert.is_true(math.abs(state.dps - (822 / 18 + 20 / 15)) < 1e-6)
        assert.are.equal(136172, state.list[2].icon)
    end)

    it("ignora hechizos que no son DoTs, sin objetivo atacable o con el objetivo muerto", function()
        local env, ns = boot()
        env:Cast(686)
        assert.are.equal(0, remaining(env, ns))
        env:SetTarget({ exists = true, attackable = false })
        env:Cast(172)
        env:SetTarget({ exists = true, attackable = true, dead = true })
        env:Cast(172)
        env:SetTarget(nil)
        env:Cast(172)
        assert.are.equal(0, remaining(env, ns))
    end)

    it("en Forever reaplicar reinicia el DoT sin conservar tiempo", function()
        local env, ns = boot()
        env:Cast(172)
        env:Advance(9)
        env:Cast(172)
        local state = ns.Dots.TargetState(env.GetTime())
        assert.are.equal(822, state.damage)
        assert.are.equal(18, state.list[1].seconds)
    end)

    it("con GUID legible recuerda los DoTs de cada objetivo al volver a él", function()
        local env, ns = boot()
        env:SetTarget({ exists = true }, "Creature-0-1-1-1-1-A")
        env:Cast(172)
        env:SetTarget({ exists = true }, "Creature-0-1-1-1-1-B")
        assert.are.equal(0, remaining(env, ns))
        env:SetTarget({ exists = true }, "Creature-0-1-1-1-1-A")
        assert.are.equal(822, remaining(env, ns))
    end)

    it("con la identidad del PNJ secreta solo sigue el objetivo actual", function()
        local env, ns = boot()
        env:SetTarget({ exists = true }, "Creature-0-1-1-1-1-A", true)
        env:Cast(172)
        assert.are.equal(822, remaining(env, ns))
        env:SetTarget({ exists = true }, "Creature-0-1-1-1-1-A", true)
        assert.are.equal(0, remaining(env, ns))
    end)
end)

describe("reglas de retail", function()
    it("la lista solo enseña los DoTs que tiene el personaje, con los nombres del cliente", function()
        local _, ns = bootRetail({ known = { [172] = true } })
        local known = table.concat(ns.Dots.Known(), "\n")
        assert.is_truthy(known:find("Corrupción (2s)", 1, true))
        assert.is_nil(known:find("Agonía", 1, true))
    end)

    it("la celeridad acelera los ticks y suma daño", function()
        local env, ns = bootRetail({ haste = 25 })
        env:Cast(172)
        local state = ns.Dots.TargetState(env.GetTime())
        assert.is_true(math.abs(state.damage - 1400 * 1.25) < 1e-6)
        assert.is_true(math.abs(state.dps - 1400 / 14 * 1.25) < 1e-6)
    end)

    it("con la celeridad secreta en combate usa la última legible", function()
        local opts = { haste = 25 }
        local env, ns = bootRetail(opts)
        env:Cast(172) -- lee 25 %
        env:Advance(20)
        opts.secretHaste, opts.haste = true, 50
        env:Cast(172) -- secreta: sigue con 25 %
        assert.is_true(math.abs(remaining(env, ns) - 1400 * 1.25) < 1e-6)
    end)

    it("sin ninguna lectura legible no aplica celeridad", function()
        local env, ns = bootRetail({ haste = 25, secretHaste = true })
        env:Cast(172)
        assert.are.equal(1400, remaining(env, ns))
    end)

    it("pandemia: reaplicar conserva hasta el 30 % de la duración", function()
        local env, ns = bootRetail()
        env:Cast(172)
        env:Advance(4) -- quedan 10 s; el tope es 4,2 s
        env:Cast(172)
        local dot = ns.Dots.TargetState(env.GetTime()).list[1]
        assert.is_true(math.abs(dot.seconds - 18.2) < 1e-6)
        env:Advance(16) -- quedan 2,2 s
        env:Cast(172)
        dot = ns.Dots.TargetState(env.GetTime()).list[1]
        assert.is_true(math.abs(dot.seconds - 16.2) < 1e-6)
    end)

    it("pandemia: reaplicar no reinicia el reloj de los ticks; el último sale parcial", function()
        local env, ns = bootRetail()
        env:Cast(172) -- 1400 en 14 s, ticks de 200 cada 2 s
        env:Advance(4.5) -- han caído 2; el siguiente toca a los 6 s
        env:Cast(172) -- dura 14 + 4,2 = 18,2 s: acaba a los 22,7 s
        -- Ticks a los 6, 8, ..., 22 s (9) y uno parcial de 0,7 / 2 al acabar.
        assert.is_true(math.abs(remaining(env, ns) - 200 * 9.35) < 1e-6)
        env:Advance(1.4) -- 5,9 s: el tick de los 6 s aún no ha caído
        assert.is_true(math.abs(remaining(env, ns) - 200 * 9.35) < 1e-6)
        env:Advance(0.2) -- 6,1 s: ya ha caído, cuando tocaba y no 2 s después de reaplicar
        assert.is_true(math.abs(remaining(env, ns) - 200 * 8.35) < 1e-6)
        env:Advance(16) -- 22,1 s: solo queda el parcial
        assert.is_true(math.abs(remaining(env, ns) - 200 * 0.35) < 1e-6)
        env:Advance(0.7) -- 22,8 s: terminado
        assert.are.equal(0, remaining(env, ns))
    end)

    it("pandemia con más celeridad que al lanzar: el siguiente tick sigue en su hora", function()
        local opts = { haste = 0 }
        local env, ns = bootRetail(opts)
        env:Cast(172)
        env:Advance(4.5) -- siguiente tick a los 6 s
        opts.haste = 100 -- ticks cada 1 s desde ahora
        env:Cast(172)
        local before = remaining(env, ns)
        env:Advance(1.4) -- 5,9 s
        assert.is_true(math.abs(remaining(env, ns) - before) < 1e-6)
        env:Advance(0.2) -- 6,1 s
        assert.is_true(remaining(env, ns) < before)
    end)

    it("Agonía: «hasta» es con el escalón máximo; empieza en el 1", function()
        local env, ns = bootRetail()
        env:Cast(980)
        local state = ns.Dots.TargetState(env.GetTime())
        local unit = 1800 / (9 * 8) -- 9 ticks, x8
        assert.is_true(math.abs(state.list[1].dps - unit / 2) < 1e-6)
        assert.is_true(math.abs(state.damage - unit * (1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 8)) < 1e-6)
    end)

    it("Agonía sube de escalón por tick y reaplicarla lo conserva", function()
        local env, ns = bootRetail()
        env:Cast(980)
        local first = ns.Dots.TargetState(env.GetTime()).list[1].dps
        env:Advance(6.01) -- tres ticks
        local later = ns.Dots.TargetState(env.GetTime()).list[1].dps
        assert.is_true(later > first)
        env:Cast(980)
        local refreshed = ns.Dots.TargetState(env.GetTime()).list[1].dps
        assert.is_true(math.abs(refreshed - later) < 1e-6)
    end)
end)

-- Datos de todos los DoTs del juego (Datos/*.lua, generados de las tablas del cliente) y talentos detectados.
describe("datos del juego y talentos detectados", function()
    it("un DoT que no estaba en ninguna lista (Toque vampírico) se sigue sin añadir nada", function()
        local spells = {
            [34914] = {
                "Toque vampírico",
                "Un toque de la oscuridad que inflige 900 p. de daño de las Sombras durante 21 s.",
            },
        }
        local env, ns = bootRetail({ spells = spells })
        env:Cast(34914)
        local dot = ns.Dots.TargetState(env.GetTime()).list[1]
        assert.are.equal(900, dot.damage)
        assert.is_true(math.abs(dot.dps - 900 / 21) < 1e-6) -- periodo 3 s de las tablas
    end)

    it("otro ID con el mismo nombre (Fuego lunar lanzado y su DoT) se reconoce por el nombre", function()
        local text = "Un rápido haz de luz lunar quema al objetivo y le inflige 200 p. de daño Arcano más "
            .. "1.800 p. de daño Arcano adicional durante 18 s"
        local spells = { [999001] = { "Fuego lunar", text }, [164812] = { "Fuego lunar", text } }
        local env, ns = bootRetail({ spells = spells })
        env:Cast(999001)
        assert.are.equal(1800, remaining(env, ns))
    end)

    it("un talento de ritmo que tienes (Creeping Death, -10 %) acelera los ticks de Corrupción", function()
        local env, ns = bootRetail({ known = { [264000] = true } })
        assert.is_true(math.abs(ns.Dots.Definition(172).period - 1.8) < 1e-6)
        env:Cast(172)
        local dot = ns.Dots.TargetState(env.GetTime()).list[1]
        -- Mismos ticks en la duración de la descripción: mismo total, en menos tiempo por tick.
        assert.is_true(math.abs(dot.dps - (1400 / (14 / 1.8)) / 1.8) < 1e-6)
    end)

    it("al cambiar los talentos se recalcula el ritmo", function()
        local opts = { known = {} }
        local env, ns = bootRetail(opts)
        assert.are.equal(2, ns.Dots.Definition(172).period)
        opts.known[264000] = true
        env:Fire("TRAIT_CONFIG_UPDATED", 1)
        assert.is_true(math.abs(ns.Dots.Definition(172).period - 1.8) < 1e-6)
    end)

    it("un talento de otra familia de clase no cambia nada", function()
        local spells = { [589] = { "Palabra de las Sombras: dolor", "Inflige 900 p. de daño durante 16 s." } }
        local _, ns = bootRetail({ known = { [264000] = true }, spells = spells })
        assert.are.equal(2, ns.Dots.Definition(589).period) -- Palabra de las Sombras: dolor (sacerdote)
    end)

    it("en Forever la celeridad no acelera los DoTs (las tablas no los marcan)", function()
        local env, ns = boot({ haste = 25 })
        env:Cast(172)
        assert.are.equal(822, remaining(env, ns))
        assert.is_false(ns.Dots.Definition(172).haste)
    end)

    it("los casos especiales se aplican por nombre a todos los rangos", function()
        local _, ns = bootRetail()
        assert.are.equal(8, ns.Dots.Definition(980).ramp)
        local _, forever = boot({ spells = { [980] = SPELLS[980], [1014] = { "Curse of Agony", SPELLS[980][2] } } })
        assert.is_not_nil(forever.Dots.Definition(1014).weights)
    end)
end)
