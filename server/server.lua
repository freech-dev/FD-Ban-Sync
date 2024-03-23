local localBans = {}

-------------------
-- SERVER EVENTS --
-------------------

AddEventHandler('playerConnecting', function(name, setKickReason)
    if Config.DebugMode then print('[Freech Framework] Player Connecting Called') end
    local src = source
    local identifiers = ExtractIdentifiers(src)
    local identifiers = ExtractIdentifiers(source)
    local discordId = identifiers.discord:gsub("discord:", "")  -- This line removes the "discord:" part from the discord ID

    

    if not hasDiscord then
        DropPlayer(src, "[Freech Framework] Discord identifier not found please relog")
        CancelEvent()
        if Config.DebugMode then print("[Freech Framework] Kicked Player " .. name .. " ID: " .. src .. " for no discord identifier") end
    else
        LoadPermissions(src)
        if Config.DebugMode then print("[Freech Framework] Permissions Loaded for " .. name .. " ID: " .. src) end
    end
end)

-------------
-- THREADS --
------------- 

Citizen.CreateThread(function()
    while true do Wait(10000)
        
    end 
end)

---------------
-- FUNCTIONS --
---------------

function ExtractIdentifiers(src)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
        xbl = "",
        live = ""
    }
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "ip") then
            identifiers.ip = id
        elseif string.find(id, "discord") then
            identifiers.discord = id
        elseif string.find(id, "license") then
            identifiers.license = id
        elseif string.find(id, "xbl") then
            identifiers.xbl = id
        elseif string.find(id, "live") then
            identifiers.live = id
        end
    end
    return identifiers
end