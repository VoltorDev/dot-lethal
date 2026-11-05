# Plan — DoTLetal

Único plan vivo del addon. Actualizado el 05-11-2026.

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

| Aviso de cuándo relanzar cada DoT (05-11-2026, pedido de Nico: «saber cuándo castear un DoT para no perder daño»). `Dots.RenewPhase` con el reloj propio y `C_Spell.GetSpellInfo().castTime`: fases ok / pronto (3 s antes de serie, ajustable de 1 a 6 s con «Aviso previo») / ¡YA! / caído (8 s). Forever: sin pandemia y con los ticks reiniciados al reaplicar, «¡YA!» cuando quedan los segundos de lanzamiento + 0,1 s; retail: al entrar el nuevo en el 30 %. Mismo día, a petición de Nico («que sea menos intrusivo»): el aviso va **encima del botón de cada DoT en las barras de Blizzard** (marco propio hijo del botón, con borde de color y texto; el botón se localiza por su `.action` y `C_ActionBar.GetSpell`, cualquier rango por nombre; los marcos se crean fuera de combate). Iconos encima del panel (`DoTLetalAlert`) solo para los DoTs que no están en ninguna barra visible (opción: siempre / nunca), filas coloreadas y sonido opcional. Bartender, ElvUI y Dominos no están cubiertos | Sí | 14 tests en `tests/renew_spec.lua` (fases en Forever y retail, caídos, orden, tiempo de lanzamiento secreto, iconos, sonido, opción, muestra al mover) y 7 en `tests/buttons_spec.lua` (marco y texto en el botón, otro rango, botón oculto, opciones, cambio de ranura, el botón de Blizzard no se toca); 168 tests en Lua 5.1 y LuaJIT. **Sin ver en el cliente** que el marco quede encima del icono y que no dé errores de taint («Interface action failed») en combate. Regla de Forever según guías de terceros (classicwow.gg: «Pandemia» es un talento de críticos y no conserva duración al reaplicar), **sin confirmar en el cliente**: que reaplicar no arrastre tiempo y que reinicie el reloj de los ticks |

## Pendiente

1. **Probar el aviso de relanzar en Forever con Fear Ofme (brujo 7)**, en un enemigo con vida de sobra y solo:
   - Tener Corrupción, Inmolar y Maldición de agonía en las barras de Blizzard. `/reload`.
   - Lanzar Corrupción y mirar su botón. Con unos 5 s restantes (3 s de aviso previo + 2 s de lanzamiento) el botón se enmarca en ámbar con cuenta atrás;
     con 2,1 s, verde «¡YA!»: lanzarla entonces y comprobar en el texto flotante de daño que cae el último tick de
     la vieja y la nueva empieza sin hueco. `/dump C_Spell.GetSpellInfo(172).castTime` debe coincidir, en milisegundos,
     con el tiempo de lanzamiento del tooltip (si sale 0 con un hechizo que no es instantáneo, el «¡YA!» llega tarde).
   - Comprobar la regla de Forever: con Corrupción a 9 s, relanzarla y ver en el marco de objetivo de Blizzard (o
     pasando el ratón por el icono del debuff) si su duración vuelve a 18 s exactos (sin pandemia, lo que supone
     el addon) o a más (habría pandemia: cambiar `Dots.Configure`). Ver también si el siguiente tick llega 3 s
     después del recast (reloj reiniciado, lo que supone el addon) o cuando tocaba.
   - Dejar caer la Maldición de agonía: debe salir «CAÍDO» en rojo, parpadeando, unos 8 s; al relanzarla, se va.
   - Activar «Sonido al tocar relanzar» y ver que suena una vez por DoT, no en bucle.
   - Taint: tras varios combates con avisos, ningún «Interface action failed because of an AddOn» ni errores en
     BugSack, y los botones siguen lanzando en combate. Quitar un DoT de la barra: su aviso pasa al icono sobre el panel.
2. **Probar en retail con Brujete (aflicción)**. El 21-10-2026 Nico lo probó y dice que «parece que va
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
3. Lo mismo en Forever a partir del 05-11-2026.
4. Detectar resistencias o inmunidades: hoy se cuenta el DoT aunque no entre.
5. Destripar y Ruptura (dependen de los puntos de combo), si se juega druida feral o pícaro.
