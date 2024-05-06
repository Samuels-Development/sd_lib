--- Selects and returns the most appropriate function for getting a player's identifier.
-- This function checks the active server framework (e.g., ESX, QBCore) to determine the best method for retrieving player identifiers.
-- If no known framework is detected, it defaults to using the native GetPlayerIdentifiers function.
---@return function A function tailored to retrieve a player's identifier using the determined method.
local Identifier = function()
    if Framework == 'esx' then
        -- For ESX, directly return the player's primary identifier.
        return function(source)
            local player = SD.GetPlayer(source)
            return player.identifier
        end
    elseif Framework == 'qb' or Framework == 'qbx' then
        -- For QBCore, return the player's citizenid.
        return function(source)
            local player = SD.GetPlayer(source)
            return player.PlayerData.citizenid
        end
    else
        -- Fallback method using GetPlayerIdentifiers for unsupported frameworks.
        return function(source)
            local identifiers = GetPlayerIdentifiers(source)
            return identifiers[1]
        end
    end
end

local GetIdentifier = Identifier()

--- Retrieve the unique identifier for a player.
-- This function is used to get a player's identifier using the 'source' provided.
-- The method to determine the identifier is set during the initialization of the script.
-- @param source any The input used to identify and retrieve the player's unique identifier.
SD.GetIdentifier = function(source)
    return GetIdentifier(source)
end

return SD.GetIdentifier