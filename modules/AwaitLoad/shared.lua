--- Waits for a specified condition to be met, with timeout management.
-- This function is designed to be generic and can be used in various scenarios where asynchronous waiting is required.
-- It asynchronously waits until a non-nil value is returned by the callback function, indicating that the specified
-- condition has been met. It incorporates timeout management to prevent infinite waiting.
-- @generic T : The expected return type upon successful condition check.
---@param callback fun(): T|nil A callback function that checks the desired condition. Should return a non-nil value once the condition is met.
---@param errorMessage string Optional error message to display upon timeout. Defaults to "Operation timed out".
---@param timeoutDuration number|nil Optional timeout in milliseconds. Defaults to 1000 ms. A nil value sets to default.
---@return T|nil Returns the value from the callback function if the condition is met within the timeout period, or throws an error if timed out.
-- @async
SD.AwaitLoad = function(callback, errorMessage, timeoutDuration)
    local defaultTimeout = 1000
    errorMessage = errorMessage or "Operation timed out"
    timeoutDuration = timeoutDuration or defaultTimeout

    local endTime = GetGameTimer() + timeoutDuration
    local result

    repeat
        Wait(0)
        result = callback()
        if result ~= nil then
            return result
        end
    until GetGameTimer() > endTime

    error(string.format("%s (after waiting %.2f seconds)", errorMessage, timeoutDuration / 1000), 2)
end

return SD.AwaitLoad