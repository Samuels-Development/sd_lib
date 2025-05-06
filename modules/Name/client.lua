SD.Name = {}

SD.Name.GetFullName = function()
    local thread = coroutine.running()
    assert(thread, "SD.Name.GetFullName must be called from within a coroutine")

    SD.Callback("sd_lib:getFullName", false, function(source)
        local result = SD.Name.GetFullName(source)
        coroutine.resume(thread, result)
    end)

    return coroutine.yield()
end

SD.Name.GetFirstName = function()
    local thread = coroutine.running()
    assert(thread, "SD.Name.GetFirstName must be called from within a coroutine")

    SD.Callback("sd_lib:getFirstName", false, function(source)
        local result = SD.Name.GetFirstName(source)
        coroutine.resume(thread, result)
    end)

    return coroutine.yield()
end

SD.Name.GetLastName = function()
    local thread = coroutine.running()
    assert(thread, "SD.Name.GetLastName must be called from within a coroutine")

    SD.Callback("sd_lib:getLastName", false, function(source)
        local result = SD.Name.GetLastName(source)
        coroutine.resume(thread, result)
    end)

    return coroutine.yield()
end

return SD.Name







