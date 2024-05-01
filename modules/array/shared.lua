--- @class SD.Array
SD.Array = {}

--- Check if an array is sequential without gaps.
---@param arr table The array to check.
---@return boolean Returns true if the table is an array, false otherwise.
SD.Array.IsArray = function(arr)
    if type(arr) ~= 'table' then return false end
    local i = 0
    for _ in pairs(arr) do
        i = i + 1
        if arr[i] == nil then return false end
    end
    return true
end

--- Append an element to the end of an array.
---@param arr table The array to append to.
---@param value any The value to append.
SD.Array.Append = function(arr, value)
    table.insert(arr, value)
end

--- Remove an element from an array by its index.
---@param arr table The array to remove from.
---@param index integer The index of the element to remove.
SD.Array.RemoveAt = function(arr, index)
    table.remove(arr, index)
end

--- Find the first index of a value in an array.
---@param arr table The array to search through.
---@param value any The value to find.
---@return integer|nil The index of the value, or nil if not found.
SD.Array.IndexOf = function(arr, value)
    for i, v in ipairs(arr) do
        if v == value then
            return i
        end
    end
    return nil
end

--- Reverse the elements of an array.
---@param arr table The array to reverse.
SD.Array.Reverse = function(arr)
    local i, j = 1, #arr
    while i < j do
        arr[i], arr[j] = arr[j], arr[i]
        i = i + 1
        j = j - 1
    end
end

--- Concatenate two arrays into a new array.
---@param arr1 table The first array.
---@param arr2 table The second array.
---@return table The new array containing elements from both arrays.
SD.Array.Concatenate = function(arr1, arr2)
    local result = {}
    for _, v in ipairs(arr1) do
        table.insert(result, v)
    end
    for _, v in ipairs(arr2) do
        table.insert(result, v)
    end
    return result
end

--- Filter an array based on a predicate function.
---@param arr table The array to be filtered.
---@param predicate function The predicate function to determine if an element should be included. Takes an element as an argument.
---@return table A new array containing only elements that satisfy the predicate.
SD.Array.Filter = function(arr, predicate)
    local filtered = {}
    for i, v in ipairs(arr) do
        if predicate(v, i) then
            table.insert(filtered, v)
        end
    end
    return filtered
end

--- Map an array to a new array based on a transformation function.
---@param arr table The array to be mapped.
---@param transform function The transformation function applied to each element. Takes an element as an argument.
---@return table A new array containing the results of the transform function.
SD.Array.Map = function(arr, transform)
    local mapped = {}
    for i, v in ipairs(arr) do
        mapped[i] = transform(v)
    end
    return mapped
end

return SD.Array