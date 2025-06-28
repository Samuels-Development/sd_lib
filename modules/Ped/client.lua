--- @class SD.Ped
SD.Ped = {}

local activePeds = {}  -- Active peds tracked by the system

--- Creates and spawns a ped at a specified location.
---@param modelHash number The hash of the ped model.
---@param coords vector3 The coordinates to spawn the ped.
---@param freeze boolean If true, freezes the ped in place.
---@param scenario string The scenario for the ped to enact.
---@param targetOptions table The options for the target interaction.
---@param interactionType string The type of interaction ('target' or 'textui').
---@return number ped The native entity handle for the created ped.
local CreatePedInternal = function(modelHash, coords, freeze, scenario, targetOptions, interactionType)
    local ped = CreatePed(0, modelHash, coords.x, coords.y, coords.z, coords.w, false, false)
    if freeze then FreezeEntityPosition(ped, true) end
    if scenario then TaskStartScenarioInPlace(ped, scenario, 0, true) end
    SetEntityVisible(ped, true)
    SetEntityInvincible(ped, true)
    PlaceObjectOnGroundProperly(ped)
    SetBlockingOfNonTemporaryEvents(ped, true)
    
    if targetOptions then
        SD.Interaction.AddTargetEntity(interactionType, ped, targetOptions)
    end

    AddEventHandler("onResourceStop", function(resource)
        if resource == GetCurrentResourceName() and DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end)

    return ped
end

--- Public function to create a ped using a 'data' table with all necessary parameters.
---@param data table A table containing:
---  • model (string|number): model name or hash  
---  • coords (vector3|table): position (x,y,z,w)  
---  • freeze? (boolean)  
---  • scenario? (string)  
---  • targetOptions? (table)  
---  • interactionType? (string)
---@return number id The internal ped ID.
---@return number ped The native entity handle.
SD.Ped.CreatePed = function(data)
    local pedModel = type(data.model) == "string" and GetHashKey(data.model) or data.model
    SD.LoadModel(pedModel)

    local coords = type(data.coords) == "table"
        and vector3(data.coords.x, data.coords.y, data.coords.z, data.coords.w or 0)
        or data.coords

    local ped = CreatePedInternal(
        pedModel,
        coords,
        data.freeze or false,
        data.scenario,
        data.targetOptions,
        data.interactionType
    )

    local id = #activePeds + 1
    activePeds[id] = ped

    return id, ped
end

--- Removes a ped from the game and the active list.
---@param pedId number The internal ID of the ped to remove.
SD.Ped.RemovePed = function(pedId)
    local ped = activePeds[pedId]
    if ped and DoesEntityExist(ped) then
        DeleteEntity(ped)
    end
    activePeds[pedId] = nil
end

--- Look up the native ped handle by your internal ID.
---@param pedId number
---@return number|nil ped The native entity handle, or nil if not found.
SD.Ped.GetEntity = function(pedId)
    return activePeds[pedId]
end

--- Integrates the Points module for ped handling, returns both point and ped handle.
---@param data table A table with:
---  • coords (vector3|table)  
---  • distance (number)  
---  • other fields passed to CreatePed
---@return table point The Point instance.
---@return number|nil ped The native entity handle when spawned (nil until onEnter).
SD.Ped.CreatePedAtPoint = function(data)
    local pointCoords = SD.Vector.ToVector3(data.coords)
    local spawnedPed

    local point = SD.Points.New({
        coords = pointCoords,
        distance = data.distance,
        onEnter = function()
            if not data.pedId or not DoesEntityExist(activePeds[data.pedId]) then
                local id, ped = SD.Ped.CreatePed(data)
                data.pedId = id
                spawnedPed = ped
            end
        end,
        onExit = function()
            SD.Ped.RemovePed(data.pedId)
            data.pedId = nil
        end,
        debug = false,
    })

    return point, spawnedPed
end

return SD.Ped