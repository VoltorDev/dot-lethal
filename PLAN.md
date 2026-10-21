# Plan — DoTLetal

Único plan vivo del addon. Actualizado el 20-10-2026.

## Objetivo

En retail y en Forever, de un vistazo: cuánto daño por segundo le hacen al objetivo los DoTs
propios, cuánto le queda a cada uno, qué parte de su vida se llevarán, y una calavera si lo matan.

## Estado

| Pieza | Implementado | Verificado |
|---|---|---|
| Carga en retail (12.1, `standard`) y Forever (`camelot`/`forever`) | Sí | Cliente simulado de las dos. Enlazado en `_retail_` y `_forever_`. **Sin cargar en el juego** |
| Lectura de daño y duración en la descripción (inglés y español, golpe directo + DoT, por tick, mayor número) | Sí | Tests con los textos reales de retail en español (Wowhead, 20-10-2026) con números en lugar de fórmulas. **Sin probar con lo que devuelve el cliente** |
| Reloj por DoT: celeridad con último tick parcial, pandemia del 30 %, rampa de Agonía (x8), pesos de Classic | Sí | Tests fuera del juego. ID y periodos de retail sacados de SkillLineAbility, TraitDefinition y SpellEffect (wago.tools, 20-10-2026); el de Arañazo, de memoria |
| APIs usadas, contra la interfaz de retail 12.1.5 (build 70448) | Sí | Existen todas con las mismas marcas de secreto; ruta de la barra del marco de objetivo y `UnitFrame.healthBar` de las placas comprobadas. Retail documenta los anclajes secretos (`IsAnchoringSecret`), que es lo que usa la franja naranja |
| Daño por segundo total y por DoT; segundos restantes por DoT | Sí | Tests del panel |
| Pérdida en naranja sobre la barra del marco de objetivo, de la placa (Blizzard o Plater) y del panel | Sí | Mock: la vida nunca se compara en Lua y la barra se ancla al relleno. **Sin ver en el cliente** |
| Calavera: por curva si la vida máxima es legible; por barra compuerta si es secreta | Sí | Mock de los dos caminos. **Sin ver en el cliente** |
| Menú de opciones con todo lo de `/dotletal` (21-10-2026); añadir un DoT = el último hechizo lanzado | Sí | 4 tests nuevos (128 en total). **Sin ver en el cliente** |

## Pendiente

1. **Probar en retail con Brujete (aflicción)**. El 21-10-2026 Nico lo probó y dice que «parece que va
   bien», sin datos concretos; Claude no pudo verlo (sin acceso a `wow.exe` por control remoto). Falta
   confirmar cada punto:
   - Reiniciar el cliente la primera vez, ya que el addon es nuevo.
   - `/dotletal lista`: que salgan Agonía, Corrupción, Aflicción inestable… Si falta alguno, su spellID
     no es el bueno; añadirlo con `/dotletal añadir`.
   - `/dotletal traza` y lanzar cada DoT a un muñeco: si no reconoce la descripción, la traza la
     enseña. Comparar el daño por segundo del panel con el que da Details en el muñeco.
   - Ver la franja naranja al final de la vida en el marco de objetivo y en la placa de Plater. Es el
     punto incierto: que un marco de addon pueda anclarse al relleno de una barra con vida secreta.
   - Bajar un enemigo hasta que salga la calavera.
   - `/dump issecretvalue(UnitHealthMax("target"))` en el mundo y en mazmorra, para saber qué camino
     de la calavera se usa en cada sitio.
2. Lo mismo en Forever a partir del 05-11-2026.
3. Detectar resistencias o inmunidades: hoy se cuenta el DoT aunque no entre.
4. Destripar y Ruptura (dependen de los puntos de combo), si se juega druida feral o pícaro.
