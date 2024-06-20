--- Retrieve the closest player to the specified coordinates.
-- This function checks all active players and returns the closest one within the specified distance.
---@param coords vector3|nil The coordinates to check from. If nil, uses the caller's coordinates.
---@param maxDistance number The maximum distance to check. Defaults to 2.
---@param includeSelf boolean Whether to include the caller themselves in the search. Defaults to false.
---@return number? closestPlayer The ID of the closest player.
---@return number? closestDistance The distance to the closest player.
SD.GetClosestPlayer = function(coords, maxDistance, includeSelf)
    local players = GetActivePlayers()
    local closestPlayer = nil
    local closestDistance = maxDistance or 2
    local callerPed = PlayerPedId()
    local callerCoords = coords or GetEntityCoords(callerPed)

    for _, playerId in ipairs(players) do
        local playerPed = GetPlayerPed(playerId)
        if includeSelf or playerPed ~= callerPed then
            local playerCoords = GetEntityCoords(playerPed)
            local dist = #(callerCoords - playerCoords)

            if closestDistance == -1 or dist < closestDistance then
                closestDistance = dist
                closestPlayer = playerId
            end
        end
    end

    return closestPlayer, closestDistance
end

return SD.GetClosestPlayer