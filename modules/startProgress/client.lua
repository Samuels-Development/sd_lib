--- Selects and returns the most appropriate function for starting a progress bar.
-- This function determines the best method for displaying progress bars based on the current game setup
-- (e.g., availability of ox_lib and configuration settings) or the active framework (ESX, QBCore).
-- @return function A function tailored to start progress bars using the determined method.
local ProgressBar = function()
    -- Return a function tailored to the active framework's method of showing progress bars
    if Framework == 'esx' then
        return function(identifier, label, duration, completed, notfinished)
            exports.esx_progressbar:Progressbar(identifier, label, duration, {
                FreezePlayer = true,
                onFinish = completed
            })
        end
    elseif Framework == 'qb' then
        return function(identifier, label, duration, completed, notfinished)
            QBCore.Functions.Progressbar(identifier, label, duration, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, completed, notfinished)
        end
    end
    
    -- Fallback function in case no method is configured
    return function(identifier, label, duration, completed, notfinished)
        error(string.format("No progress bar method configured. Unable to start progress for: %s", label))
        -- Optionally, call notfinished callback here if needed
    end
end

--- The chosen method for starting a progress bar, determined at the time of script initialization.
SD.StartProgress = ProgressBar()

return SD.StartProgress