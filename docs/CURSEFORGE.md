# Publicar DoTLetal en CurseForge — kit

Preparado el 03-11-2026. Paquete: `mods\wow\dist\DoTLetal-1.0.0.zip` (generado con
`python -I mods\herramientas\empaquetar-wow.py mods\wow\DoTLetal --version 1.0.0`; pasa
`comprobar-paquete.py --juego wow`: solo `.toc`, `.lua`, `LICENSE` y `CHANGELOG.md`, sin ejecutables).

**Estado honesto:** pasa las seis comprobaciones fuera del juego (146 tests, 03-11-2026). En el cliente solo se ha
visto la franja naranja en retail el 21-10-2026, con un fallo que se corrigió ese día y no se ha vuelto a mirar; la
calavera, la calibración y el menú están **sin ver en el cliente** ([PLAN.md](../PLAN.md)). Recomendación (juicio
propio): subirlo como **Beta**, no como Release, hasta verlo en Forever el 05-11.

**Subido el 04-11-2026 hacia las 07:00 (por Claude, con la sesión de Nico en el navegador de la app, por orden suya):** proyecto «DoT Lethal», n.º **1782801** (`https://authors.curseforge.com/#/projects/1782801`), estado «New» hasta que lo apruebe un moderador. Fichero «DoT Lethal 1.0.0», tipo Release (subido como Beta y pasado a Release a las 08:00 del mismo día, por orden de Nico: «que lo descargue quien quiera»), versiones Retail 12.1.5 y 12.1.0, Forever 1.60.1, publicación automática al aprobarse, changelog del kit. Licencia MIT, distribución a terceros permitida (WowUp y otros gestores), comentarios activados, avatar `docs/avatar-curseforge.png` (lo dibuja `mods/herramientas/avatares_curseforge.py`). Falta: capturas (solo en el juego) y verlo en el cliente.

## Campos del formulario

| Campo | Valor |
|---|---|
| Juego | World of Warcraft |
| Nombre del proyecto | **Decisión de Nico.** La norma de CurseForge pide nombre en inglés, sin juego, clases ni versiones. Propuesta: `DoT Lethal`. La carpeta del addon sigue siendo `DoTLetal` |
| Resumen | `Shows how much health your DoTs will still take from your target, and a skull when they are enough to kill it.` |
| Categoría principal | Combat (secundarias: Buffs & Debuffs, Unit Frames). Comprobar los nombres exactos en el formulario |
| Licencia | MIT (está en `LICENSE`) |
| Donaciones | Ko-fi, usuario `thevoltor` (General › Donation Method). Puesto el 05-11-2026; sale como botón «Donate» en la página, y además el botón «Buy me a coffee» bajo la introducción de la descripción (con `width`: CurseForge quita el estilo de altura y sin él sale a 580 px). Nunca dentro del addon: la política de Blizzard prohíbe pedir donaciones en la interfaz |
| Versiones de juego | Retail 12.1.x (Interface 120100/120105) y **Forever 1.60.1** (Interface 16001). Un solo zip vale para los dos |
| Tipo de fichero | Beta (ver arriba). Para que el proyecto salga en la app de CurseForge hace falta al menos un Release aprobado |
| Avatar | 400×400, sin imágenes con copyright (nada de iconos de Blizzard). **Falta** |
| Capturas | **Faltan**: marco de objetivo con la franja naranja, la calavera y el panel en modo Clásico y Compacto. Solo se pueden hacer en el juego |

## Descripción (pegar en el editor de CurseForge)

