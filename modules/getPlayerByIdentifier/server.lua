-- Internal function to select the appropriate method for retrieving a player by identifier based on the framework.
local GetPlayerByIdent = function()
    if Framework == 'qb' then
        -- QB-Core logic for getting a player by identifier
        return function(identifier)
            local player = QBCore.Functions.GetPlayerByCitizenId(identifier)
            if player and player.PlayerData then
                return Framework.GetPlayer(player.PlayerData.source)
            end
            return nil -- Return nil if no player is found
        end
    elseif Framework == 'esx' then
        -- ESX logic for getting a player by identifier
        return function(identifier)
            local player = ESX.GetPlayerFromIdentifier(identifier)
            if player then
                return Framework.GetPlayer(player.source)
            end
            return nil -- Return nil if no player is found
        end
    else
        -- Fallback for unsupported frameworks
        return function(identifier)
            error(string.format("Unsupported framework: %s", Framework))
        end
    end
end

local GetPlayerByIdentifier = GetPlayerByIdent()

-- This function assigns the ability to retrieve a player by identifier to the SD namespace.
-- It abstracts the retrieval process, depending on the framework used.
---@returns a players source for the given identifier
SD.GetPlayerByIdentifier = function()
    local identifier = SD.GetIdentifier(source)
    return GetPlayerByIdentifier(identifier)
end

return SD.GetPlayerByIdentifier