--- @class SD.Callback
SD.Callback = {}

local events = {}
local timers = {}
local cbEvent = ('__sd_cb_%s')

--- Registers a network event and associates a callback.
-- @param eventName string The event name to listen for.
-- @param callback function The callback to execute when the event is triggered.
local function registerNetEvent(eventName, callback)
    RegisterNetEvent(cbEvent:format(eventName), callback)
end

registerNetEvent('sd_lib', function(key, ...)
    local cb = events[key]
    return cb and cb(...)
end)

--- Manages delay timers for events to prevent spamming or rapid calls.
-- @param event string The name of the event.
-- @param delay number | false A delay in milliseconds to enforce between activations, or false to ignore timing.
-- @return boolean True if the event can proceed, false if it is being throttled.
local function eventTimer(event, delay)
    if delay and type(delay) == 'number' and delay > 0 then
        local time = GetGameTimer()

        if (timers[event] or 0) > time then
            return false
        end

        timers[event] = time + delay
    end

    return true
end

--- Triggers a server callback and manages its lifecycle.
-- @param _ any
-- @param event string The event name.
-- @param delay number | false Optional delay to throttle the event.
-- @param cb function|false The callback function or false for a promise-based response.
-- @param ... any The arguments to pass to the server event.
-- @return ... The results from the callback or a resolved promise.
local function triggerServerCallback(_, event, delay, cb, ...)
    if not eventTimer(event, delay) then return end

    local key
    repeat
        key = ('%s:%s'):format(event, math.random(0, 100000))
    until not events[key]

    TriggerServerEvent(cbEvent:format(event), 'sd_lib', key, ...)

    local promise = not cb and promise.new()

    events[key] = function(response, ...)
        response = {response, ...}
        events[key] = nil

        if promise then
            return promise:resolve(response)
        end

        if cb then
            cb(table.unpack(response))
        end
    end

    if promise then
        return table.unpack(Citizen.Await(promise))
    end
end

--- Allows triggering server callbacks directly through the module.
-- @function call
-- @param event string
-- @param delay number | false
-- @param cb function
-- @param ...
SD.Callback = setmetatable({}, {
    __call = triggerServerCallback
})

return SD.Callback