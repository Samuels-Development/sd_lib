--- @class SD.Inventory
SD.Inventory = {}

local invState = GetResourceState('ox_inventory') -- Check if ox_inventory is started.

-- Dynamic selection function to determine how to check for item existence.
local HasItem = function()
    if invState == 'started' then
        -- 'ox_inventory' system.
        return function(items, amount)
            local itemArray = {}
            if type(items) == 'table' then
                -- Convert dictionary to array if needed.
                for k in pairs(items) do
                    itemArray[#itemArray + 1] = k
                end
                local returnedItems = exports.ox_inventory:Search('count', itemArray)
                local count = 0
                for k, v in pairs(items) do
                    if returnedItems[k] and (returnedItems[k] >= v or returnedItems[k] >= items[k].amount) then
                        count = count + 1
                    end
                end
                return count == #itemArray
            else
                return exports.ox_inventory:Search('count', items) >= amount
            end
        end
    elseif Framework == 'esx' then
        -- ESX system.
        return function(items, amount)
            local PlayerData = ESX.GetPlayerData() or {}
            local inventory = PlayerData.inventory or {}
            if type(items) == 'table' then
                local count = 0
                for _, itemData in pairs(inventory) do
                    if items[itemData.name] and ((itemData.count or itemData.amount) >= items[itemData.name]) then
                        count = count + 1
                    end
                end
                return count == table.count(items)
            else
                for _, itemData in pairs(inventory) do
                    if itemData.name == items and ((itemData.count or itemData.amount) >= amount) then
                        return true
                    end
                end
            end
            return false
        end
    elseif Framework == 'qb' or Framework == 'qbx' then
        -- QBCore system.
        return function(items, amount)
            local PlayerData = QBCore.Functions.GetPlayerData()
            local inventory = PlayerData and PlayerData.items or {}
            if type(items) == 'table' then
                for itemName, requiredAmount in pairs(items) do
                    local item = nil
                    for _, inventoryItem in ipairs(inventory) do
                        if inventoryItem.name == itemName and ((inventoryItem.amount or inventoryItem.count) >= requiredAmount) then
                            item = inventoryItem
                            break
                        end
                    end
                    if not item then return false end
                end
                return true
            else
                for _, inventoryItem in ipairs(inventory) do
                    if inventoryItem.name == items and ((inventoryItem.amount or inventoryItem.count) >= amount) then
                        return true
                    end
                end
                return false
            end
        end
    else
        -- Fallback for unsupported inventory systems.
        return function() return false end
    end
end

local HasItemInInventory = HasItem()

-- Assign the dynamically selected function to SD.Inventory.HasItem
SD.Inventory.HasItem = function(items, amount)
    return HasItemInInventory(items, amount)
end

return SD.Inventory