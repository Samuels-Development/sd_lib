--- Table of resources for dispatch systems. (custom is a placeholder for your application)
local resources = { {name = "linden_outlawalert"}, {name = "cd_dispatch"}, {name = "ps-dispatch"}, {name = "qs-dispatch"}, {name = "core_dispatch"}, {name = "origen_police"}, {name = "codem-dispatch"}, {name = "custom"} }

-- Common tables for jobs and job types in the case of ps-dispatch.
local jobs = { 'police' }
local types = { 'leo' }

--- Selects and returns the most appropriate function for dispatching police alerts.
-- Based on the configured dispatch system, this function assigns a tailored dispatch method.
-- It facilitates the dynamic use of different alert systems without hardcoding preferences within the alert logic.
---@return function A dispatch function customized to the active configuration.
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
                        blip = {
                            sprite = data.sprite,
                            scale = data.scale,
                            colour = data.colour,
                            flashes = false,
                            text = data.blipText,
                            time = 5,
                            radius = 0,
                        }
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
                        blip = {
                            sprite = data.sprite,
                            scale = data.scale,
                            colour = data.colour,
                            flashes = true,
                            text = data.blipText,
                            time = (6 * 60 * 1000),
                        }
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
            elseif resource.name == "origen_police" then
                return function(data, playerCoords, locationInfo, gender)
                    TriggerServerEvent("SendAlert:police", {
                        coords = playerCoords,
                        title = data.message,
                        type = data.displayCode,
                        message = data.description,
                        job = 'police',
                    })
                end
            elseif resource.name == "codem-dispatch" then
                return function(data, playerCoords, locationInfo, gender)
                    local Text = data.message .. ' on ' .. locationInfo
                    local Type = 'Illegal'
                    local Header = data.title
                    local Code = data.displayCode

                    local DispatchData = {
                        type = Type,
                        header = Header,
                        text = Text,
                        code = Code,
                    }

                    exports['codem-dispatch']:CustomDispatch(DispatchData)
                end
            elseif resource.name == "tk_dispatch" then
                return function(data, playerCoords, locationInfo, gender)
                    exports.tk_dispatch:addCall({
                        title = data.title,
                        code = data.displayCode,
                        message = data.message,
                        coords = data.coords or playerCoords,
                        jobs = jobs,
                        blip = {
                            sprite = data.sprite,
                            scale = data.scale,
                            colour = data.colour,
                            text = data.blipText,
                        },
                        playSound = data.playSound,
                    })
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
