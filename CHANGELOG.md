# Changelog

## Sin publicar

- 07-11-2026: el DoT va al enemigo que tenías al pulsarlo, no al de cuando el servidor lo confirma: cambiar de
  objetivo justo después de un instantáneo ya no se lo pone al nuevo. Las macros al foco y lanzar al ratón también
  aciertan.
- 07-11-2026: los DoTs de cada enemigo se siguen aunque cambies de objetivo, también con la identidad del PNJ oculta
  (mazmorras), por su placa. La franja y la calavera salen en la placa de cada enemigo con DoTs tuyos y en el marco
  de foco (opción nueva «Marcar el marco de foco», activada).
- 07-11-2026: respaldo de los fallos: un DoT del que pasan dos ticks sin ver ningún golpe a su hora se quita.
- 07-11-2026: opción «Modo prudente» (desactivada): la calibración solo puede bajar el daño previsto, así que no
  cuenta con críticos que aún no han salido y la calavera solo aparece si los DoTs bastan sin ellos.
- 07-11-2026: un DoT fallado (fallo, resistido, inmune; esquivado o parado si es un sangrado) ya no cuenta su daño en la barra: se quita y sale como «CAÍDO» para relanzarlo. Si era un relanzamiento, sigue contando el anterior. El aviso viene del resultado del ataque sobre el objetivo justo al lanzarlo (idea tomada de Does It Die, MIT). Si en ese mismo instante falla un golpe de tu mascota o de otro jugador, puede quitar un DoT que sí entró: el error es siempre por lo bajo.

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

