"""Genera Datos/Retail.lua y Datos/Forever.lua: todos los DoTs que puede tener un jugador y los talentos que
cambian su ritmo de ticks, sacados de las tablas del cliente (DB2) que publica wago.tools.

Uso: python tools/generar_datos.py [carpeta de caché]

Qué es un DoT aquí (por hechizo que el jugador aprende: habilidades de clase de SkillLineAbility, hechizos de
especialización de SpecializationSpells, talentos de TraitDefinition en retail y de Talent en Forever, y los que
estos sustituyen):
  - tiene, él, el hechizo que dispara o uno de su misma familia de clase y con su mismo nombre (Vapulear pone su
    sangrado por script, sin enlace en las tablas), un efecto de aura de daño periódico (aura 3 PERIODIC_DAMAGE o 53
    PERIODIC_LEECH) con periodo (EffectAuraPeriod) y que no va al propio lanzador (ImplicitTarget 1);
  - no es pasivo (SPELL_ATTR0_PASSIVE, 0x40) ni canalizado (SPELL_ATTR1_IS_CHANNELLED 0x4 o 0x40): un canalizado
    deja de hacer daño al cortarlo y el addon no puede saber cuándo.
Por cada uno: periodo base en segundos, si la celeridad acelera los ticks (SPELL_ATTR5_SPELL_HASTE_AFFECTS_PERIODIC,
0x2000), duración base (SpellMisc.DurationIndex -> SpellDuration) y la familia y máscara de clase del aura
(SpellClassOptions), con las que el juego decide a qué hechizos afecta cada talento.

Talentos que cambian el ritmo: hechizos pasivos aprendibles con un efecto ADD_PCT_MODIFIER (aura 108) y operación
19 (Period). Se comprobó con Creeping Death (-10 %), Rapid Contagion (-31 %) y Sataiel's Volition (-25 %), que
apuntan a Corrupción. El daño y la duración no hacen falta: la descripción del hechizo ya los da con los talentos
y el poder con hechizos del jugador (Dots.ParseDescription).
"""
import csv
import io
import os
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
BUILDS = {"Retail": "12.1.5.70448", "Forever": "1.60.1.70245"}
TABLAS = ["SpellEffect", "SpellName", "SkillLineAbility", "SkillLine", "TraitDefinition", "Talent",
          "SpecializationSpells", "SpellClassOptions", "SpellMisc", "SpellDuration"]
URL = "https://wago.tools/db2/{tabla}/csv?build={build}"
UA = {"User-Agent": "DoTLetal-generar-datos/1.0"}

AURAS_DOT = {"3", "53"}  # PERIODIC_DAMAGE, PERIODIC_LEECH
AURA_PCT_MOD = "108"  # ADD_PCT_MODIFIER
OP_PERIODO = "19"  # SpellModOp Period
CATEGORIA_CLASE = "7"  # SkillLine.CategoryID de las habilidades de clase
ATTR0_PASIVO = 0x40
ATTR1_CANALIZADO = 0x4 | 0x40
ATTR5_PRISA_PERIODICO = 0x2000
OBJETIVO_LANZADOR = "1"


def bajar(cache, tabla, build):
    ruta = Path(cache) / f"{tabla}_{build}.csv"
    if not ruta.exists() or ruta.stat().st_size == 0:
        req = urllib.request.Request(URL.format(tabla=tabla, build=build), headers=UA)
        try:
            with urllib.request.urlopen(req, timeout=300) as r:
                ruta.write_bytes(r.read())
        except urllib.error.HTTPError as e:
            if e.code != 400:
                raise
            print(f"  {tabla} no existe en {build}: se toma vacía")
            return []
    with open(ruta, encoding="utf-8", newline="") as f:
        return list(csv.DictReader(f))


def entero(valor):
    try:
        return int(float(valor))
    except (TypeError, ValueError):
        return 0


def aprendibles(t):
    """Hechizos que el jugador puede aprender (habilidades de clase y talentos) y los que sustituyen."""
    clases = {f["ID"] for f in t["SkillLine"] if f["CategoryID"] == CATEGORIA_CLASE}
    ids = {entero(f["Spell"]) for f in t["SkillLineAbility"] if f["SkillLine"] in clases}
    for f in t["SpecializationSpells"]:
        for campo in ("SpellID", "OverridesSpellID"):
            ids.add(entero(f.get(campo)))
    for f in t["TraitDefinition"]:
        for campo in ("SpellID", "OverridesSpellID", "VisibleSpellID"):
            ids.add(entero(f.get(campo)))
    for f in t["Talent"]:
        for campo in [c for c in f if c.startswith("SpellRank_")] + ["SpellID", "OverridesSpellID"]:
            ids.add(entero(f.get(campo)))
    ids.discard(0)
    return ids


