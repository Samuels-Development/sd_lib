SD.Ped = {}

-- Table to keep track of created peds, indexed by ID for easy access.
local Peds = {}

-- Internal function: Deletes a ped and cleans up resources.
local deletePed = function(ped)
    if DoesEntityExist(ped) then
        SetEntityAsMissionEntity(ped, false, true)
        DeleteEntity(ped)
    end
end

--- Creates and spawns a ped at the specified location with given attributes.
-- @param payload table A table containing ped creation parameters.
-- @field model Hash|String The model hash or name to be used for the ped.
-- @field coords Vector3 The coordinates where the ped will be spawned.
-- @field heading number The heading of the ped.
-- @field freeze boolean If true, freezes the ped in place.
-- @field invincible boolean If true, makes the ped invincible.
-- @field tempevents boolean If true, blocks non-temporary events for the ped.
-- @field animDict string Optional. The animation dictionary to use.
-- @field animName string Optional. The animation name to play.
-- @field scenario string Optional. The scenario for the ped to engage in.
-- @return Ped The handle of the created ped; nil if creation failed.
SD.Ped.CreatePed = function(payload)
    if not payload or not payload.coords or not payload.model then
        error("CreatePed: Missing required parameters.")
        return nil
    end

    if not SD.LoadModel(payload.model) then
        error(string.format("Failed to load ped model: %s", tostring(payload.model)))
        return nil
    end

    local ped = CreatePed(0, payload.model, payload.coords.x, payload.coords.y, payload.coords.z, payload.heading or 0, false, true)
    if not DoesEntityExist(ped) then return nil end

    -- Apply ped properties based on payload options
    if payload.freeze then FreezeEntityPosition(ped, true) end
    if payload.invincible then SetEntityInvincible(ped, true) end
    if payload.tempevents then SetBlockingOfNonTemporaryEvents(ped, true) end

    -- Handle animations if specified
    if payload.animDict and payload.animName then
        if SD.LoadAnim(payload.animDict) then
            TaskPlayAnim(ped, payload.animDict, payload.animName, 8.0, -8.0, -1, 49, 0, false, false, false)
        end
    end

    -- Handle scenario if specified
    if payload.scenario then
        TaskStartScenarioInPlace(ped, payload.scenario, 0, true)
    end

    -- Generate unique ID for the ped and add it to the tracking table
    local pedId = #Peds + 1
    Peds[pedId] = { ped = ped, resource = GetInvokingResource() }

    -- Cleanup the model
    SetModelAsNoLongerNeeded(payload.model)

    return ped, pedId -- Return both the ped handle and its ID for further reference
end

--- Adds a ped to the tracking table and optionally spawns it.
-- @param payload table Contains parameters for ped creation including an optional distance check.
SD.Ped.AddPed = function(payload)
    if not payload or type(payload) ~= 'table' then return end
    local playerCoords = GetEntityCoords(PlayerPedId())

    -- Create and add the ped only if within specified distance
    if payload.dist and #(playerCoords - vector3(payload.coords.x, payload.coords.y, payload.coords.z)) <= payload.dist then
        local ped, pedId = SD.Ped.CreatePed(payload)
        if ped and pedId then
            payload.id = pedId -- Store the ID in the payload for reference
            Peds[pedId] = payload -- Update the tracking table with full payload
        end
    end
end

--- Removes a ped based on its ID.
-- @param id integer The unique ID of the ped to remove.
SD.Ped.RemovePed = function(id)
    local pedData = Peds[id]
    if pedData and pedData.ped then
        deletePed(pedData.ped)
        Peds[id] = nil
    end
end

--- Sets new coordinates for a ped based on its ID.
-- @param id integer The unique ID of the ped to relocate.
-- @param coords vector3 The new coordinates for the ped.
-- @param heading number The new heading for the ped.
SD.Ped.SetPedCoords = function(id, coords, heading)
    local pedData = Peds[id]
    if pedData and pedData.ped then
        SetEntityCoords(pedData.ped, coords.x, coords.y, coords.z, false, false, false, true)
        if heading then SetEntityHeading(pedData.ped, heading) end
    end
end

--- Retrieves a ped by its unique ID.
-- @param id integer The unique ID of the ped to retrieve.
-- @return entity|nil The ped entity if found, or nil if not.
SD.Ped.GetPedById = function(id)
    local pedData = Peds[id]
    if pedData then
        return pedData.ped
    end
    return nil
end

--- Removes all peds spawned by a specific resource or the current invoking resource if not specified.
-- @param resource string|nil The name of the resource, or nil to use the invoking resource.
SD.Ped.RemoveResourcePed = function(resource)
    resource = resource or GetInvokingResource()
    for id, pedData in pairs(Peds) do
        if pedData.resource == resource then
            deletePed(pedData.ped)
            Peds[id] = nil
        end
    end
end

-- Register an event handler for cleanup on resource stop
AddEventHandler('onClientResourceStop', function(stoppedResource)
    SD.Ped.RemoveResourcePed(stoppedResource)
end)

return SD.Ped