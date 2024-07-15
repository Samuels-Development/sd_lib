--- @class SD.Inventory
SD.Inventory = {}

local invState = GetResourceState('ox_inventory') -- Check if ox_inventory is started.

-- Dynamic selection function to determine how to check for item existence.
local HasItem = function()
    if invState == 'started' then
        -- 'ox_inventory' system.
        return function(items)
            if type(items) == 'table' then
                local itemArray = {}
                for k in pairs(items) do
                    itemArray[#itemArray + 1] = k
                end
                local returnedItems = exports.ox_inventory:Search('count', itemArray)
                local result = {}
                for k, v in pairs(items) do
                    result[k] = returnedItems[k] or 0
                end
                return result
            else
                return exports.ox_inventory:Search('count', items)
            end
        end
    elseif Framework == 'esx' then
        -- ESX system.
        return function(items)
            local PlayerData = ESX.GetPlayerData() or {}
            local inventory = PlayerData.inventory or {}
            local result = {}
            if type(items) == 'table' then
                for k in pairs(items) do
                    result[k] = 0
                end
                for _, itemData in pairs(inventory) do
                    if items[itemData.name] then
                        result[itemData.name] = (itemData.count or itemData.amount)
                    end
                end
                return result
            else
                for _, itemData in pairs(inventory) do
                    if itemData.name == items then
                        return itemData.count or itemData.amount
                    end
                end
            end
            return 0
        end
    elseif Framework == 'qb' or Framework == 'qbx' then
        -- QBCore system.
        return function(items)
            local PlayerData = QBCore.Functions.GetPlayerData()
            local inventory = PlayerData and PlayerData.items or {}
            local result = {}
            if type(items) == 'table' then
                for k in pairs(items) do
                    result[k] = 0
                end
                for _, inventoryItem in ipairs(inventory) do
                    if items[inventoryItem.name] then
                        result[inventoryItem.name] = inventoryItem.amount or inventoryItem.count
                    end
                end
                return result
            else
                for _, inventoryItem in ipairs(inventory) do
                    if inventoryItem.name == items then
                        return inventoryItem.amount or inventoryItem.count
                    end
                end
            end
            return 0
        end
    else
        -- Fallback for unsupported inventory systems.
        return function() return 0 end
    end
end

local HasItemInInventory = HasItem()

-- Assign the dynamically selected function to SD.Inventory.HasItem
SD.Inventory.HasItem = function(items)
    return HasItemInInventory(items)
end

return SD.Inventory