---@class SD.Points
SD.Points = {}

local points = {}  -- Active points tracked by the system.

--- Draws a debug marker for the point.
---@param point table The point to draw debug information for.
local drawDebug = function(point)
    if point.debug then
        -- Drawing a sphere at the point's location with the specified radius
        -- Color is red, alpha is 150 for transparency
        DrawMarker(28, point.coords.x, point.coords.y, point.coords.z - 1, 0, 0, 0, 0, 0, 0, point.distance*2, point.distance*2, point.distance*2, 255, 0, 0, 150, false, true, 2, false, nil, nil, false)
    end
end

--- Creates a new point with specific behaviors.
---@param args table Contains all necessary data to define the point.
---@return table The created point.
SD.Points.New = function(args)
    local point = {
        id = #points + 1,
        coords = SD.Vector.ToVector(args.coords),
        distance = args.distance,
        onEnter = args.onEnter,
        onExit = args.onExit,
        debug = args.debug,
    }
    point.remove = function()
        points[point.id] = nil
    end
    points[point.id] = point
    return point
end

CreateThread(function()
    while true do
        local anyDebug = false
        local coords = GetEntityCoords(PlayerPedId())

        for _, point in pairs(points) do
            local distance = #(coords - point.coords)
            if distance <= point.distance then
                if not point.inside then
                    point.inside = true
                    if point.onEnter then point.onEnter() end
                end
            elseif point.inside then
                point.inside = false
                if point.onExit then point.onExit() end
            end

            -- Call the debug drawing function if debugging is enabled
            if point.debug then
                anyDebug = true
                drawDebug(point)
            end
        end

        Wait(anyDebug and 0 or 300)  -- Check every 300 ms if no debug, every frame if any debug
    end
end)

--- Gets all the active points.
---@return table The table of active points.
SD.Points.GetAllPoints = function()
    return points
end

--- Gets the closest point to the player's current location.
---@return table The closest point.
SD.Points.GetClosestPoint = function()
    local closest, minDist = nil, math.huge
    local playerCoords = GetEntityCoords(PlayerPedId())
    for _, point in pairs(points) do
        local dist = #(playerCoords - point.coords)
        if dist < minDist then
            closest, minDist = point, dist
        end
    end
    return closest
end

return SD.Points