def generar(t):
    nombres = {entero(f["ID"]): f["Name_lang"] for f in t["SpellName"]}
    misc = {}
    for f in t["SpellMisc"]:
        if f.get("DifficultyID", "0") == "0":
            misc[entero(f["SpellID"])] = f
    duraciones = {f["ID"]: entero(f["Duration"]) for f in t["SpellDuration"]}
    clase = {entero(f["SpellID"]): f for f in t["SpellClassOptions"]}
    efectos = {}
    for f in t["SpellEffect"]:
        if f.get("DifficultyID", "0") == "0":
            efectos.setdefault(entero(f["SpellID"]), []).append(f)

    def attr(spell, n):
        return entero(misc.get(spell, {}).get(f"Attributes_{n}"))

    def periodico(spell):
        for e in efectos.get(spell, []):
            if (e["EffectAura"] in AURAS_DOT and entero(e["EffectAuraPeriod"]) > 0
                    and e["ImplicitTarget_0"] != OBJETIVO_LANZADOR):
                return e
        return None

    def mascara(spell):
        f = clase.get(spell)
        if not f:
            return 0, [0, 0, 0, 0]
        return entero(f["SpellClassSet"]), [entero(f[f"SpellClassMask_{i}"]) for i in range(4)]

    aprende = aprendibles(t)
    # Auras periódicas por (nombre, familia) para el enlace por nombre; gana el ID más alto (el más reciente).
    por_nombre = {}
    for spell in sorted(efectos):
        if periodico(spell) and spell in nombres and not attr(spell, 1) & ATTR1_CANALIZADO:
            familia = mascara(spell)[0]
            if familia:
                por_nombre[(nombres[spell], familia)] = spell
    dots = {}
    for spell in sorted(aprende):
        if spell not in nombres or attr(spell, 0) & ATTR0_PASIVO or attr(spell, 1) & ATTR1_CANALIZADO:
            continue
        aura, efecto = spell, periodico(spell)
        if not efecto:  # el DoT lo pone otro hechizo que este dispara (Fuego lunar -> 164812)
            for e in efectos.get(spell, []):
                hijo = entero(e["EffectTriggerSpell"])
                if hijo and hijo != spell and periodico(hijo) and not attr(hijo, 1) & ATTR1_CANALIZADO:
                    aura, efecto = hijo, periodico(hijo)
                    break
        if not efecto:
            hermano = por_nombre.get((nombres[spell], mascara(spell)[0]))
            if hermano and mascara(spell)[0]:
                aura, efecto = hermano, periodico(hermano)
        if not efecto:
            continue
        familia, masc = mascara(aura)
        duracion = duraciones.get(misc.get(aura, {}).get("DurationIndex"), 0)
        dots[spell] = {
            "nombre": nombres[spell],
            "aura": aura,
            "periodo": entero(efecto["EffectAuraPeriod"]) / 1000,
            "prisa": bool(attr(aura, 5) & ATTR5_PRISA_PERIODICO),
            "duracion": duracion / 1000 if duracion > 0 else 0,
            "familia": familia,
            "mascara": masc,
        }

    ritmos = []
    for spell in sorted(aprende):
        if not attr(spell, 0) & ATTR0_PASIVO:
            continue
        familia = mascara(spell)[0]
        for e in efectos.get(spell, []):
            if e["EffectAura"] == AURA_PCT_MOD and e["EffectMiscValue_0"] == OP_PERIODO:
                pct = entero(e["EffectBasePointsF"])
                masc = [entero(e[f"EffectSpellClassMask_{i}"]) for i in range(4)]
                if pct and any(masc):
                    ritmos.append({"talento": spell, "nombre": nombres.get(spell, "?"), "pct": pct,
                                   "familia": familia, "mascara": masc})
    return dots, ritmos


def a_lua(nombre, build, dots, ritmos):
    lineas = [
        "-- Generado por tools/generar_datos.py con las tablas del cliente (wago.tools, build "
        f"{build}, {time.strftime('%d-%m-%Y')}). No editar a mano.",
        "local _, ns = ...",
        "ns.DATOS = ns.DATOS or {}",
        "-- [spellID que se lanza] = { aura, periodo (s), prisa, duración base (s), familia, máscara de clase }",
        f"ns.DATOS.{nombre} = {{",
        "    dots = {",
    ]
    for spell, d in sorted(dots.items()):
        lineas.append(
            f"        [{spell}] = {{ aura = {d['aura']}, periodo = {d['periodo']:g}, prisa = "
            f"{'true' if d['prisa'] else 'false'}, duracion = {d['duracion']:g}, familia = {d['familia']}, "
            f"mascara = {{ {', '.join(str(m) for m in d['mascara'])} }} }}, -- {d['nombre']}"
        )
    lineas += ["    },", "    -- Talentos pasivos que cambian el ritmo de ticks (operación 19, Period): pct sobre el periodo.",
               "    ritmos = {"]
    for r in ritmos:
        lineas.append(
            f"        {{ talento = {r['talento']}, pct = {r['pct']}, familia = {r['familia']}, "
            f"mascara = {{ {', '.join(str(m) for m in r['mascara'])} }} }}, -- {r['nombre']}"
        )
    lineas += ["    },", "}", ""]
    return "\n".join(lineas)


def main():
    cache = Path(sys.argv[1] if len(sys.argv) > 1 else os.environ.get("LOCALAPPDATA", ".")) / "DoTLetal-db2"
    cache.mkdir(parents=True, exist_ok=True)
    (RAIZ / "Datos").mkdir(exist_ok=True)
    for nombre, build in BUILDS.items():
        t = {tabla: bajar(cache, tabla, build) for tabla in TABLAS}
        dots, ritmos = generar(t)
        (RAIZ / "Datos" / f"{nombre}.lua").write_text(a_lua(nombre, build, dots, ritmos), encoding="utf-8",
                                                    newline="\n")
        print(f"{nombre} ({build}): {len(dots)} DoTs, {len(ritmos)} talentos de ritmo")


if __name__ == "__main__":
    main()
