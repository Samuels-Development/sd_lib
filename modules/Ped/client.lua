---@class SD.Ped
SD.Ped = {}

local activePeds = {}  -- Active peds tracked by the system

--- Creates and spawns a ped at a specified location.
---@param modelHash number The hash of the ped model.
---@param coords vector3 The coordinates to spawn the ped.
---@param heading number The heading direction of the ped.
---@param freeze boolean If true, freezes the ped in place.
---@param invincible boolean If true, makes the ped invincible.
---@param blockTempEvents boolean If true, blocks non-temporary events for the ped.
---@param scenario string The scenario for the ped to enact.
---@param animDict string The animation dictionary for the ped to play.
---@param animName string The animation name for the ped to play.
---@param targetOptions table The options for the target interaction.
---@param interactOptions table The options for the interaction.
---@return number The created ped.
local function CreatePed(modelHash, coords, heading, freeze, invincible, blockTempEvents, scenario, animDict, animName, targetOptions, interactOptions)
    local ped = CreatePed(0, modelHash, coords.x, coords.y, coords.z, heading, false, true)
    
    if freeze then FreezeEntityPosition(ped, true) end
    if invincible then SetEntityInvincible(ped, true) end
    if blockTempEvents then SetBlockingOfNonTemporaryEvents(ped, true) end
    if animDict and animName then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Citizen.Wait(0)
        end
        TaskPlayAnim(ped, animDict, animName, 8.0, 0.0, -1, 1, 0, false, false, false)
        RemoveAnimDict(animDict)
    end
    if scenario then TaskStartScenarioInPlace(ped, scenario, 0, true) end
    
    -- Add target interaction
    if targetOptions then
        SD.Target.AddTargetEntity(ped, targetOptions)
    end

    SetModelAsNoLongerNeeded(modelHash)
    SetEntityVisible(ped, true)
    PlaceObjectOnGroundProperly(ped)
    
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
    local ped = CreatePed(
        pedModel,
        SD.Vector.ToVector(data.coords),
        data.heading or 0.0,
        data.freeze or false,
        data.invincible or false,
        data.blockTempEvents or false,
        data.scenario,
        data.animDict,
        data.animName,
        data.targetOptions,
        data.interactOptions
    )
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

--- Sets the coordinates and heading of an existing ped.
---@param pedId number The ID of the ped to move.
---@param coords vector3 The new coordinates for the ped.
---@param heading number The new heading for the ped.
SD.Ped.SetPedCoords = function(pedId, coords, heading)
    local ped = activePeds[pedId]
    if DoesEntityExist(ped) then
        SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
        SetEntityHeading(ped, heading)
    end
end

--- Gets the ped entity by its ID.
---@param pedId number The ID of the ped to retrieve.
---@return number The ped entity.
SD.Ped.GetPedById = function(pedId)
    return activePeds[pedId]
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