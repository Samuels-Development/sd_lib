--- Selects and returns the most appropriate function for getting a player's identifier.
-- This function checks the active server framework (e.g., ESX, QBCore) to determine the best method for retrieving player identifiers.
-- If no known framework is detected, it returns nil.
---@return function|nil A function tailored to retrieve a player's identifier using the determined method, or nil if no known framework is detected.
local Identifier = function()
    if Framework == 'esx' then
        -- For ESX, directly return the player's primary identifier.
        return function(player)
            return player.identifier
        end
    elseif Framework == 'qb' or Framework == 'qbx' then
        -- For QBCore, return the player's citizenid.
        return function(player)
            return player.PlayerData.citizenid
        end
    else
        -- Return nil if no known framework is detected.
        return nil
    end
end

local GetIdentifier = Identifier()

--- Retrieve the unique identifier for a player.
-- This function is used to get a player's identifier using the 'source' provided.
-- The method to determine the identifier is set during the initialization of the script.
-- @param source any The input used to identify and retrieve the player's unique identifier.
SD.GetIdentifier = function(source)
    local player = SD.GetPlayer(source)
    if player then return GetIdentifier(player) end
end

return SD.GetIdentifier