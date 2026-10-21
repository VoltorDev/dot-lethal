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
L.SLASH_HELP = "Commands: /dotletal [config | move | list | trace | debug | reset]"
L.ERR_COMBAT = "Not available in combat; try again when combat ends."
L.RESET_CONFIRM = "Type /dotletal reset confirm to restore the defaults."
L.RESET_DONE = "Settings restored to defaults."
L.COMPARTMENT_TOOLTIP = "Click to open the options."

L.OPT_ENABLED = "Enable"
L.OPT_ENABLED_TT = "Shows or hides everything this addon draws."
L.OPT_SCALE = "Scale"
L.OPT_SCALE_TT = "Size of the addon frames."
L.OPT_MODE = "Mode"
L.OPT_MODE_TT = "Classic lists each DoT with its time and damage per second; Compact shows only the totals."
L.MODE_CLASSIC = "Classic"
L.MODE_COMPACT = "Compact"

L.DEBUG_HEADER = "Diagnostics (paste this when reporting a problem):"

L.HEADER = "DoTs %s/s · %s left"
L.ROW = "%.0fs · %s/s"
L.OPT_TARGETFRAME = "Mark the target frame"
L.OPT_TARGETFRAME_TT = "On the target frame health bar: the health it will lose to your DoTs"
    .. " and a skull if they kill it."
L.OPT_NAMEPLATE = "Mark the target nameplate"
L.OPT_NAMEPLATE_TT = "The same on the nameplate of your target (Blizzard or Plater)."
L.LOCKED = "Frame locked. It shows only while your DoTs are ticking."
L.UNLOCKED = "Frame unlocked: drag it with the left button. /dotletal move to lock it."
L.KNOWN_HEADER = "Your DoTs it tracks (name and current seconds between ticks):"
L.TRACE_ON = "Trace on."
L.TRACE_OFF = "Trace off."

-- Options menu (Config.lua)
L.OPT_LOCKED = "Lock the panel"
L.OPT_LOCKED_TT = "Locked, the panel only shows while your DoTs tick. Unlocked, it shows sample data to drag it."
L.OPT_TRACE = "Trace"
L.OPT_TRACE_TT = "Debug messages in the chat, for example when a DoT description is not understood."
L.OPT_SECTION_DOTS = "Tracked DoTs"
L.OPT_LIST = "Tracked DoTs"
L.OPT_LIST_BUTTON = "List"
L.OPT_LIST_TT = "Prints in the chat your DoTs and their seconds between ticks with your talents and haste rules."
L.OPT_SECTION_TOOLS = "Support"
L.OPT_DEBUG = "Support diagnostics"
L.OPT_DEBUG_BUTTON = "Print"
L.OPT_DEBUG_TT = "Prints in the chat what is needed to report a problem (same as /dotletal debug)."
L.OPT_RESET = "Reset all options"
L.OPT_RESET_BUTTON = "Reset"
L.OPT_RESET_TT = "Puts every option back to the defaults."
L.OPT_RESET_CONFIRM = "Reset all DoTLetal options?"
