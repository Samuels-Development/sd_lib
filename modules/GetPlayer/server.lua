--- Dynamically selects and returns the appropriate function for retrieving a player object
--- based on the configured framework. This approach abstracts framework-specific calls
--- into a unified SD interface, facilitating a clean and maintainable way to interact
--- with player objects across different frameworks.
----@return function A function that, when called with a player's server ID, returns the corresponding player object.
local GetPlayer = function()
    if Framework == 'esx' then
        return function(source)
            return ESX.GetPlayerFromId(source)
        end
    elseif Framework == 'qb' then
        return function(source)
            return QBCore.Functions.GetPlayer(source)
        end
    elseif Framework == 'qbx' then
        return function(source)
            return exports.qbx_core:GetPlayer(source)
        end
    else
        -- Fallback function for unsupported frameworks. Logs an error message.
        return function(source)
            error(string.format("Unsupported framework. Unable to retrieve player object for source: %s", source))
            return nil
        end
    end
end

-- Assign the dynamically selected function to SD.GetPlayer.
local GetPlayerFromId = GetPlayer()

--- Retrieves a player object using a server ID, abstracting framework-specific retrieval logic.
--- This function serves as a wrapper that calls a pre-defined function based on the current game framework,
--- optimized for performance by determining the appropriate function during script initialization.
----@param source number The server ID of the player to retrieve.
----@return Player|nil Returns the player object if found; returns nil if the player is not found or if an error occurs.
SD.GetPlayer = function(source)
    return GetPlayerFromId(source)
end

return SD.GetPlayer