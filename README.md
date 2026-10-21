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

1. Al terminar de lanzar un DoT conocido, apunta la hora.
2. Lee el daño total y la duración en la descripción del hechizo, que ya incluye tu poder con hechizos.
3. En retail aplica tu celeridad (los ticks van más rápido y hacen más daño en total) y la pandemia:
   reaplicar conserva hasta el 30 % de la duración. La Agonía sube de escalón en cada tick.

## Uso

- `/dotletal mover` desbloquea el panel (se ve con datos de muestra) para arrastrarlo; repítelo para
  bloquearlo.
- `/dotletal lista` enseña los DoTs que sigue.
- `/dotletal añadir 2 Nombre exacto` añade un DoT que no esté en la lista (aquí, un tick cada 2 s sin
  celeridad). `/dotletal quitar Nombre exacto` lo quita.
- `/dotletal` o el botón del compartimento de addons abre las opciones (Opciones > AddOns > DoTLetal), con todo
  lo de los comandos: activar, escala, modo (Clásico con la lista o Compacto con solo los totales), marcar el
  marco de objetivo y la placa, bloquear el panel, traza, ver los DoTs que sigue, **añadir el último hechizo que
  lanzaste** (con sus segundos entre ticks), quitar uno añadido, diagnóstico y restablecer (con confirmación).
- `/dotletal traza` activa mensajes de depuración (por ejemplo, si no entiende la descripción de un DoT).
- `/dotletal debug` saca el diagnóstico para informar de un problema.

DoTs de serie en retail: Agonía, Corrupción, Aflicción inestable, Succionar vida, Marchitar,
Putrefacción de alma, Inmolar, Palabra de las Sombras: dolor, Toque vampírico, Palabra de las Sombras:
locura, Fuego lunar, Fuego solar, Centella estelar, Arañazo, Vapulear, Choque de llamas, Garrote,
Desgarrar y Picadura de serpiente. Sus ID y periodos de tick salen de las tablas del juego (12.1.5). En
Forever, los equivalentes de Classic.

## Límites (conviene saberlos)

- **Solo cuenta tus DoTs.** El daño de otros jugadores no entra; si te ayudan, morirá antes.
- **No sabe si el DoT ha entrado.** Si el objetivo lo resiste o es inmune, el addon lo cuenta igual.
- **Supone que el DoT va al objetivo actual.** Lanzado por mouseover o foco, se apunta mal.
- **Al cambiar de objetivo puede olvidarlo.** Si el juego oculta la identidad del PNJ (GUID secreto),
  solo sigue al objetivo actual y borra sus DoTs al cambiar.
- **Es una estimación.** Críticos, maestría y otros modificadores que la descripción no recoge, y los
  DoTs que dependen de los puntos de combo (Destripar, Ruptura), quedan fuera. La celeridad, si en
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
