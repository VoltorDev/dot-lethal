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
