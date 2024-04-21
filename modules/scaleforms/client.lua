--- @class SD.Scaleforms
SD.Scaleforms = {}

--- Load a standard scaleform.
-- @param name string The name of the scaleform movie.
-- @return scaleform The loaded scaleform handle.
SD.Scaleforms.LoadMovie = function(name)
    local scaleform = RequestScaleformMovie(name)
    while not HasScaleformMovieLoaded(scaleform) do Wait(0); end
    return scaleform
end

--- Load an interactive scaleform.
-- @param name string The name of the interactive scaleform movie.
-- @return scaleform The loaded scaleform handle.
SD.Scaleforms.LoadInteractive = function(name)
    local scaleform = RequestScaleformMovieInteractive(name)
    while not HasScaleformMovieLoaded(scaleform) do Wait(0); end
    return scaleform
end

--- Unload a scaleform movie.
-- @param scaleform The scaleform handle to unload.
SD.Scaleforms.UnloadMovie = function(scaleform)
    SetScaleformMovieAsNoLongerNeeded(scaleform)
end

--- Load additional text for scaleforms.
-- @param gxt string The GXT entry.
-- @param count number The number of additional texts to load.
SD.Scaleforms.LoadAdditionalText = function(gxt, count)
    for i = 0, count, 1 do
        if not HasThisAdditionalTextLoaded(gxt, i) then
            ClearAdditionalText(i, true)
            RequestAdditionalText(gxt, i)
            while not HasThisAdditionalTextLoaded(gxt, i) do Wait(0); end
        end
    end
end

--- Set labels on a scaleform movie.
-- @param scaleform The scaleform handle.
-- @param labels table A list of labels to set.
SD.Scaleforms.SetLabels = function(scaleform, labels)
    PushScaleformMovieFunction(scaleform, "SET_LABELS")
    for _, txt in ipairs(labels) do
        BeginTextCommandScaleformString(txt)
        EndTextCommandScaleformString()
    end
    PopScaleformMovieFunctionVoid()
end

--- Generic method for pushing multiple parameters to a scaleform function.
-- @param scaleform The scaleform handle.
-- @param method string The scaleform method name.
-- @param ... Various parameters of mixed types.
SD.Scaleforms.PopMulti = function(scaleform, method, ...)
    PushScaleformMovieFunction(scaleform, method)
    for _, v in pairs({...}) do
        local trueType = SD.Scaleforms.TrueType(v)
        if trueType == "string" then      
            PushScaleformMovieFunctionParameterString(v)
        elseif trueType == "boolean" then
            PushScaleformMovieFunctionParameterBool(v)
        elseif trueType == "int" then
            PushScaleformMovieFunctionParameterInt(v)
        elseif trueType == "float" then
            PushScaleformMovieFunctionParameterFloat(v)
        end
    end
    PopScaleformMovieFunctionVoid()
end

--- Push a floating-point value to a scaleform function.
-- @param scaleform The scaleform handle.
-- @param method string The scaleform method name.
-- @param val float The float value to push.
function SD.Scaleforms.PopFloat(scaleform, method, val)
    PushScaleformMovieFunction(scaleform, method)
    PushScaleformMovieFunctionParameterFloat(val)
    PopScaleformMovieFunctionVoid()
end

--- Push an integer value to a scaleform function.
-- @param scaleform The scaleform handle.
-- @param method string The scaleform method name.
-- @param val int The integer value to push.
SD.Scaleforms.PopInt = function(scaleform, method, val)
    PushScaleformMovieFunction(scaleform, method)
    PushScaleformMovieFunctionParameterInt(val)
    PopScaleformMovieFunctionVoid()
end

--- Push a boolean value to a scaleform function.
-- @param scaleform The scaleform handle.
-- @param method string The scaleform method name.
-- @param val bool The boolean value to push.
SD.Scaleforms.PopBool = function(scaleform, method, val)
    PushScaleformMovieFunction(scaleform, method)
    PushScaleformMovieFunctionParameterBool(val)
    PopScaleformMovieFunctionVoid()
end

--- Call a scaleform function and return the handle for the return value.
-- @param scaleform The scaleform handle.
-- @param method string The scaleform method name.
-- @return ret The return handle for further processing.
function SD.Scaleforms.PopRet(scaleform, method)
    PushScaleformMovieFunction(scaleform, method)
    return PopScaleformMovieFunction()
end

--- Call a scaleform function without expecting any return.
-- @param scaleform The scaleform handle.
-- @param method string The scaleform method name.
function SD.Scaleforms.PopVoid(scaleform, method)
    PushScaleformMovieFunction(scaleform, method)
    PopScaleformMovieFunctionVoid()
end

--- Retrieve a boolean result from a scaleform return handle.
-- @param ret The return handle.
-- @return bool The boolean result.
SD.Scaleforms.RetBool = function(ret)
    return GetScaleformMovieFunctionReturnBool(ret)
end

--- Retrieve an integer result from a scaleform return handle.
-- @param ret The return handle.
-- @return int The integer result.
SD.Scaleforms.RetInt = function(ret)
    return GetScaleformMovieFunctionReturnInt(ret)
end

--- Determines the true type of a value, enhancing Lua's native type identification.
-- @param val The value to determine the type of.
-- @return string The determined type ("string", "boolean", "int", or "float").
SD.Scaleforms.TrueType = function(val)
    if type(val) ~= "number" then return type(val) end

    if string.find(tostring(val), '.') then 
        return "float"
    else
        return "int"
    end
end

return SD.Scaleforms
