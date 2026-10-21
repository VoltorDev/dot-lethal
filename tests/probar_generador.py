"""Prueba de tools/generar_datos.py con tablas pequeñas inventadas (sin red).
Uso: python tests/probar_generador.py"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "tools"))
import generar_datos as g  # noqa: E402


def efecto(spell, aura="0", periodo="0", objetivo="6", dispara="0", op="0", pct="0", mascara=(0, 0, 0, 0)):
    fila = {"SpellID": str(spell), "DifficultyID": "0", "EffectAura": aura, "EffectAuraPeriod": periodo,
            "ImplicitTarget_0": objetivo, "EffectTriggerSpell": dispara, "EffectMiscValue_0": op,
            "EffectBasePointsF": pct}
    for i, m in enumerate(mascara):
        fila[f"EffectSpellClassMask_{i}"] = str(m)
    return fila


def misc(spell, a0=0, a1=0, a5=0, duracion="1"):
    fila = {"SpellID": str(spell), "DifficultyID": "0", "DurationIndex": duracion}
    for i in range(17):
        fila[f"Attributes_{i}"] = "0"
    fila["Attributes_0"], fila["Attributes_1"], fila["Attributes_5"] = str(a0), str(a1), str(a5)
    return fila


def clase(spell, familia, m0):
    return {"SpellID": str(spell), "SpellClassSet": str(familia), "SpellClassMask_0": str(m0),
            "SpellClassMask_1": "0", "SpellClassMask_2": "0", "SpellClassMask_3": "0"}


NOMBRES = {1: "Corrupción", 2: "Fuego lunar", 3: "Aura de Fuego lunar", 4: "Pasivo con daño", 5: "Tortura mental",
           6: "Vapulear", 7: "Vapulear", 8: "Muerte reptante", 9: "Bola de fuego", 10: "Vapulear"}
t = {
    "SpellName": [{"ID": str(k), "Name_lang": v} for k, v in NOMBRES.items()],
    "SkillLine": [{"ID": "100", "CategoryID": "7"}, {"ID": "200", "CategoryID": "11"}],
    "SkillLineAbility": [{"SkillLine": "100", "Spell": str(s)} for s in (1, 2, 4, 5, 6, 9)]
    + [{"SkillLine": "200", "Spell": "10"}],
    "TraitDefinition": [{"SpellID": "8", "OverridesSpellID": "0", "VisibleSpellID": "0"}],
    "Talent": [],
    "SpecializationSpells": [],
    "SpellDuration": [{"ID": "1", "Duration": "18000"}],
    "SpellMisc": [misc(1, a5=0x2000), misc(2), misc(3), misc(4, a0=0x40), misc(5, a1=0x4), misc(6), misc(7),
                  misc(8, a0=0x40), misc(9)],
    "SpellClassOptions": [clase(1, 5, 2), clase(6, 7, 64), clase(7, 7, 64), clase(8, 5, 0)],
    "SpellEffect": [
        efecto(1, aura="3", periodo="2000"),  # Corrupción: DoT
        efecto(2, dispara="3"),  # Fuego lunar dispara su aura
        efecto(3, aura="3", periodo="2000"),
        efecto(4, aura="3", periodo="1000"),  # pasivo: fuera
        efecto(5, aura="3", periodo="1000"),  # canalizado: fuera
        efecto(7, aura="3", periodo="3000"),  # sangrado de Vapulear, sin enlace: por nombre y familia
        efecto(8, aura="108", op="19", pct="-10", mascara=(2, 0, 0, 0)),  # Muerte reptante
        efecto(9, aura="3", periodo="1000", objetivo="1"),  # a uno mismo: fuera
    ],
}
dots, ritmos = g.generar(t)
fallos = []
esperado = {1, 2, 6}
if set(dots) != esperado:
    fallos.append(f"DoTs {sorted(dots)} y se esperaba {sorted(esperado)}")
else:
    if not (dots[1]["prisa"] and dots[1]["periodo"] == 2 and dots[1]["duracion"] == 18 and dots[1]["familia"] == 5):
        fallos.append(f"Corrupción: {dots[1]}")
    if dots[2]["aura"] != 3 or dots[2]["prisa"]:
        fallos.append(f"Fuego lunar debería tomar el aura que dispara, sin celeridad: {dots[2]}")
    if dots[6]["aura"] != 7 or dots[6]["periodo"] != 3:
        fallos.append(f"Vapulear debería enlazarse por nombre y familia con su sangrado: {dots[6]}")
if len(ritmos) != 1 or ritmos[0]["talento"] != 8 or ritmos[0]["pct"] != -10 or ritmos[0]["familia"] != 5:
    fallos.append(f"talentos de ritmo: {ritmos}")
lua = g.a_lua("Retail", "0", dots, ritmos)
if "ns.DATOS.Retail = {" not in lua or "[1] = { aura = 1, periodo = 2, prisa = true" not in lua:
    fallos.append("el Lua generado no tiene la forma esperada")
if fallos:
    sys.exit("FALLA:\n  " + "\n  ".join(fallos))
print("OK: DoT, aura disparada, enlace por nombre, fuera pasivos, canalizados y a uno mismo; talento de ritmo")
