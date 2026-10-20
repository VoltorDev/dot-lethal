local _, ns = ...

local locale = GetLocale()
if locale ~= "esES" and locale ~= "esMX" then
    return
end

local L = ns.L

L.LOADED = "cargado. Escribe /dotletal para ver las opciones."
L.SLASH_HELP = "Comandos: /dotletal [config | mover | lista | añadir <segundos> <hechizo> | quitar <hechizo>"
    .. " | traza | debug | reset]"
L.ERR_COMBAT = "No disponible en combate; inténtalo al salir de él."
L.RESET_CONFIRM = "Escribe /dotletal reset confirmar para volver a los valores por defecto."
L.RESET_DONE = "Opciones restauradas a los valores por defecto."
L.COMPARTMENT_TOOLTIP = "Clic para abrir las opciones."

L.OPT_ENABLED = "Activar"
L.OPT_ENABLED_TT = "Muestra u oculta todo lo que dibuja este addon."
L.OPT_SCALE = "Escala"
L.OPT_SCALE_TT = "Tamaño de los marcos del addon."
L.OPT_MODE = "Modo"
L.OPT_MODE_TT =
    "Clásico muestra el daño de los DoTs, su tiempo y la vida del objetivo; Compacto, solo el cuadro y la barra."
L.MODE_CLASSIC = "Clásico"
L.MODE_COMPACT = "Compacto"

L.DEBUG_HEADER = "Diagnóstico (pégalo al informar de un problema):"

L.DOTS_LEFT = "DoTs %s · %.0f s"
L.LOCKED = "Marco bloqueado. Solo aparece mientras tus DoTs hacen daño."
L.UNLOCKED = "Marco desbloqueado: arrástralo con el botón izquierdo. /dotletal mover para bloquearlo."
L.KNOWN_HEADER = "DoTs que sigue (nombre y segundos entre ticks):"
L.ADD_USAGE = "Uso: /dotletal añadir <segundos entre ticks> <nombre exacto del hechizo>"
L.ADDED = "Añadido %s (un tick cada %s s)."
L.REMOVED = "Quitado %s."
L.NOT_CUSTOM = "%s no está entre los que has añadido."
L.TRACE_ON = "Traza activada."
L.TRACE_OFF = "Traza desactivada."
