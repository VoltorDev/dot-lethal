# Plan — DoTLetal

Único plan vivo del addon. Actualizado el 20-10-2026.

## Objetivo

Con un vistazo, saber si los DoTs propios que lleva el objetivo lo matan sin volver a pegarle.

## Estado

| Pieza | Implementado | Verificado |
|---|---|---|
| Lectura de daño y duración en la descripción del hechizo (inglés y español, golpe directo + DoT, modo por tick) | Sí | Tests con descripciones de Classic. **Sin probar con las descripciones reales de Forever** |
| Reloj propio por DoT, ticks con peso (Maldición de agonía), reaplicar | Sí | Tests fuera del juego |
| Seguimiento por objetivo (por GUID si es legible; si es secreto, solo el actual) | Sí | Tests con GUID legible y secreto |
| Veredicto por recorte de la barra (`SetMinMaxValues(R, R + 1)` + `SetValue(vida secreta)`) | Sí | Mock de secretos: la vida nunca se compara en Lua y las mutaciones que lo intentan fallan. **Sin ver en el cliente** |
| Barra de vida con el daño de los DoTs superpuesto, textos, mover y bloquear, opciones | Sí | Tests fuera del juego |

## Pendiente

1. **Probar en el cliente** (lo primero). Es lo que decide si funciona:
   - Reiniciar el cliente la primera vez, ya que el addon es nuevo.
   - `/dotletal lista`: que salgan los nombres. Si falta alguno, el spellID de Classic no existe en
     Forever; buscar el bueno o añadirlo con `/dotletal añadir`.
   - `/dotletal traza` y lanzar cada DoT a un muñeco: si no reconoce la descripción, la traza la enseña;
     ajustar `Dots.ParseDescription` con el texto real.
   - Con un enemigo bajo de vida, comprobar que el cuadro pasa de rojo a verde. Este es el punto
     incierto: que la barra recorte la vida secreta a su rango igual que lo hace con un número.
   - `/dump issecretvalue(UnitGUID("target"))` en el mundo y en mazmorra, para saber qué modo de
     seguimiento usa en cada sitio.
2. Detectar resistencias o inmunidades: hoy se cuenta el DoT aunque no entre.
3. Desgarro y Ruptura (dependen de los puntos de combo), si se juega druida feral o pícaro.
