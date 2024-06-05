--- @class SD.Doorlock
SD.Doorlock = {}

-- Table of resources for toggling doors.
local resources = { {name = "ox_doorlock"}, {name = "qb-doorlock"}, {name = "nui-doorlock"}, {name = "cd_doorlock"}, {name = "doors_creator"} }

-- Function to automatically detect the running door lock resource and return the appropriate update function.
local SelectDoorLock = function()
    for _, resource in ipairs(resources) do
        if GetResourceState(resource.name) == 'started' then
            if resource.name == "qb-doorlock" then
                return function(data)
                    TriggerServerEvent('qb-doorlock:server:updateState', data.id, data.locked, false, false, data.enablesounds, false, false)
                end
            elseif resource.name == "nui-doorlock" then
                return function(data)
                    TriggerServerEvent('nui_doorlock:server:updateState', data.id, data.locked, false, false, data.enablesounds)
                end
            elseif resource.name == "cd_doorlock" or resource.name == "ox_doorlock" or resource.name == "doors_creator" then
                return function(data)
                    TriggerServerEvent('sd_lib:doorToggle', data)
                end
            end
        end
    end

    return function(data)  -- Fallback if none of the resources are started
        error("No supported door lock resource is currently running.")
    end
end

-- Utilize the dynamically selected function for door state updates.
local UpdateDoorState = SelectDoorLock()

-- Public function to update door state
SD.Doorlock.UpdateState = function(data)
    UpdateDoorState(data)
end

return SD.Doorlock