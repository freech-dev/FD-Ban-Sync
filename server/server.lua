---------------------
-- DISCORD LOGGING --
---------------------

local function ExtractIdentifiers(playerId)
    local identifiers = {}

    for i = 0, GetNumPlayerIdentifiers(playerId) - 1 do
        local id = GetPlayerIdentifier(playerId, i)

        if string.find(id, "steam:") then
            identifiers['steam'] = id
        elseif string.find(id, "discord:") then
            identifiers['discord'] = id
        elseif string.find(id, "license:") then
            identifiers['license'] = id
        elseif string.find(id, "license2:") then
            identifiers['license2'] = id
        end
    end

    return identifiers
end

-------------------
-- SERVER EVENTS --
-------------------

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    if Config.DebugMode then print('[Freech Ban Sync] Player Connecting Called') end
    local src = source

    deferrals.defer()
    Wait(0)
    deferrals.update(string.format('[Freech Ban Sync] Checking %s', name))

    local discordId = GetPlayerIdentifierByType(src, 'discord') and GetPlayerIdentifierByType(src, 'discord'):gsub('discord:', '') or false

    Wait(0)

    if not discordId then
        if Config.DebugMode then print("[Freech Ban Sync] Kicked Player " .. name .. " ID: " .. src .. " for no discord identifier") end
        deferrals.done("You need to have discord linked to join this server.")
    end

    hasDiscord, isBanned = CheckBan(discordId)

    if isBanned then 
        print("[Freech Ban Sync] Rejected Player " .. name .. " ID: " .. src .. " for being banned - Discord: " .. discordId)
        deferrals.done(Config.Setup.BanMessage)
        if Config.Setup.LogWebhook ~= "" then
            local embed = {
                color = '16711680',
                title = 'Player Banned',
                description = string.format('Player %s (Discord ID: %s) has been banned from the server.', name, discordId),
                fields = {
                    { name = "Reason", value = Config.Setup.BanMessage },
                    { name = "Identifiers", value = json.encode(ExtractIdentifiers(src)) },
                },
                footer = {
                    text = 'Date: ' .. os.date('%Y-%m-%d %H:%M:%S'),
                },
            }
            PerformHttpRequest(Config.Setup.LogWebhook, function(err, text, headers) end, 'POST', json.encode({ username = 'Server Bot', embeds = { embed } }), { ['Content-Type'] = 'application/json' })
        end
    else
        deferrals.done()
    end
end)

-------------
-- THREADS --
------------- 

-- Ban request thread removed as it was breaking will be added back soon

---------------
-- FUNCTIONS --
---------------

function CheckBan(userId)
    if Config.DebugMode then print('[Freech Ban Sync] CheckBan Called') end
    PerformHttpRequest(
        'https://discordapp.com/api/guilds/' .. Config.Setup.GuildId .. '/bans/' .. userId,
        function(err, responseCode, body)
            local isBanned = false
            if err == 200 then
                isBanned = true
            end
            if Config.DebugMode then print('[Freech Ban Sync] CheckBan Returned ' .. tostring(hasDiscord) .. ' - ' .. tostring(isBanned)) end
            return isBanned
        end,
        'GET',
        '',
        {['Authorization'] = 'Bot ' .. Config.Setup.BotToken,
        ['Content-Type'] = 'application/json'}
    )
end
