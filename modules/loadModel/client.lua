--- Loads a model into the game with advanced validations and timeout handling.
-- This function handles the loading of game models with additional checks for parameter validity, type conversion,
-- and uses a custom wait function to manage asynchronous loading with a timeout.
-- @param model The model identifier (could be a hash key, name, or number) to be loaded.
SD.LoadModel = function(model)
    if type(model) ~= 'number' then model = joaat(model) end

    -- Check if the model exists and is not already loaded, otherwise skip loading.
    if not HasModelLoaded(model) and IsModelInCdimage(model) then
        RequestModel(model)

        -- Check coroutine yieldability to decide on wait approach.
        if not coroutine.isyieldable() then return model end

        -- Use SD.AwaitLoad for asynchronous wait with timeout.
        return SD.AwaitLoad(function()
            if HasModelLoaded(model) then return model end
        end, ("Failed to load model '%s'"):format(model), 5000)
    end

    return model
end

return SD.LoadModel