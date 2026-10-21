# DoTLetal

Addon para World of Warcraft **retail** (Midnight, 12.1) y **Forever**. Mientras tus DoTs hacen daño:

- **En la barra de vida del objetivo** (marco de objetivo, su placa y el panel del addon) pinta en
  naranja el trozo de vida que se llevarán tus DoTs.
- Pone una **calavera** a la izquierda de esa barra si tus DoTs bastan para matarlo.
- Un **panel** dice cuánto daño por segundo le hacen tus DoTs y cuánto les queda en total, y debajo,
  uno por línea, cada DoT con los segundos que le quedan y su daño por segundo.

## Cómo lo sabe (y por qué no hace la cuenta él)

Desde Midnight la vida de los enemigos es un **valor secreto**: un addon no puede compararla ni
restarla. DoTLetal no lo hace; le entrega la vida al juego:

- **Pérdida**: una barra naranja anclada al final del relleno de la barra de vida, con el mismo
  máximo y el daño de los DoTs como valor. Blizzard pinta así su predicción de curación.
- **Calavera**: si la vida máxima del objetivo es legible, una curva escalonada sobre el porcentaje de
  vida la muestra solo por debajo del daño de los DoTs. Si también es secreta, la decide una barra
  invisible con rango [daño, daño + 1] que el juego recorta.

El daño de los DoTs sí lo calcula el addon, con su propio reloj, porque en combate las auras del
objetivo también son secretas:

1. Al terminar de lanzar un DoT, apunta la hora. **Trae todos los DoTs del juego**, sacados de las tablas
   del propio cliente (`Datos/Retail.lua`, 116 hechizos, y `Datos/Forever.lua`, 231 con todos sus rangos):
   su periodo de tick, si la celeridad lo acelera y a qué talentos responde. No hay que añadir nada.
2. Lee el daño total y la duración en la descripción del hechizo, que ya incluye tu poder con hechizos y
   los talentos que cambian el daño o la duración.
3. **Detecta solo** los talentos que tienes que cambian el ritmo de los ticks (por ejemplo, Creeping Death,
   −10 % sobre Corrupción, Agonía y Aflicción inestable) y los recalcula al cambiar talentos o especialización.
4. En retail aplica tu celeridad a los DoTs que el juego marca así (los ticks van más rápido y hacen más daño
   en total) y la pandemia: reaplicar conserva hasta el 30 % de la duración. La Agonía sube de escalón en
   cada tick. En Forever, como en Vanilla, la celeridad no acelera los DoTs.

## Uso

- `/dotletal mover` desbloquea el panel (se ve con datos de muestra) para arrastrarlo; repítelo para
  bloquearlo.
- `/dotletal lista` enseña tus DoTs y sus segundos entre ticks con tus talentos.
- `/dotletal` o el botón del compartimento de addons abre las opciones (Opciones > AddOns > DoTLetal), con todo
  lo de los comandos: activar, escala, modo (Clásico con la lista o Compacto con solo los totales), marcar el
  marco de objetivo y la placa, bloquear el panel, traza, ver tus DoTs, diagnóstico y restablecer (con
  confirmación).
- `/dotletal traza` activa mensajes de depuración (por ejemplo, si no entiende la descripción de un DoT).
- `/dotletal debug` saca el diagnóstico para informar de un problema.

Los datos se regeneran tras cada parche con `python tools/generar_datos.py`, que baja las tablas del cliente
de wago.tools (SpellEffect, SkillLineAbility, SpecializationSpells, TraitDefinition, Talent, SpellClassOptions,
SpellMisc, SpellDuration) para el build de retail y el de Forever que tiene apuntados. Un DoT es un hechizo que
el jugador puede aprender con un efecto de daño periódico sobre otro; quedan fuera los pasivos y los canalizados
(se cortan y el addon no puede saberlo).

## Límites (conviene saberlos)

- **Solo cuenta tus DoTs.** El daño de otros jugadores no entra; si te ayudan, morirá antes.
- **No sabe si el DoT ha entrado.** Si el objetivo lo resiste o es inmune, el addon lo cuenta igual.
- **Supone que el DoT va al objetivo actual.** Lanzado por mouseover o foco, se apunta mal.
- **Al cambiar de objetivo puede olvidarlo.** Si el juego oculta la identidad del PNJ (GUID secreto),
  solo sigue al objetivo actual y borra sus DoTs al cambiar.
- **Es una estimación.** Críticos, maestría y otros modificadores que la descripción no recoge, los efectos
  de conjunto de equipo que cambian el ritmo y los DoTs que dependen de los puntos de combo (Destripar,
  Ruptura) quedan fuera. La celeridad, si en
  combate es secreta, se toma de la última lectura.
- La placa se marca con las de Blizzard y con Plater; otras placas o marcos de unidad, no.

## Informar de un problema

Abre un issue con el texto de `/dotletal debug` y, si hay error, la exportación de BugSack.

## Desarrollo

Proyecto creado con la plantilla de la skill `wow-addons`. Comprobaciones fuera del juego (luacheck,
StyLua, LuaLS, API real de Forever, tests en Lua 5.1 y XML):

```powershell
C:\Users\Nico\.claude\skills\wow-addons\scripts\verificar-addon.ps1 -Carpeta .
```

Tests solos: `python tools/probar_addon.py . --ambos`. Estado y pendientes en [PLAN.md](PLAN.md).
