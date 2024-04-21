--- Loads an animation dictionary into the game with validation and timeout.
-- Ensures that the animation dictionary is loaded into the game before proceeding, checking its validity
-- and applying a timeout mechanism to prevent infinite waiting. This function is crucial for operations
-- requiring animations to ensure smooth execution without runtime errors due to unloaded assets.
-- @param animDict string The animation dictionary name to be loaded.
-- @async
SD.LoadAnim = function(animDict)
    if type(animDict) ~= "string" then error("Animation dictionary identifier must be a string.") end

    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)

        -- Use sd.awaitLoad to wait for the animation dictionary to load with a timeout.
        SD.AwaitLoad(function()
            if HasAnimDictLoaded(animDict) then
                return true -- Return true indicating the dictionary is loaded.
            end
        end, ("Failed to load animation dictionary '%s'").format(animDict), 5000) -- 5000 ms timeout.
    end
end

return SD.LoadAnim