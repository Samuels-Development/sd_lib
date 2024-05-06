--- Retrieves the player's identifier through a server callback, requiring coroutine context.
-- This function asynchronously fetches the player's identifier from the server by utilizing a server callback mechanism.
-- It's designed to be called within a coroutine to allow for synchronous-style programming in what is fundamentally
-- an asynchronous operation. The function uses the coroutine's yielding and resuming capabilities to wait for the server's
-- response without blocking the main execution thread. This approach facilitates cleaner and more readable code for
-- operations that depend on server-side data.
-- Note: It must be invoked from within a coroutine; otherwise, it will raise an error due to the assertion check.
---@return string The player's identifier retrieved from the server.
SD.GetIdentifier = function()
    -- Ensure this function is called within a coroutine context
    local thread = coroutine.running()
    assert(thread, "SD.GetIdentifier must be called from within a coroutine.")

    -- Trigger server callback and pass a function to handle the response
    SD.Callback('sd_lib:getIdentifier', false, function(identifier)
        -- Resume the coroutine from which this function was called, providing the identifier
        -- print('Resuming coroutine with identifier:', identifier)
        coroutine.resume(thread, identifier)
    end)

    -- Yield the current coroutine and wait for the response to resume it
    return coroutine.yield()
end

return SD.GetIdentifier 