# DoTLetal

Addon para World of Warcraft: Forever.

## Qué hace

Describe aquí la función del addon en dos o tres frases, y para quién es.

## Uso

- `/dotletal` o el botón del compartimento de addons (junto al minimapa) abre las opciones.
- `/dotletal debug` muestra el diagnóstico que hay que pegar al informar de un problema.
- `/dotletal reset confirm` restaura los valores por defecto.

## Informar de un problema

Abre un issue con el texto de `/dotletal debug` y, si hay error, la exportación de BugSack.

## Desarrollo

Proyecto creado con la plantilla de la skill `wow-addons`. Comprobaciones fuera del juego (luacheck,
StyLua, LuaLS, API real de Forever, tests en Lua 5.1 y XML):

```powershell
C:\Users\Nico\.claude\skills\wow-addons\scripts\verificar-addon.ps1 -Carpeta .
```

Tests solos: `python tools/probar_addon.py . --ambos`. Para publicar, se sube una etiqueta `vX.Y.Z`:
GitHub Actions empaqueta y publica en CurseForge y Wago.

## Licencia

MIT (ver `LICENSE`).
