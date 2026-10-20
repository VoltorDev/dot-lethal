local _, ns = ...

-- Tabla de textos: si falta una clave, devuelve la propia clave en vez de nil
-- (un texto sin traducir se ve, pero no rompe el addon).
local L = setmetatable({}, {
    __index = function(_, key)
        return key
    end,
})
ns.L = L

L.ADDON_TITLE = "DoTLetal"
L.LOADED = "loaded. Type /dotletal for options."
L.SLASH_HELP =
    "Commands: /dotletal [config | move | list | add <seconds> <spell> | remove <spell> | trace | debug | reset]"
L.ERR_COMBAT = "Not available in combat; try again when combat ends."
L.RESET_CONFIRM = "Type /dotletal reset confirm to restore the defaults."
L.RESET_DONE = "Settings restored to defaults."
L.COMPARTMENT_TOOLTIP = "Click to open the options."

L.OPT_ENABLED = "Enable"
L.OPT_ENABLED_TT = "Shows or hides everything this addon draws."
L.OPT_SCALE = "Scale"
L.OPT_SCALE_TT = "Size of the addon frames."
L.OPT_MODE = "Mode"
L.OPT_MODE_TT = "Classic shows DoT damage, time and target health; Compact, only the square and the bar."
L.MODE_CLASSIC = "Classic"
L.MODE_COMPACT = "Compact"

L.DEBUG_HEADER = "Diagnostics (paste this when reporting a problem):"

L.DOTS_LEFT = "DoTs %s · %.0fs"
L.LOCKED = "Frame locked. It shows only while your DoTs are ticking."
L.UNLOCKED = "Frame unlocked: drag it with the left button. /dotletal move to lock it."
L.KNOWN_HEADER = "DoTs it tracks (name and seconds between ticks):"
L.ADD_USAGE = "Usage: /dotletal add <seconds between ticks> <exact spell name>"
L.ADDED = "Added %s (one tick every %ss)."
L.REMOVED = "Removed %s."
L.NOT_CUSTOM = "%s is not in your added list."
L.TRACE_ON = "Trace on."
L.TRACE_OFF = "Trace off."
