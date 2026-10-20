# DoTLetal

Addon para World of Warcraft: Forever. Te dice si los DoTs que le has puesto al objetivo lo van a
matar sin que le pegues más.

## Qué se ve

Mientras tus DoTs hacen daño aparece un marco pequeño:

- **Cuadro verde con un visto bueno**: lo que les queda a tus DoTs basta para matarlo. Puedes cambiar
  de objetivo.
- **Cuadro rojo**: no basta.
- **Barra de la derecha**: en gris, la vida del objetivo; encima, en verde, el daño que les queda a tus
  DoTs en la misma escala. Si el verde pasa del final del gris, muere.
- **Texto** (modo Clásico): daño restante de los DoTs, segundos que les quedan y vida del objetivo.

## Cómo lo sabe (y por qué no hace la cuenta él)

En Forever la vida de los enemigos es un **valor secreto**: un addon no puede compararla ni restarla.
DoTLetal no la compara. Le pasa la vida a una barra cuyo rango va del daño restante R a R + 1. La barra
la recorta: queda vacía (se ve el verde) si la vida es R o menos, y llena (tapa de rojo) si es más. El
cálculo lo hace el propio juego al dibujar, que es lo que Blizzard permite.

El daño de los DoTs sí lo calcula el addon, con su propio reloj, porque en combate las auras del
objetivo también son secretas:

1. Al terminar de lanzar un DoT conocido, apunta la hora.
2. Lee el daño total y la duración en la descripción del hechizo, que ya incluye tu poder con hechizos.
3. Descuenta un tick cada X segundos.

## Uso

- `/dotletal mover` desbloquea el marco (se ve con datos de muestra) para arrastrarlo; repítelo para
  bloquearlo.
- `/dotletal lista` enseña los DoTs que sigue.
- `/dotletal añadir 3 Nombre exacto` añade un DoT que no esté en la lista (aquí, un tick cada 3 s).
  `/dotletal quitar Nombre exacto` lo quita.
- `/dotletal` o el botón del compartimento de addons abre las opciones: activar, escala y modo.
- `/dotletal traza` activa mensajes de depuración (por ejemplo, si no entiende la descripción de un DoT).
- `/dotletal debug` saca el diagnóstico para informar de un problema.

DoTs que trae de serie: Corrupción, Maldición de agonía (con sus ticks crecientes), Inmolar, Succionar
vida, Palabra de las Sombras: dolor, Peste devoradora, Fuego lunar, Enjambre de insectos, Arañazo,
Picadura de serpiente, Choque de llamas, Desgarrar, Garrote y Piroexplosión.

## Límites (conviene saberlos)

- **Solo cuenta tus DoTs.** El daño de otros jugadores no entra; si te ayudan, morirá antes.
- **No sabe si el DoT ha entrado.** Si el objetivo lo resiste o es inmune, el addon lo cuenta igual.
- **Supone que el DoT va al objetivo actual.** Lanzado por mouseover o foco, se apunta mal.
- **Al cambiar de objetivo puede olvidarlo.** Si el juego oculta la identidad del PNJ (GUID secreto),
  solo sigue al objetivo actual y borra sus DoTs al cambiar; si la identidad es legible, recuerda
  cada objetivo.
- Desgarro y Ruptura (dependen de los puntos de combo) y los efectos pasivos (Ignición, Heridas
  profundas) no están.
- Es una estimación: los ticks reales pueden variar algo respecto a la descripción.

## Informar de un problema

Abre un issue con el texto de `/dotletal debug` y, si hay error, la exportación de BugSack.

## Desarrollo

Proyecto creado con la plantilla de la skill `wow-addons`. Comprobaciones fuera del juego (luacheck,
StyLua, LuaLS, API real de Forever, tests en Lua 5.1 y XML):

```powershell
C:\Users\Nico\.claude\skills\wow-addons\scripts\verificar-addon.ps1 -Carpeta .
```

Tests solos: `python tools/probar_addon.py . --ambos`. Estado y pendientes en [PLAN.md](PLAN.md).
