---@class SD.Ped
SD.Ped = {}

local activePeds = {}  -- Active peds tracked by the system

--- Creates and spawns a ped at a specified location.
---@param modelHash number The hash of the ped model.
---@param coords vector3 The coordinates to spawn the ped.
---@param freeze boolean If true, freezes the ped in place.
---@param scenario string The scenario for the ped to enact.
---@param targetOptions table The options for the target interaction.
---@param interactionType string The type of interaction ('target' or 'textui').
local CreatePed = function(modelHash, coords, freeze, scenario, targetOptions, interactionType)
    local ped = CreatePed(0, modelHash, coords.x, coords.y, coords.z, coords.w, false, false)
    if freeze then FreezeEntityPosition(ped, true) end
    if scenario then TaskStartScenarioInPlace(ped, scenario, 0, true) end
    SetEntityVisible(ped, true)
    SetEntityInvincible(ped, true)
    PlaceObjectOnGroundProperly(ped)
    SetBlockingOfNonTemporaryEvents(ped, true)
    
    -- Add target interaction
    if targetOptions then
        SD.Interaction.AddTargetEntity(interactionType, ped, targetOptions)
    end

    -- Clean up the ped on resource stop
    AddEventHandler("onResourceStop", function(resource)
        if resource == GetCurrentResourceName() then
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
        end
    end)

    return ped
end

--- Public function to create a ped using a 'data' table with all necessary parameters.
---@param data table A table containing all necessary data for ped creation.
---@return number The ID of the created ped.
SD.Ped.CreatePed = function(data)
    local pedModel = type(data.model) == "string" and GetHashKey(data.model) or data.model
    SD.LoadModel(pedModel)
    local ped = CreatePed(pedModel, SD.Vector.ToVector(data.coords), data.freeze or false, data.scenario, data.targetOptions, data.interactionType)
    local id = #activePeds + 1
    activePeds[id] = ped
    return id
end

--- Removes a ped from the game and the active list.
---@param pedId number The ID of the ped to remove.
SD.Ped.RemovePed = function(pedId)
    local ped = activePeds[pedId]
    if DoesEntityExist(ped) then
        DeleteEntity(ped)
    end
    activePeds[pedId] = nil
end

--- Integrates the Points module for ped handling.
---@param data table A table with ped data and point behaviors.
SD.Ped.CreatePedAtPoint = function(data)
    local pointCoords = SD.Vector.ToVector3(data.coords)
    local point = SD.Points.New({
        coords = pointCoords,
        distance = data.distance,
        onEnter = function()
            if not data.pedId or not DoesEntityExist(activePeds[data.pedId]) then
                data.pedId = SD.Ped.CreatePed(data)
            end
        end,
        onExit = function()
            SD.Ped.RemovePed(data.pedId)
        end,
        debug = false, 
    })
    return point
end

return SD.Ped