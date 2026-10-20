# Plan — DoTLetal

Único plan vivo del addon. Actualizado el 20-10-2026.

## Objetivo

En retail y en Forever, de un vistazo: cuánto daño por segundo le hacen al objetivo los DoTs
propios, cuánto le queda a cada uno, qué parte de su vida se llevarán, y una calavera si lo matan.

## Estado

| Pieza | Implementado | Verificado |
|---|---|---|
| Carga en retail (12.1, `standard`) y Forever (`camelot`/`forever`) | Sí | Cliente simulado de las dos. Enlazado en `_retail_` y `_forever_`. **Sin cargar en el juego** |
| Lectura de daño y duración en la descripción (inglés y español, golpe directo + DoT, modo por tick) | Sí | Tests con descripciones inventadas con la forma de las reales. **Sin probar con las descripciones reales** |
| Reloj por DoT: celeridad con último tick parcial, pandemia del 30 %, rampa de Agonía, pesos de Classic | Sí | Tests fuera del juego. Los periodos de tick de retail son de memoria |
| Daño por segundo total y por DoT; segundos restantes por DoT | Sí | Tests del panel |
| Pérdida en naranja sobre la barra del marco de objetivo, de la placa (Blizzard o Plater) y del panel | Sí | Mock: la vida nunca se compara en Lua y la barra se ancla al relleno. **Sin ver en el cliente** |
| Calavera: por curva si la vida máxima es legible; por barra compuerta si es secreta | Sí | Mock de los dos caminos. **Sin ver en el cliente** |

## Pendiente

1. **Probar en retail con Brujete (aflicción)**. Es lo que decide si funciona:
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
