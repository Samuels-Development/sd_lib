-- Internal function to select the appropriate method for retrieving a player by identifier based on the framework.
local GetPlayerByIdent = function()
    if Framework == 'qb' then
        -- QB-Core logic for getting a player by identifier
        return function(identifier)
            return SD.GetPlayer(QBCore.Functions.GetPlayerByCitizenId(identifier)?.PlayerData?.source)
        end
    elseif Framework == 'esx' then
        -- ESX logic for getting a player by identifier
        return function(identifier)
            return SD.GetPlayer(ESX.GetPlayerFromIdentifier(identifier)?.source)
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
SD.GetPlayerByIdentifier = function(identifier)
    print('identifier:', identifier)
    return GetPlayerByIdentifier(identifier)
end

return SD.GetPlayerByIdentifier