---@class SD.Vector
SD.Vector = {}

--- Converts a table with x, y, z (and optionally w) keys into a vector3 or vector4.
---@param t table A table containing x, y, z coordinates (and optionally w).
---@return vector3|vector4 A vector3 or vector4 created from the table coordinates.
SD.Vector.ToVector = function(t)
    if t.w then
        return vector4(t.x, t.y, t.z, t.w)
    else
        return vector3(t.x, t.y, t.z)
    end
end

--- Converts a vector4 to a vector3 by removing the w component.
---@param vec vector4 The vector4 to convert.
---@return vector3 The resulting vector3.
SD.Vector.ToVector3 = function(vec)
    if vec.w then
        return vector3(vec.x, vec.y, vec.z)
    end
    return vec
end

--- Adds two vectors.
---@param vec1 vector3|vector4 The first vector.
---@param vec2 vector3|vector4 The second vector.
---@return vector3|vector4 The resulting vector after addition.
SD.Vector.Add = function(vec1, vec2)
    if vec1.w and vec2.w then
        return vector4(vec1.x + vec2.x, vec1.y + vec2.y, vec1.z + vec2.z, vec1.w + vec2.w)
    else
        return vector3(vec1.x + vec2.x, vec1.y + vec2.y, vec1.z + vec2.z)
    end
end

--- Subtracts the second vector from the first vector.
---@param vec1 vector3|vector4 The first vector.
---@param vec2 vector3|vector4 The second vector.
---@return vector3|vector4 The resulting vector after subtraction.
SD.Vector.Subtract = function(vec1, vec2)
    if vec1.w and vec2.w then
        return vector4(vec1.x - vec2.x, vec1.y - vec2.y, vec1.z - vec2.z, vec1.w - vec2.w)
    else
        return vector3(vec1.x - vec2.x, vec1.y - vec2.y, vec1.z - vec2.z)
    end
end

--- Multiplies a vector by a scalar.
---@param vec vector3|vector4 The vector to multiply.
---@param scalar number The scalar value.
---@return vector3|vector4 The resulting vector after multiplication.
SD.Vector.Multiply = function(vec, scalar)
    if vec.w then
        return vector4(vec.x * scalar, vec.y * scalar, vec.z * scalar, vec.w * scalar)
    else
        return vector3(vec.x * scalar, vec.y * scalar, vec.z * scalar)
    end
end

--- Divides a vector by a scalar.
---@param vec vector3|vector4 The vector to divide.
---@param scalar number The scalar value.
---@return vector3|vector4 The resulting vector after division.
SD.Vector.Divide = function(vec, scalar)
    if vec.w then
        return vector4(vec.x / scalar, vec.y / scalar, vec.z / scalar, vec.w / scalar)
    else
        return vector3(vec.x / scalar, vec.y / scalar, vec.z / scalar)
    end
end

--- Calculates the distance between two vectors.
---@param vec1 vector3 The first vector.
---@param vec2 vector3 The second vector.
---@return number The distance between the two vectors.
SD.Vector.Distance = function(vec1, vec2)
    return #(vec1 - vec2)
end

--- Normalizes a vector.
---@param vec vector3 The vector to normalize.
---@return vector3 The normalized vector.
SD.Vector.Normalize = function(vec)
    local mag = #vec
    if mag > 0 then
        return vec / mag
    end
    return vector3(0, 0, 0)
end

--- Calculates the dot product of two vectors.
---@param vec1 vector3 The first vector.
---@param vec2 vector3 The second vector.
---@return number The dot product of the two vectors.
SD.Vector.Dot = function(vec1, vec2)
    return vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z
end

--- Calculates the cross product of two vectors.
---@param vec1 vector3 The first vector.
---@param vec2 vector3 The second vector.
---@return vector3 The cross product of the two vectors.
SD.Vector.Cross = function(vec1, vec2)
    return vector3(
        vec1.y * vec2.z - vec1.z * vec2.y,
        vec1.z * vec2.x - vec1.x * vec2.z,
        vec1.x * vec2.y - vec1.y * vec2.x
    )
end

--- Converts a vector to a table with x, y, z (and optionally w) keys.
---@param vec vector3|vector4 The vector to convert.
---@return table A table containing the x, y, z (and optionally w) coordinates of the vector.
SD.Vector.ToTable = function(vec)
    if vec.w then
        return { x = vec.x, y = vec.y, z = vec.z, w = vec.w }
    else
        return { x = vec.x, y = vec.y, z = vec.z }
    end
end

return SD.Vector
