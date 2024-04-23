--- Table of resources for dispatch systems. (custom is a placeholder for your application)
local resources = { {name = "linden_outlawalert"}, {name = "cd_dispatch"}, {name = "ps-dispatch"}, {name = "qs-dispatch"}, {name = "core_dispatch"}, {name = "custom"} }

-- Common tables for jobs and job types in the case of ps-dispatch.
local jobs = { 'police' }
local types = { 'leo' }

--- Selects and returns the most appropriate function for dispatching police alerts.
-- Based on the configured dispatch system, this function assigns a tailored dispatch method.
-- It facilitates the dynamic use of different alert systems without hardcoding preferences within the alert logic.
-- @return function A dispatch function customized to the active configuration.
local SelectDispatch = function()
    for _, resource in ipairs(resources) do
        if GetResourceState(resource.name) == 'started' then
            if resource.name == "linden_outlawalert" then
                return function(data, playerCoords, locationInfo, gender)
                    local dispatchData = {
                        dispatchData = {
                            displayCode = data.displayCode,
                            description = data.description,
                            isImportant = 0,
                            recipientList = jobs,
                            length = '10000',
                            infoM = 'fa-info-circle',
                            info = data.message
                        },
                        caller = 'Citizen',
                        coords = playerCoords
                    }
                    TriggerServerEvent('wf-alerts:svNotify', dispatchData)
                end
            elseif resource.name == "cd_dispatch" then
                return function(data, playerCoords, locationInfo, gender)
                    TriggerServerEvent('cd_dispatch:AddNotification', {
                        job_table = jobs,
                        coords = playerCoords,
                        title = data.title,
                        message = data.message .. ' on ' .. locationInfo,
                        flash = 0,
                        unique_id = math.random(999999999),
                        sound = 1,
                        blip = data.blip
                    })
                end
            elseif resource.name == "ps-dispatch" then
                return function(data, playerCoords, locationInfo, gender)
                    local dispatchData = {
                        message = data.title,
                        codeName = data.dispatchcodename,
                        code = data.displayCode,
                        icon = 'fas fa-info-circle',
                        priority = 2,
                        coords = playerCoords,
                        gender = gender,
                        street = locationInfo,
                        jobs = types
                    }
                    TriggerServerEvent('ps-dispatch:server:notify', dispatchData)
                end
           --[[ elseif resource.name == "ps-dispatch-old" then
                return function(data, playerCoords, locationInfo, gender)
                    TriggerServerEvent("dispatch:server:notify",{
                        dispatchcodename = data.dispatchcodename,
                        dispatchCode = data.displayCode,
                        firstStreet = locationInfo,
                        gender = gender,
                        model = nil,
                        plate = nil,
                        priority = 2,
                        firstColor = nil,
                        automaticGunfire = false,
                        origin = playerCoords,
                        dispatchMessage = data.title,
                        job = types
                    })
                end ]] 
            elseif resource.name == "qs-dispatch" then
                return function(data, playerCoords, locationInfo, gender)
                    TriggerServerEvent('qs-dispatch:server:CreateDispatchCall', {
                        job = jobs,
                        callLocation = playerCoords,
                        callCode = { code = data.displayCode, snippet = data.description },
                        message = data.message .. ' on ' .. locationInfo,
                        flashes = false,
                        blip = data.blip
                    })
                end
            elseif resource.name == "core_dispatch" then
                return function(data, playerCoords, locationInfo, gender)
                    TriggerServerEvent("core_dispatch:addCall",
                        data.displayCode,
                        data.description,
                        {{icon = "fa-info-circle", info = data.message}},
                        {playerCoords.x, playerCoords.y, playerCoords.z},
                        jobs,
                        10000,
                        data.sprite,
                        data.colour
                    )
                end
            elseif resource.name == "custom" then
                -- Custom dispatch system implementation placeholder
                return function(data, playerCoords, locationInfo, gender)
                    print("Custom dispatch system configured. Please implement the dispatch functionality.")
                end
            end
        end
    end

    -- Fallback if none of the resources are started
    return function(data, playerCoords, locationInfo, gender)
        print("No supported dispatch system is currently running.")
    end
end

local Dispatch = SelectDispatch()

SD.Dispatch = function(data)
    
    -- Common data preparation
    data = data or {}
    local playerCoords = GetEntityCoords(PlayerPedId())
    local streetName, crossingRoad = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
    local locationInfo = GetStreetNameFromHashKey(streetName)
    if crossingRoad ~= nil and crossingRoad ~= 0 then
        local crossName = GetStreetNameFromHashKey(crossingRoad)
        if crossName and crossName ~= "" then
            locationInfo = locationInfo .. " & " .. crossName
        end
    end

    local gender = SD.GetGender()
    
    -- Execute the dispatch function with prepared data
    Dispatch(data, playerCoords, locationInfo, gender)
end

return SD.Dispatch