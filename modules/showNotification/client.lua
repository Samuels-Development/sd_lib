--- Selects and returns the most appropriate notification function based on the current game setup.
-- This function checks the available libraries and configurations to determine which notification method to use.
-- It then returns a function tailored to use that method for showing notifications.
-- @return function A function configured to show notifications using the determined method.
local Notification = function()
    -- Determine the framework and return a corresponding function for showing the notification.
    if Framework == 'esx' then
        return function(message, _)
            ESX.ShowNotification(message)
        end
    elseif Framework == 'qb' then
        return function(message, type)
            QBCore.Functions.Notify(message, type)
        end
    end

    -- As a fallback, return a function that does nothing or logs a warning/error.
    return function(message, type)
        error(string.format("Notification system not supported. Message was: %s, Type was: %s", message, type))
    end
end

--- The chosen method for showing notifications, determined at the time of script initialization.
local ShowNotification = Notification()

SD.ShowNotification = ShowNotification()

return SD.ShowNotification