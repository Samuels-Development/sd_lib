---@class SD.Name
SD.Name = {}

-- Internal function to select the appropriate method for retrieving full name based on the framework.
local GetFullName = function()
    if Framework == 'esx' then
        return function(player)
            return player.get('firstName') .. ' ' .. player.get('lastName')
        end
    elseif Framework == 'qb' then
        return function(player)
            if player.PlayerData and player.PlayerData.charinfo then
                return player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
            end
        end
    else
        return function()
            error(string.format("Unsupported framework: %s", Framework))
        end
    end
end

local GetPlayerFullName = GetFullName()

-- Internal function to select the appropriate method for retrieving first name.
local GetFirstName = function()
    if Framework == 'esx' then
        return function(player)
            return player.get('firstName')
        end
    elseif Framework == 'qb' then
        return function(player)
            if player.PlayerData and player.PlayerData.charinfo then
                return player.PlayerData.charinfo.firstname
            end
        end
    else
        return function()
            error(string.format("Unsupported framework: %s", Framework))
        end
    end
end

local GetPlayerFirstName = GetFirstName()

-- Internal function to select the appropriate method for retrieving last name.
local GetLastName = function()
    if Framework == 'esx' then
        return function(player)
            return player.get('lastName')
        end
    elseif Framework == 'qb' then
        return function(player)
            if player.PlayerData and player.PlayerData.charinfo then
                return player.PlayerData.charinfo.lastname
            end
        end
    else
        return function()
            error(string.format("Unsupported framework: %s", Framework))
        end
    end
end

local GetPlayerLastName = GetLastName()

--- GetFullName retrieves the full name of a player based on the active framework.
---@param source number The player's server ID.
---@return string|nil The full name of the player if available, or nil if not found or unsupported framework.
SD.Name.GetFullName = function(source)
    local player = SD.GetPlayer(source)
    if not player then error(string.format("Player not found for source: %s", tostring(source))) end
    return GetPlayerFullName(player)
end

--- GetFirstName retrieves the first name of a player based on the active framework.
---@param source number The player's server ID.
---@return string|nil The first name of the player if available, or nil if not found.
SD.Name.GetFirstName = function(source)
    local player = SD.GetPlayer(source)
    if not player then error(string.format("Player not found for source: %s", tostring(source))) end
    return GetPlayerFirstName(player)
end

--- GetLastName retrieves the last name of a player based on the active framework.
---@param source number The player's server ID.
---@return string|nil The last name of the player if available, or nil if not found.
SD.Name.GetLastName = function(source)
    local player = SD.GetPlayer(source)
    if not player then error(string.format("Player not found for source: %s", tostring(source))) end
    return GetPlayerLastName(player)
end

return SD.Name