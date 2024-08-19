--- Dynamically selects and returns the appropriate function for retrieving all online players
--- based on the configured framework. This abstracts framework-specific calls into a unified
--- SD interface, making the process of getting online players straightforward and consistent
--- across different frameworks.
----@return function A function that returns a table of all online players when called.
local GetPlayers = function()
    if Framework == 'esx' then
        return function()
            return ESX.GetExtendedPlayers()
        end
    elseif Framework == 'qb' then
        return function()
            return QBCore.Functions.GetPlayers()
        end
    else
        return function()
            error("Unsupported framework. Unable to retrieve list of online players.")
            return {}
        end
    end
end

-- Assign the dynamically selected function to SD.GetPlayers.
local GetAllPlayers = GetPlayers()

SD.GetPlayers = function(source)
    return GetAllPlayers()
end

return SD.GetPlayers