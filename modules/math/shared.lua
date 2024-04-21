--- @class SD.Math
SD.Math = {}

--- Calculates a weighted chance selection based on the provided table of choices.
-- @param tbl table The table containing choices with their associated weights.
-- @return any The key of the chosen item based on weighted probability.
SD.Math.WeightedChance = function(tbl)
    local total = 0
    for _, reward in pairs(tbl) do
        total = total + reward.chance
    end

    local rand = math.random() * total
    for k, reward in pairs(tbl) do
        rand = rand - reward.chance
        if rand <= 0 then
            return k
        end
    end
end

--- Clamps a number between a minimum and maximum value.
-- @param num number The number to clamp.
-- @param min number The minimum value.
-- @param max number The maximum value.
-- @return number The clamped value.
SD.Math.Clamp = function(num, min, max)
    if num < min then
        return min
    elseif num > max then
        return max
    else
        return num
    end
end

--- Linearly interpolates between two values.
-- @param from number The start value.
-- @param to number The end value.
-- @param alpha number The interpolation factor (0-1).
-- @return number The interpolated value.
SD.Math.Lerp = function(from, to, alpha)
    return from + (to - from) * alpha
end

--- Calculates the factorial of a number.
-- @param n number The number to calculate the factorial of.
-- @return number The factorial of the number.
SD.Math.Factorial = function(n)
    if n == 0 then
        return 1
    else
        return n * SD.Math.Factorial(n - 1)
    end
end

--- Rounds a number to a specified number of decimal places.
-- @param num number The number to round.
-- @param numDecimalPlaces number The number of decimal places to round to.
-- @return number The rounded number.
SD.Math.Round = function(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

--- Calculates the distance between two points in 2D space.
-- @param x1 number The x coordinate of the first point.
-- @param y1 number The y coordinate of the first point.
-- @param x2 number The x coordinate of the second point.
-- @param y2 number The y coordinate of the second point.
-- @return number The distance between the two points.
SD.Math.Distance2D = function(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

--- Calculates the distance between two points in 3D space.
-- @param x1 number The x coordinate of the first point.
-- @param y1 number The y coordinate of the first point.
-- @param z1 number The z coordinate of the first point.
-- @param x2 number The x coordinate of the second point.
-- @param y2 number The y coordinate of the second point.
-- @param z2 number The z coordinate of the second point.
-- @return number The distance between the two points.
SD.Math.Distance3D = function(x1, y1, z1, x2, y2, z2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
end

return SD.Math