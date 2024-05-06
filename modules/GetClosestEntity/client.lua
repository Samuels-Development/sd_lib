--- Gets the closest player or entity in the vicinity of the player.
-- This function scans the nearby entities and determines which one is the closest to the player.
-- It is designed to work independently of the framework used, directly interfacing with the game's native functions.
---@param isPlayerEntities boolean If true, the function will only consider player entities; otherwise, it will consider all entities.
---@param coords vector3|nil Optional. The coordinates from which to measure distance. Defaults to the player's current position if nil.
---@param modelFilter table|nil Optional. A table where the keys are model hashes that are allowed. If nil, all models are considered.
---@return entity The closest entity found, or -1 if none are found.
---@return distance The distance to the closest entity, or -1 if none are found.
SD.GetClosestEntity = function(isPlayerEntities, coords, modelFilter)
    local entities = isPlayerEntities and GetNearbyPlayers() or GetNearbyEntities()
    local closestEntity, closestEntityDistance = -1, -1

    if not coords then
        local playerPed = PlayerPedId()
        coords = GetEntityCoords(playerPed)
    end

    local filteredEntities = modelFilter and FilterEntitiesByModel(entities, modelFilter) or entities

    for _, entity in ipairs(filteredEntities) do
        local entityCoords = GetEntityCoords(entity)
        local distance = #(coords - entityCoords)

        if closestEntityDistance == -1 or distance < closestEntityDistance then
            closestEntity, closestEntityDistance = entity, distance
        end
    end

    return closestEntity, closestEntityDistance
end

--- Filters entities by the specified models.
---@param entities table A table of entity handles to filter.
---@param modelFilter table A table where keys are model hashes that are allowed.
---@return table A table of entities that match the model filter.
function FilterEntitiesByModel(entities, modelFilter)
    local filteredEntities = {}

    for _, entity in ipairs(entities) do
        if modelFilter[GetEntityModel(entity)] then
            table.insert(filteredEntities, entity)
        end
    end

    return filteredEntities
end

--- Retrieves entities near the player.
---@param range to detect a entity from
---@return table A table of nearby entities.
GetNearbyEntities = function(range)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local nearbyEntities = {}

    for ped in EnumeratePeds() do
        if DoesEntityExist(ped) and playerPed ~= ped then
            local pedCoords = GetEntityCoords(ped)
            if #(playerCoords - pedCoords) < range then
                table.insert(nearbyEntities, ped)
            end
        end
    end

    for vehicle in EnumerateVehicles() do
        if DoesEntityExist(vehicle) then
            local vehicleCoords = GetEntityCoords(vehicle)
            if #(playerCoords - vehicleCoords) < range then
                table.insert(nearbyEntities, vehicle)
            end
        end
    end

    return nearbyEntities
end

--- Retrieves players near the player.
---@param range to detect a player from
---@return table A table of nearby player entities.
GetNearbyPlayers = function(range)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local nearbyPlayers = {}

    for _, playerId in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(playerId)
        if DoesEntityExist(targetPed) and playerPed ~= targetPed then
            local targetCoords = GetEntityCoords(targetPed)
            if #(playerCoords - targetCoords) < range then
                table.insert(nearbyPlayers, targetPed)
            end
        end
    end

    return nearbyPlayers
end

--- Enumerates entities based on provided functions.
-- This generic function creates an iterator for entities, such as peds or vehicles, using the game's native enumeration functions.
---@param initFunc function The function to initialize the enumeration. Expected to return an iterator handle and the first entity ID.
---@param moveFunc function The function to move to the next entity in the enumeration. It takes the iterator handle and returns a success flag and the next entity ID.
---@param disposeFunc function The function to dispose of the iterator handle once enumeration is complete or needs to be terminated early.
---@return coroutine An iterator coroutine that yields entity IDs one by one until all have been enumerated.
EnumerateEntities = function(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
        local iter, id = initFunc()
        if not id or id == 0 then
            disposeFunc(iter) -- Dispose of the iterator if the initial ID is invalid.
            return
        end
        
        local enum = {handle = iter, destructor = disposeFunc}
        -- Set a garbage collector for the enumerator to ensure resources are cleaned up automatically.
        setmetatable(enum, {__gc = function(enum) enum.destructor(enum.handle) end})

        local next = true
        repeat
            coroutine.yield(id) -- Yield the current entity ID to the caller.
            next, id = moveFunc(iter) -- Move to the next entity in the enumeration.
        until not next -- Continue until there are no more entities to enumerate.

        enum.destructor(enum.handle) -- Explicitly dispose of the iterator handle when done.
    end)
end

--- Creates an enumerator for all peds in the game world.
-- Utilizes EnumerateEntities with the game's native ped enumeration functions to create an iterator over all peds.
---@return coroutine An iterator that yields the entity ID of each ped one by one.
EnumeratePeds = function()
    return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

--- Creates an enumerator for all vehicles in the game world.
-- Utilizes EnumerateEntities with the game's native vehicle enumeration functions to create an iterator over all vehicles.
---@return coroutine An iterator that yields the entity ID of each vehicle one by one.
EnumerateVehicles = function()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

return SD.GetClosestEntity