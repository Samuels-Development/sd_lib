if GetResourceState('qb-core') == 'started' then Framework = 'qb' elseif GetResourceState('es_extended') == 'started' then Framework = 'esx' end

-- Check if the 'es_extended' resource is started
if Framework == 'esx' then
    -- Triggered when a player has loaded into the game
    RegisterNetEvent('esx:playerLoaded', function(xPlayer)
        -- Trigger 'onPlayerLoaded' event for custom script
        TriggerEvent('sd_bridge:onPlayerLoaded')
        PlayerLoaded = true
    end)
    
    -- Triggered when a player logs out
    RegisterNetEvent('esx:onPlayerLogout', function()
        -- Set PlayerLoaded to false
        PlayerLoaded = false
    end)

    -- Triggered when a resource starts
    AddEventHandler('onResourceStart', function(resourceName)
        -- Check if the current resource is 'es_extended' and if the player has loaded
        if GetCurrentResourceName() ~= resourceName or not ESX.PlayerLoaded then 
            return 
        end

        PlayerLoaded = true
    end)
    
-- Check if 'qb-core' resource is started
elseif Framework == 'qb' then    
    -- Add a state bag change handler for 'isLoggedIn' state
    AddStateBagChangeHandler('isLoggedIn', '', function(_bagName, _key, value, _reserved, _replicated)
        PlayerLoaded = value
    end)
    
    -- Register event for player loaded
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        TriggerEvent('sd_bridge:onPlayerLoaded')
    end)
    
    -- Add an event handler for resource start
    AddEventHandler('onResourceStart', function(resourceName)
        -- Check if the resource name is the same as the current resource name and the player is logged in
        if GetCurrentResourceName() ~= resourceName or not LocalPlayer.state.isLoggedIn then
            return
        end
        -- Get the player data and set the PlayerLoaded variable to true
        PlayerLoaded = true
    end)
    
else
    -- If neither 'es_extended' nor 'qb-core' is running, print error
    print("Error: Neither ESX nor QBCore resources are running!")
    return
end

--- Event handler to display notifications to the player.
-- Listens for an event and displays a notification using the configured method upon receiving it.
RegisterNetEvent('sd_bridge:notification', function(msg, type)
    -- Invoke the ShowNotification function with the message and type received from the event.
    SD.ShowNotification(msg, type)
end)

--- Event handler to create logs in the system.
-- Listens for an event and logs information using the configured logging method upon receiving it.
RegisterNetEvent('sd_lib:createLog', function(name, title, color, message, tagEveryone)
    -- Invoke the Log function with the parameters received from the event.
    -- Parameters:
    -- name: A string specifying the logger name or source of the log.
    -- title: A string representing the title or summary of the log entry.
    -- color: A numeric or string value specifying the color associated with the log entry, typically used for categorization or priority.
    -- message: A string containing the detailed message or description for the log entry.
    -- tagEveryone: A boolean indicating whether to notify all users associated with the log event, useful for urgent or important logs.
    SD.Log(name, title, color, message, tagEveryone)
end)