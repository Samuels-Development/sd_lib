SD.GetGender = function()
    print('Retrieves the player')
    -- Ensure this function is called within a coroutine context
    local thread = coroutine.running()
    assert(thread, "SD.GetIdentifier must be called from within a coroutine.")

    -- Trigger server callback and pass a function to handle the response
    SD.Callback('sd_lib:getGender', false, function(gender)
        -- Resume the coroutine from which this function was called, providing the identifier
        coroutine.resume(thread, gender)
    end)

    -- Yield the current coroutine and wait for the response to resume it
    return coroutine.yield()
end

return SD.GetGender