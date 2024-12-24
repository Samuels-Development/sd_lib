---@class SD.Inventory
SD.Inventory = {}

local inventorySystem
local codemInv = 'codem-inventory' -- Variable to store the string name codem-inventory
local oxInv = 'ox_inventory' -- Variable to store the string name ox_inventory
local tgiannInv = 'tgiann-inventory' -- Variable to store the string name tgiann-inventory

if GetResourceState(codemInv) == 'started' then
    inventorySystem = 'codem'
elseif GetResourceState(oxInv) == 'started' then
    inventorySystem = 'ox'
elseif GetResourceState(tgiannInv) == 'started' then
    inventorySystem = 'tgiann'
end

-- Dynamic selection function to determine how to check for item existence.
local HasItem = function()
    if inventorySystem == 'codem' then
        return function(items)
            local playerInventory = exports[codemInv]:getUserInventory()
            local result = {}

            if type(items) == 'table' then
                for k in pairs(items) do
                    result[k] = 0
                end
                for _, itemData in pairs(playerInventory) do
                    local itemName = tostring(itemData.name)
                    if items[itemName] then
                        result[itemName] = result[itemName] + (itemData.amount or 0)
                    end
                end
                return result
            else
                local itemCount = 0
                for _, itemData in pairs(playerInventory) do
                    if tostring(itemData.name) == items then
                        itemCount = itemCount + (itemData.amount or 0)
                    end
                end
                return itemCount
            end
        end
    elseif inventorySystem == 'ox' then
        return function(items)
            if type(items) == 'table' then
                local itemArray = {}
                for k in pairs(items) do
                    itemArray[#itemArray + 1] = k
                end
                local returnedItems = exports[oxInv]:Search('count', itemArray)
                local result = {}
                for k, v in pairs(items) do
                    result[k] = returnedItems[k] or 0
                end
                return result
            else
                return exports[oxInv]:Search('count', items)
            end
        end
    elseif inventorySystem == 'tgiann' then
        return function(items)
            local playerInventory = exports[tgiannInv]:GetPlayerItems()
            local result = {}
        
            if type(items) == 'table' then
                -- Initialize result table with 0 for each item in `items`
                for k in pairs(items) do
                    result[k] = 0
                end
                
                -- Iterate through the player's inventory and count matching items
                for _, itemData in pairs(playerInventory or {}) do
                    local itemName = tostring(itemData.name or "")
                    if items[itemName] then
                        -- Use `count` if available, otherwise fall back to `amount`
                        local itemAmount = itemData.count or itemData.amount or 0
                        result[itemName] = result[itemName] + itemAmount
                    end
                end
                
                return result
            else
                -- Single item check
                local itemCount = 0
                for _, itemData in pairs(playerInventory or {}) do
                    if tostring(itemData.name or "") == tostring(items) then
                        -- Use `count` if available, otherwise fall back to `amount`
                        local itemAmount = itemData.count or itemData.amount or 0
                        itemCount = itemCount + itemAmount
                    end
                end
                
                return itemCount
            end
        end
        
        
    elseif Framework == 'esx' then
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
    elseif Framework == 'qb' then
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
        return function() return 0 end
    end
end

local HasItemInInventory = HasItem()

-- Assign the dynamically selected function to SD.Inventory.HasItem
SD.Inventory.HasItem = function(items)
    return HasItemInInventory(items)
end

return SD.Inventory
