local addonName, ns = ...
local L = ns.L

-- Volcado para soporte: todo lo necesario para reproducir un problema en otro cliente.
function ns:PrintDiagnostics()
    local client = self.Client
    self:Print(L.DEBUG_HEADER)
    print(("  %s %s | %s"):format(addonName, self.version, GetLocale()))
    print("  " .. client.Describe())
    print(
        ("  GameMode=%s ForeverExperiencePreset=%s"):format(
            tostring(client.GetGameModeName()),
            tostring(client.GetExperiencePresetName())
        )
    )
    print("  HasSecretRestrictions=" .. tostring(client.HasSecretRestrictions()))
    if Enum.AddOnRestrictionType then
        local active = {}
        for name, value in pairs(Enum.AddOnRestrictionType) do
            if self.IsRestrictionActive(value) then
                active[#active + 1] = name
            end
        end
        print("  Restricciones activas: " .. (#active > 0 and table.concat(active, ", ") or "ninguna"))
    end
    print(("  InCombatLockdown=%s"):format(tostring(InCombatLockdown())))
    for _, warning in ipairs(client.GetWarnings()) do
        print("  AVISO: " .. warning)
    end
end

SLASH_DOTLETAL1 = "/dotletal"
SlashCmdList.DOTLETAL = function(message)
    local raw, argument = message:match("^(%S*)%s*(.-)%s*$")
    -- lower() de Lua depende del locale de C y puede alterar los bytes de "ñ": se compara también
    -- la palabra tal cual.
    local command = raw:lower()
    if command == "" or command == "config" then
        ns:OpenSettings()
    elseif command == "debug" then
        ns:PrintDiagnostics()
    elseif command == "mover" or command == "move" then
        ns.db.locked = not ns.db.locked
        ns:ApplySettings()
        ns:Print(ns.db.locked and L.LOCKED or L.UNLOCKED)
    elseif command == "lista" or command == "list" then
        ns:Print(L.KNOWN_HEADER)
        for _, line in ipairs(ns.Dots.Known()) do
            print("  " .. line)
        end
    elseif raw == "añadir" or command == "anadir" or command == "add" then
        local period, name = argument:match("^(%d+%.?%d*)%s+(.+)$")
        period = tonumber(period)
        if not period or period <= 0 then
            ns:Print(L.ADD_USAGE)
        else
            ns.db.custom[name] = period
            ns:ApplySettings()
            ns:Print(L.ADDED:format(name, period))
        end
    elseif command == "quitar" or command == "remove" then
        if ns.db.custom[argument] then
            ns.db.custom[argument] = nil
            ns:ApplySettings()
            ns:Print(L.REMOVED:format(argument))
        else
            ns:Print(L.NOT_CUSTOM:format(argument))
        end
    elseif command == "traza" or command == "trace" then
        ns.db.debug = not ns.db.debug
        ns:Print(ns.db.debug and L.TRACE_ON or L.TRACE_OFF)
    elseif command == "reset" then
        if argument == "confirm" or argument == "confirmar" then
            ns:ResetDB()
            ns:ApplySettings()
            ns:Print(L.RESET_DONE)
        else
            ns:Print(L.RESET_CONFIRM)
        end
    else
        ns:Print(L.SLASH_HELP)
    end
end
