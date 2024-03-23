-------------------
-- SERVER EVENTS --
-------------------

AddEventHandler('playerConnecting', function(name, setKickReason)
    if Config.DebugMode then print('[Freech Ban Sync] Player Connecting Called') end
    local src = source
    local identifiers = ExtractIdentifiers(src)
    local identifiers = ExtractIdentifiers(source)
    local discordId = identifiers.discord:gsub("discord:", "")  -- This line removes the "discord:" part from the discord ID
    deferrals.defer()
    Wait(0)
    deferrals.update(string.format('[Freech Ban Sync] Checking %s', name))
    
    hasDiscord, isBanned = CheckBan(discordId)
    
    if not hasDiscord then
        DropPlayer(src, "[Freech Ban Sync] Discord identifier not found please relog")
        CancelEvent()
        if Config.DebugMode then print("[Freech Ban Sync] Kicked Player " .. name .. " ID: " .. src .. " for no discord identifier") end
    elseif isBanned then 
        DropPlayer(src, "[Freech Ban Sync] " .. Config.Setup.BanMessage)
        CancelEvent()
        if Config.DebugMode then print("[Freech Ban Sync] Kicked Player " .. name .. " ID: " .. src .. " for being banned") end
    elseif not isBanned then
        defferals.done('[Freech Ban Sync] You are not banned')
    end
end)

-------------
-- THREADS --
------------- 

Citizen.CreateThread(function()
    while true do Wait(10000)
        -- Check players in server if they are banned or not
    end 
end)

---------------
-- FUNCTIONS --
---------------

function CheckBan(userId)
    if Config.DebugMode then print('[Freech Ban Sync] CheckBan Called') end
    PerformHttpRequest(
        'https://discordapp.com/api/guilds/' .. Config.Setup.GuildId .. '/bans/' .. userId,
        function(err, responseCode, body)
            local hasDiscord = true
            local isBanned = false
            if err == 200 then
                isBanned = true
            elseif err == 404 then
                hasDiscord = false
            end
            if Config.DebugMode then print('[Freech Ban Sync] CheckBan Returned ' .. tostring(hasDiscord) .. ' - ' .. tostring(isBanned)) end
            return hasDiscord, isBanned
        end,
        'GET',
        '',
        {['Authorization'] = 'Bot ' .. Config.Setup.BotToken,
        ['Content-Type'] = 'application/json'}
    )
end

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