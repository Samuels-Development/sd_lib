--- @class SD.Inventory
SD.Inventory = {}

local ox_inventory = 'ox_inventory' -- Variable to store the name for ox_inventory, case changed.
local invState = GetResourceState('ox_inventory') -- Check if ox_inventory is started.

-- Dynamic selection function to determine how to check for item existence.
local HasItem = function()
    -- 'ox_inventory' system.
    if invState == 'started' then
        return function(items, amount)
            if type(items) == 'table' then
                local itemArray = {}
                if next(items, next(items)) then -- It's an array.
                    itemArray = items
                else -- Convert dictionary to array.
                    for k in pairs(items) do
                        itemArray[#itemArray + 1] = k
                    end
                end

                local returnedItems = exports[ox_inventory]:Search('count', itemArray)
                if returnedItems then
                    local count = 0
                    for k, v in pairs(items) do
                        if returnedItems[k] and returnedItems[k] >= v then
                            count = count + 1
                        end
                    end
                    return count == #itemArray
                end
                return false
            else -- Single item check.
                return exports[ox_inventory]:Search('count', items) >= amount
            end
        end
    -- ESX system.
    elseif Framework == 'esx' then
        return function(items, amount)
            local PlayerData = ESX.GetPlayerData()
            local inventory = PlayerData and PlayerData.inventory or {}
            local isTable = type(items) == 'table'
            local count = 0

            for _, itemData in pairs(inventory) do
                if isTable then
                    for k, v in pairs(items) do
                        if itemData.name == k and itemData.count >= v then
                            count = count + 1
                        end
                    end
                    return count == #items
                elseif itemData.name == items and itemData.count >= amount then
                    return true
                end
            end
            return false
        end
    -- QBCore system.
    elseif Framework == 'qb' then
        return function(items, amount)
            local PlayerData = QBCore.Functions.GetPlayerData()
            local isTable = type(items) == 'table'
            local inventory = PlayerData and PlayerData.items or {}

            if isTable then
                for k, v in pairs(items) do
                    local item = inventory[k]
                    if not (item and item.amount >= v) then
                        return false
                    end
                end
                return true
            else
                local item = inventory[items]
                return item and item.amount >= amount
            end
        end
    else
        -- Fallback for unsupported inventory systems.
        return function() return false end
    end
end

-- Assign the dynamically selected function to SD.Inventory.HasItem
SD.Inventory.HasItem = HasItem()

return SD.Inventory