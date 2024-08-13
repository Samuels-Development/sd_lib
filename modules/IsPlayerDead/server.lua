--- Dynamically selects and returns the appropriate function for retrieving a player object
--- based on the configured framework. This approach abstracts framework-specific calls
--- into a unified SD interface, facilitating a clean and maintainable way to interact
--- with player objects across different frameworks.
---@return function A function that, when called with a player's server ID, returns the corresponding player object.
local IsPlayerDead = function()
    if Framework == 'qb' or Framework == 'qbx' then
        return function(source)
            local Player = SD.GetPlayer(source)
            return (Player.PlayerData.metadata['isdead'] or Player.PlayerData.metadata['inlaststand'])
        end
    else
        -- Fallback function for unsupported frameworks. Logs an error message.
        return function(source)
            error(string.format("Unsupported framework. Unable to retrieve player status for source: %s", source))
            return nil
        end
    end
end

-- Assign the dynamically selected function to isPlayerDead.
local isPlayerDeath = IsPlayerDead()

SD.IsPlayerDead = function(source)
    return isPlayerDeath(source)
end

return SD.IsPlayerDead



