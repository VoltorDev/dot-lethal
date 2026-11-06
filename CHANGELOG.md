# Changelog

## 1.2.0 (06-11-2026)

- 06-11-2026: cada fila del panel muestra, además del tiempo y el daño por segundo, el daño que le queda a ese DoT («15 s · 20/s · 300»). El panel es algo más ancho para que quepa.

## 1.1.0 (05-11-2026)

- 05-11-2026: la descripción de cada hechizo con daño en el tiempo (libro, barras de acción, enlaces) añade su daño por segundo: «Daño por segundo: 45,7 (822 en 18 s)». Solo en los DoTs que el addon conoce; en los que también golpean al lanzarse cuenta solo la parte en el tiempo. Opción nueva «DPS de los DoTs en la descripción» (activada).
- 05-11-2026: aviso de cuándo relanzar cada DoT, encima de su botón en las barras de acción de Blizzard: marco ámbar con cuenta atrás (aún no), verde «¡YA!» (lánzalo: en Forever llega justo tras el último tick, contando su tiempo de lanzamiento; en retail, dentro de la pandemia) y rojo «CAÍDO» durante 8 s si se cae y sigues con el objetivo. Los DoTs que no están en ninguna barra visible salen en iconos encima del panel. Las filas del panel toman el mismo color. Opciones nuevas: avisar en los botones (activado), iconos sobre el panel (si no está en las barras / siempre / nunca), aviso previo (3 s, de 1 a 6) y sonido (desactivado).
- 21-10-2026: calibración con el daño real. Al salir de un combate contra un solo objetivo, compara el daño de cada DoT en el medidor de daño de Blizzard con lo estimado y guarda un factor por hechizo y personaje (críticos, maestría y lo que la descripción no dice). `/dotletal calibracion [borrar]` y opciones nuevas. Si el objetivo muere, sus DoTs dejan de contar en ese momento.
- 21-10-2026: al reaplicar un DoT en retail, el reloj de los ticks ya no se reinicia (como en el juego: el siguiente tick cae cuando tocaba y el último sale parcial). Antes el addon restaba cada tick hasta un intervalo tarde y la franja naranja se quedaba entera mientras la vida bajaba.
- Todos los DoTs del juego (retail y Forever) sacados de las tablas del cliente, con su periodo y si la celeridad los acelera; detección automática de los talentos que cambian el ritmo de los ticks. Ya no hay que añadir DoTs a mano (se quitan /dotletal añadir y quitar y sus opciones).
- Catálogo de retail corregido con las tablas del juego: Aflicción inestable 1259790, Inmolar 118297, Choque de llamas 470411, Palabra de las Sombras: locura en lugar de Peste devoradora, periodos reales de tick.
- Agonía: el «hasta» de su descripción es con el escalón máximo (x8); antes sobreestimaba la primera aplicación.
- La lectura de descripciones ignora los porcentajes y Putrefacción de alma toma el daño del objetivo principal.
- Retail (12.1): catálogo de DoTs de retail, celeridad, pandemia y rampa de Agonía.
- Daño por segundo total y por DoT, y segundos que le quedan a cada uno.
- Vida que perderá por DoTs pintada en la barra del marco de objetivo, de la placa (Blizzard o Plater) y del panel, con una calavera si lo matan. Sustituye al cuadro verde o rojo.
- Primera versión: veredicto de DoTs letales con la vida secreta, 14 DoTs de serie y DoTs añadidos a mano.

## 1.0.1 (05-11-2026)

- The addon list in game now shows its English name, **DoT Lethal** (the folder is still `DoTLetal`, so your settings are kept). Same code as 1.0.0; the changes above are not in this release.

