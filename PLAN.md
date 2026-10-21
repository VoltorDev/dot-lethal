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
| Pérdida en naranja sobre la barra del marco de objetivo, de la placa (Blizzard o Plater) y del panel | Sí | Mock: la vida nunca se compara en Lua y la barra se ancla al relleno. **Vista por Nico en retail el 21-10-2026**: a veces la vida bajaba con la franja entera. Causa encontrada: al reaplicar (pandemia) el addon reiniciaba el reloj de los ticks y los restaba hasta un intervalo tarde; corregido ese día (el siguiente tick conserva su hora, como `dot_t::refresh` de SimulationCraft), 2 tests nuevos que fallan con el código anterior. **Falta verlo otra vez en el cliente** |
| Calavera: por curva si la vida máxima es legible; por barra compuerta si es secreta | Sí | Mock de los dos caminos. **Sin ver en el cliente** |
| Calibración con el daño real (`Modules/Calibration.lua`, cuenta en `Dots.lua`, 21-10-2026, pedido de Nico: «¿no hay manera de leer el daño real?»). En combate no se puede (registro cerrado, `C_DamageMeter` es `SecretWhenInCombat`, `UNIT_COMBAT` no dice quién ni con qué); al salir, el daño de cada hechizo del jugador en el medidor contra lo estimado sin factor, y un factor por hechizo y personaje (`DoTLetalCharDB.calibration`, media por ticks con memoria de 60). Solo combates de un objetivo, sin perder la pista de ningún DoT, sesión de duración parecida, 3 ticks o más, sin golpe directo y proporción entre 0,5 y 3. Si el objetivo muere, sus DoTs dejan de contar entonces | Sí | 11 tests con el medidor simulado (secreto en combate), entre ellos el de la muerte del objetivo, que falla sin el arreglo; 146 tests en Lua 5.1 y LuaJIT. **Sin probar en el cliente**: que la sesión `Current` siga siendo la del combate al salir, que `combatSpells` traiga los DoTs con su ID o el del aura y si `totalAmount` incluye el daño sobrante (`overkillAmount`) |
| Menú de opciones con todo lo de `/dotletal` (21-10-2026) | Sí | Tests del menú. **Sin ver en el cliente** |
| Todos los DoTs del juego y talentos de ritmo detectados solos (21-10-2026, pedido de Nico: «el jugador no debería añadir nada»). `tools/generar_datos.py` con las DB2 de wago.tools: 116 DoTs en retail (12.1.5.70448) y 231 en Forever (1.60.1.70245); 35 talentos de ritmo en retail (operación 19, comprobada con Creeping Death, Rapid Contagion y Sataiel's Volition). Se quitó el añadido manual | Sí | `tests/probar_generador.py` con tablas inventadas; 133 tests del addon con los datos reales (Toque vampírico sin catálogo, Fuego lunar por nombre, Creeping Death, cambio de talentos, Forever sin celeridad). **Sin probar en el cliente** que `C_SpellBook.IsSpellKnown` ve los talentos pasivos |

## Pendiente

1. **Probar en retail con Brujete (aflicción)**. El 21-10-2026 Nico lo probó y dice que «parece que va
   bien», sin datos concretos; Claude no pudo verlo (sin acceso a `wow.exe` por control remoto). Falta
   confirmar cada punto:
   - Reiniciar el cliente la primera vez, ya que el addon es nuevo.
   - `/dotletal lista`: que salgan Agonía, Corrupción, Aflicción inestable… con el periodo que toca. Con
     Creeping Death, 1,8 s en vez de 2: si sale 2, `C_SpellBook.IsSpellKnown` no ve los talentos pasivos.
   - `/dotletal traza` y lanzar cada DoT a un muñeco: si no reconoce la descripción, la traza la
     enseña. Comparar el daño por segundo del panel con el que da Details en el muñeco.
   - Ver la franja naranja al final de la vida en el marco de objetivo y en la placa de Plater. Es el
     punto incierto: que un marco de addon pueda anclarse al relleno de una barra con vida secreta.
   - Bajar un enemigo hasta que salga la calavera.
   - `/dump issecretvalue(UnitHealthMax("target"))` en el mundo y en mazmorra, para saber qué camino
     de la calavera se usa en cada sitio.
   - Calibración, en un muñeco y solo: activar el medidor de daño de Blizzard y `/dotletal traza`; lanzar
     Corrupción y Agonía, esperar a que terminen y salir de combate. La traza dice «calibración: …» con lo real,
     lo previsto y el factor, o por qué no calibra. Si falla, fuera de combate:
     `/dump C_DamageMeter.IsDamageMeterAvailable()`, `/dump C_DamageMeter.GetSessionDurationSeconds(1)` y
     `/run local s=C_DamageMeter.GetCombatSessionSourceFromType(1,0,UnitGUID("player")) print(canaccesstable(s)) for _,x in ipairs(s.combatSpells) do print(x.spellID,C_Spell.GetSpellName(x.spellID),x.totalAmount,x.overkillAmount) end`.
     Luego `/dotletal calibracion`.
2. Lo mismo en Forever a partir del 05-11-2026.
3. Detectar resistencias o inmunidades: hoy se cuenta el DoT aunque no entre.
4. Destripar y Ruptura (dependen de los puntos de combo), si se juega druida feral o pícaro.