```markdown
**DoT Lethal** shows, while your damage-over-time spells are ticking, how much of your target's health they will
still take, and puts a skull next to the health bar when your DoTs alone are enough to finish it.

Works on **Retail (Midnight 12.1)** and **World of Warcraft: Forever**.

<p align="center"><a href="https://ko-fi.com/thevoltor"><img src="https://storage.ko-fi.com/cdn/kofi6.png?v=6" alt="Buy Me a Coffee at ko-fi.com" width="145" height="36"></a><br><em>Free and always will be. If it helps you, you can buy me a coffee.</em></p>

## Features

- **Orange chunk on the target's health bar** (target frame, nameplate and the addon panel): the health your DoTs
  will still remove.
- **Skull** to the left of that bar when your DoTs are enough to kill the target.
- **Panel** with the total damage per second of your DoTs and the damage they still have to do, plus one line per
  DoT with its seconds left and its damage per second. Classic (list) or Compact (totals only) mode.
- **Every DoT in the game is built in**, taken from the client's own tables (116 spells on Retail, 231 on Forever
  with all their ranks): tick period, haste scaling and the talents that change their rhythm, detected
  automatically when you change talents or spec. Nothing to add by hand.
- **Calibrates itself with your real damage**: after a single-target fight it compares each DoT's real damage in
  Blizzard's damage meter with its estimate and learns a factor per spell and character (crits, mastery and
  everything the tooltip does not say). Needs the damage meter enabled in the game options.
- **When to recast** each DoT, right on its action button: amber with a countdown (not yet), green **NOW!** (recast)
  and red **DROPPED** for 8 s if it falls off. DoTs that are not on a visible bar show as icons above the panel.
- **Damage per second in the spell description**: every DoT tooltip (spellbook, action bars, links) adds a line
  such as "Damage per second: 45.7 (822 over 18 sec)".

## How it works with Midnight's secret values

Enemy health is a secret value: no addon can compare or subtract it. DoT Lethal never does. It hands the health to
the game: the orange chunk is a bar anchored to the end of the health fill, the way Blizzard draws incoming heals,
and the skull is drawn by a curve (or an invisible clamped bar when max health is secret too). The DoT damage
itself is read from the spell description, which already includes your spell power and talents.

## Commands

- `/dotletal` or the addon compartment button: options (Options > AddOns > DoTLetal).
- `/dotletal mover`: unlock the panel to drag it (shows sample data); again to lock it.
- `/dotletal lista`: your DoTs and their seconds between ticks with your talents.
- `/dotletal calibracion` shows the learned factors; `/dotletal calibracion borrar` forgets them.
- `/dotletal debug`: diagnostics to paste when reporting a problem.

## Limits

- Only your own DoTs count; if others help, the target dies sooner.
- It cannot know whether a DoT was resisted or the target is immune.
- It assumes the DoT went to your current target (mouseover or focus casts are tracked wrong).
- It is an estimate: crits and modifiers enter through the calibration, as an average of recent fights. Set
  bonuses that change tick rate and combo-point DoTs (Rip, Rupture) are not covered.
- Nameplates: Blizzard's and Plater.

## Data

Spell data comes from the game client's own tables (DB2 files via wago.tools) and is regenerated after each patch.

## Bugs

Please report with the output of `/dotletal debug` and, if there is an error, the BugSack export.

---

**Español.** DoT Lethal enseña la vida que tus DoTs aún le quitarán al objetivo (franja naranja en su barra), una
calavera si bastan para matarlo y un panel con su daño por segundo y lo que les queda. Funciona en retail
(Midnight) y en Forever, trae todos los DoTs del juego y se calibra solo con el daño real del medidor de Blizzard.
Comandos: `/dotletal`.
```

## Changelog del fichero 1.0.0

```markdown
First public release.

- Health your DoTs will still take, drawn on the target frame, nameplate (Blizzard or Plater) and panel.
- Skull when your DoTs are enough to kill the target.
- Panel with total and per-DoT damage per second and time left; Classic and Compact modes.
- All DoTs of Retail and Forever from the client tables, with tick period, haste and rhythm talents detected.
- Self-calibration with Blizzard's damage meter after single-target fights.
- Options menu with everything from /dotletal.
```

## Pasos que solo puede hacer Nico

1. Crear el proyecto en `https://authors.curseforge.com/#/projects/create/choose-game` con los campos de arriba
   (nombre y tipo Beta/Release son decisión suya) y subir el avatar.
2. Subir `DoTLetal-1.0.0.zip` en «Upload file», marcar Retail 12.1.x y Forever 1.60.1, pegar el changelog.
3. **Plazo:** la moderación de CurseForge trabaja de 08:00 a 15:00 (hora de España). Para que se vea el día del
   lanzamiento de Forever tiene que estar aprobado antes del **04-11-2026 a las 15:00**: subirlo esta noche deja
   el fichero en la cola de mañana a primera hora.
4. Pasarle a Claude el número de proyecto para ponerlo en `## X-Curse-Project-ID` (hoy `0`) si más adelante se
   publica por GitHub Actions (procedimiento en la skill `wow-addons`, `tooling-y-publicacion.md` §8.0).

Antes de publicar como Release: verlo en el cliente (`/reload`, BugSack limpio, franja, calavera y calibración).

**1.0.1, nombre en inglés (05-11-2026, por orden de Nico: «Nombres en inglés siempre»):** el `## Title` del TOC pasa a «DoT Lethal» y el zip a `mods\wow\dist\DoTLethal-1.0.1.zip`. Es el zip publicado anterior con solo el título y la versión cambiados (los cambios sin publicar del repo no entran); la carpeta interna sigue siendo `DoTLetal`, así que las SavedVariables y la junction de `Interface\AddOns` no cambian. Subido como Release con las mismas versiones de juego; pasa por moderación. Desde ahora `empaquetar-wow.py` nombra el zip por el `## Title`.

**1.1.0 (05-11-2026, por orden de Nico: «sube los addons que faltan»):** aviso de relanzar en los botones de acción y DPS del DoT en la descripción. `mods\wow\dist\DoTLethal-1.1.0.zip`; descripción del proyecto ampliada con las dos funciones. Sin ver en el cliente.

## Changelog del fichero 1.1.0

```markdown
- When to recast each DoT, on its action button: amber countdown, green NOW! and red DROPPED; icons above the panel for DoTs not on a visible bar. Options: warning lead time (3 s by default) and an optional sound.
- Every DoT tooltip shows its damage per second (total damage over its duration). Option to turn it off.
```

**1.2.0 (06-11-2026, por Claude con la sesión de Nico en Chrome, por orden suya: «Sí, súbelas»):** fichero «DoT Lethal 1.2.0», `mods\wow\dist\DoTLethal-1.2.0.zip`, tipo **Release**, versiones Forever 1.60.1 y Retail 12.1.5/12.1.0, publicación automática al aprobarse. Changelog en inglés que nombra lo nuevo: daño restante de cada DoT en las filas del panel. Aprobado por CurseForge a los pocos minutos. Pasa las comprobaciones fuera del juego (06-11-2026); **sin probar en el cliente**.
