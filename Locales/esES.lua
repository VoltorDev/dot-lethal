local _, ns = ...

local locale = GetLocale()
if locale ~= "esES" and locale ~= "esMX" then
    return
end

local L = ns.L

L.LOADED = "cargado. Escribe /dotletal para ver las opciones."
L.SLASH_HELP = "Comandos: /dotletal [config | mover | lista | traza | debug | reset]"
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
L.KNOWN_HEADER = "Tus DoTs que sigue (nombre y segundos entre ticks ahora):"
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
L.OPT_LIST_TT = "Escribe en el chat tus DoTs y sus segundos entre ticks con tus talentos."
L.OPT_SECTION_TOOLS = "Soporte"
L.OPT_DEBUG = "Diagnóstico para soporte"
L.OPT_DEBUG_BUTTON = "Escribir"
L.OPT_DEBUG_TT = "Escribe en el chat lo necesario para informar de un problema (lo mismo que /dotletal debug)."
L.OPT_RESET = "Restablecer todas las opciones"
L.OPT_RESET_BUTTON = "Restablecer"
L.OPT_RESET_TT = "Vuelve a los valores por defecto todas las opciones."
L.OPT_RESET_CONFIRM = "¿Restablecer todas las opciones de DoTLetal?"
