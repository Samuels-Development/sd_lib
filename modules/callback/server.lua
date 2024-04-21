--- @class SD.Callback
SD.Callback = {}

local events = {}
local cbEvent = ('__sd_cb_%s')

--- Registers a network event and associated callback.
-- @param eventName string The event name to listen for.
-- @param callback function The callback to execute when the event is triggered.
local function registerNetEvent(eventName, callback)
    RegisterNetEvent(cbEvent:format(eventName), callback)
end

registerNetEvent('sd_lib', function(key, ...)
    local cb = events[key]
    return cb and cb(...)
end)

--- Handles the response from a callback and ensures any script errors are cleanly logged.
-- @param success boolean Whether the call was successful.
-- @param result any The result of the call, if successful.
-- @param ... any Additional results.
-- @return any The processed result, or false if an error occurred.
local function callbackResponse(success, result, ...)
    if not success then
        if result then
            return print(('^1SCRIPT ERROR: %s^0\n%s'):format(result, Citizen.InvokeNative(`FORMAT_STACK_TRACE` & 0xFFFFFFFF, nil, 0, Citizen.ResultAsString()) or ''))
        end
        return false
    end

    return result, ...
end

local pcall = pcall

--- Registers an event handler and callback function to respond to client requests.
-- @param name string The name of the event.
-- @param cb function The callback function to register.
function SD.Callback.Register(name, cb)
    RegisterNetEvent(cbEvent:format(name), function(resource, key, ...)
        TriggerClientEvent(cbEvent:format(resource), source, key, callbackResponse(pcall(cb, source, ...)))
    end)
end

return SD.Callback