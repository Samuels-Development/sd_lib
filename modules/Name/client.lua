---@class SD.Name
SD.Name = {}

--- GetFullName retrieves the full name of a player by invoking an asynchronous callback.
--- The function must be called from within a coroutine; it will yield until the callback resumes it.
---@return string fullName The full name of the player when the callback returns.
SD.Name.GetFullName = function()
    local thread = coroutine.running()
    assert(thread, "SD.Name.GetFullName must be called from within a coroutine")

    SD.Callback("sd_lib:getFullName", false, function(fullName)
        coroutine.resume(thread, fullName)
    end)

    return coroutine.yield()
end

--- GetFirstName retrieves the first name of a player by invoking an asynchronous callback.
--- The function must be called from within a coroutine; it will yield until the callback resumes it.
---@return string firstName The first name of the player when the callback returns.
SD.Name.GetFirstName = function()
    local thread = coroutine.running()
    assert(thread, "SD.Name.GetFirstName must be called from within a coroutine")

    SD.Callback("sd_lib:getFirstName", false, function(firstName)
        coroutine.resume(thread, firstName)
    end)

    return coroutine.yield()
end

--- GetLastName retrieves the last name of a player by invoking an asynchronous callback.
--- The function must be called from within a coroutine; it will yield until the callback resumes it.
---@return string lastName The last name of the player when the callback returns.
SD.Name.GetLastName = function()
    local thread = coroutine.running()
    assert(thread, "SD.Name.GetLastName must be called from within a coroutine")

    SD.Callback("sd_lib:getLastName", false, function(lastName)
        coroutine.resume(thread, lastName)
    end)

    return coroutine.yield()
end

return SD.Name







