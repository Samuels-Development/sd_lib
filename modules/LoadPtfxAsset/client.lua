--- Loads a particle effects asset into the game with validations and timeout handling using SD.AwaitLoad.
---@param asset The particle effects asset dictionary name to be loaded.
-- @async
SD.LoadPtfxAsset = function(asset)
    if type(asset) ~= "string" then error("Asset identifier must be a string.") end

    RequestNamedPtfxAsset(asset)

    -- Check coroutine yieldability to decide on wait approach.
    if not coroutine.isyieldable() then return asset end

    -- Use SD.AwaitLoad for asynchronous wait with timeout.
    SD.AwaitLoad(function()
        if HasNamedPtfxAssetLoaded(asset) then 
            return true 
        end
    end, ("Failed to load particle effects asset '%s'"):format(asset), 5000)

    -- Return the asset for potential further use, indicating it's now loaded.
    return asset
end

return SD.LoadPtfxAsset
