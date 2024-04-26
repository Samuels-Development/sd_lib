--- Dynamically selects and returns the appropriate function for retrieving a player's gender
--- based on the configured framework. This approach abstracts framework-specific calls
--- into a unified SD interface, facilitating a clean and maintainable way to interact
--- with player gender data across different frameworks.
----@return function A function that, when called with a player object, returns the corresponding gender as 'm' or 'f'.
local GetPlayerGender = function()
    if Framework == 'esx' then
        return function(player)
            return player.get("sex") or "Male"
        end
    elseif Framework == 'qb' or Framework == 'qbx' then
        return function(player)
            return player.PlayerData.charinfo.gender == 0 and 'Male' or 'Female'
        end
    else
        -- Fallback function for unsupported frameworks. Logs an error message.
        return function(player)
            error(string.format("Unsupported framework. Unable to retrieve gender for player: %s", player))
            return nil
        end
    end
end

-- Assign the dynamically selected function to SD.GetPlayerGender.
local GetGenderFromPlayer = GetPlayerGender()

--- Retrieves a player's gender using a player object, abstracting framework-specific retrieval logic.
--- This function serves as a wrapper that calls a pre-defined function based on the current game framework,
--- optimized for performance by determining the appropriate function during script initialization.
----@param player Player The player object to retrieve the gender from.
----@return string 'm' or 'f' Returns the gender of the player if found; returns nil if the player is not found or if an error occurs.
SD.GetPlayerGender = function(source)
    local player = SD.GetPlayer(source)
    return GetGenderFromPlayer(player)
end

return SD.GetPlayerGender