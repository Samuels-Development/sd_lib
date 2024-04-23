--- @class SD.Table
SD.Table = {}

--- Check if a value exists in a passed table.
---@param tbl table The table to search through.
---@param value any The value to search for in the table.
---@return boolean Returns true if the value exists in the table, false otherwise.
SD.Table.Contains = function(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

--- Remove a passed value from a passed table.
---@param tbl table The table to remove the value from.
---@param value any The value to be removed from the table.
SD.Table.RemoveValue = function(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            tbl[k] = nil
            break
        end
    end
end

--- Get the index of a value in a table.
---@param tbl table The table to search through.
---@param object any The object whose index in the table is to be found.
---@return integer|nil The index of the object in the table, or nil if not found.
SD.Table.IndexOf = function(tbl, object)
    if type(tbl) == 'table' then
        for i, value in ipairs(tbl) do
            if object == value then
                return i
            end
        end
    end
    return nil
end

--- Add a value to a table if it does not already exist.
---@param tbl table The table to add the value to.
---@param value any The value to be added to the table if it's unique.
SD.Table.AddUnique = function (tbl, value)
    if not SD.Table.Contains(tbl, value) then
        table.insert(tbl, value)
    end
end

--- Merge two tables.
---@param tbl1 table The first table to merge into.
---@param tbl2 table The second table whose values will be added to the first table.
SD.Table.MergeTables = function(tbl1, tbl2)
    for _, value in ipairs(tbl2) do
        table.insert(tbl1, value)
    end
end

--- Filter a table based on a predicate function.
---@param tbl table The table to be filtered.
---@param predicate function The predicate function to determine if an element should be included in the result. Takes an element and its key as arguments.
---@return table A new table containing only elements that satisfy the predicate function.
SD.Table.Filter = function(tbl, predicate)
    local filtered = {}
    for k, v in pairs(tbl) do
        if predicate(v, k) then
            table.insert(filtered, v)
        end
    end
    return filtered
end

--- Map a table to a new table based on a transformation function.
---@param tbl table The table to be mapped.
---@param transform function The transformation function applied to each element. Takes an element and its key as arguments.
---@return table A new table containing the results of applying the transform function to each element in the original table.
SD.Table.Map = function(tbl, transform)
    local mapped = {}
    for k, v in pairs(tbl) do
        mapped[k] = transform(v, k)
    end
    return mapped
end

return SD.Table