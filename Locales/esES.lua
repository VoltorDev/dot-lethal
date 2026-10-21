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
L.OPT_MODE_TT = "Clásico enumera cada DoT con su tiempo y su daño por segundo; Compacto, solo los totales."
L.MODE_CLASSIC = "Clásico"
L.MODE_COMPACT = "Compacto"

L.DEBUG_HEADER = "Diagnóstico (pégalo al informar de un problema):"

L.HEADER = "DoTs %s/s · quedan %s"
L.ROW = "%.0f s · %s/s"
L.OPT_TARGETFRAME = "Marcar el marco de objetivo"
L.OPT_TARGETFRAME_TT = "En la barra de vida del marco de objetivo: la vida que perderá por tus DoTs y una calavera"
    .. " si lo matan."
L.OPT_NAMEPLATE = "Marcar la placa del objetivo"
L.OPT_NAMEPLATE_TT = "Lo mismo en la placa de tu objetivo (Blizzard o Plater)."
L.LOCKED = "Marco bloqueado. Solo aparece mientras tus DoTs hacen daño."
L.UNLOCKED = "Marco desbloqueado: arrástralo con el botón izquierdo. /dotletal mover para bloquearlo."
L.KNOWN_HEADER = "DoTs que sigue (nombre y segundos entre ticks):"
L.ADD_USAGE = "Uso: /dotletal añadir <segundos entre ticks> <nombre exacto del hechizo>"
L.ADDED = "Añadido %s (un tick cada %s s)."
L.REMOVED = "Quitado %s."
L.NOT_CUSTOM = "%s no está entre los que has añadido."
L.TRACE_ON = "Traza activada."
L.TRACE_OFF = "Traza desactivada."

-- Menú de opciones (Config.lua)
L.OPT_LOCKED = "Bloquear el panel"
L.OPT_LOCKED_TT = "Bloqueado, el panel solo aparece mientras tus DoTs hacen daño. Desbloqueado,"
    .. " enseña datos de muestra "
    .. "para arrastrarlo."
L.OPT_TRACE = "Traza"
L.OPT_TRACE_TT = "Mensajes de depuración en el chat, por ejemplo si no entiende la descripción de un DoT."
L.OPT_SECTION_DOTS = "DoTs que sigue"
L.OPT_LIST = "DoTs que sigue"
L.OPT_LIST_BUTTON = "Ver lista"
L.OPT_LIST_TT = "Escribe en el chat los DoTs que sigue y sus segundos entre ticks."
L.OPT_ADD_PERIOD = "Segundos entre ticks del DoT que añadas"
L.OPT_ADD_PERIOD_TT = "Los usa «Añadir el último hechizo que lanzaste»."
L.OPT_ADD_LAST = "Añadir el último hechizo que lanzaste"
L.OPT_ADD_BUTTON = "Añadir"
L.OPT_ADD_LAST_TT = "Lanza una vez el DoT que falta (a un muñeco, por ejemplo) y pulsa este botón."
L.OPT_ADD_NONE = "Aún no has lanzado ningún hechizo en esta sesión."
L.OPT_REMOVE = "Quitar un DoT añadido"
L.OPT_REMOVE_TT = "Solo los DoTs que añadiste tú."
L.OPT_REMOVE_NONE = "Elige..."
L.OPT_SECTION_TOOLS = "Soporte"
L.OPT_DEBUG = "Diagnóstico para soporte"
L.OPT_DEBUG_BUTTON = "Escribir"
L.OPT_DEBUG_TT = "Escribe en el chat lo necesario para informar de un problema (lo mismo que /dotletal debug)."
L.OPT_RESET = "Restablecer todas las opciones"
L.OPT_RESET_BUTTON = "Restablecer"
L.OPT_RESET_TT = "Vuelve a los valores por defecto todas las opciones, también los DoTs que añadiste."
L.OPT_RESET_CONFIRM = "¿Restablecer todas las opciones de DoTLetal, también los DoTs que añadiste?"
