--- @class SD.Inventory
SD.Inventory = {}

local inventorySystem
local codemInv   = 'codem-inventory'
local oxInv      = 'ox_inventory'
local qsProInv   = 'qs-inventory-pro'
local origenInv  = 'origen_inventory'

if GetResourceState(codemInv) == 'started' then
    inventorySystem = 'codem'
elseif GetResourceState(oxInv) == 'started' then
    inventorySystem = 'ox'
elseif GetResourceState(qsProInv) == 'started' then
    inventorySystem = 'qs-pro'
elseif GetResourceState(origenInv) == 'started' then
    inventorySystem = 'origen'
end

--- Dynamic selection function to determine how to check for item existence.
local HasItem = function()
    if inventorySystem == 'codem' then
        return function(items)
            local playerInventory = exports[codemInv]:getUserInventory()
            local result = {}
            if type(items) == 'table' then
                for k in pairs(items) do result[k] = 0 end
                for _, itemData in pairs(playerInventory) do
                    local name = tostring(itemData.name)
                    if items[name] then
                        result[name] = result[name] + (itemData.amount or 0)
                    end
                end
                return result
            else
                local count = 0
                for _, itemData in pairs(playerInventory) do
                    if tostring(itemData.name) == items then
                        count = count + (itemData.amount or 0)
                    end
                end
                return count
            end
        end

    elseif inventorySystem == 'ox' then
        return function(items)
            if type(items) == 'table' then
                local keys, result = {}, {}
                for k in pairs(items) do keys[#keys+1] = k; result[k] = 0 end
                local returned = exports[oxInv]:Search('count', keys)
                for k in pairs(items) do
                    result[k] = returned[k] or 0
                end
                return result
            else
                return exports[oxInv]:Search('count', items)
            end
        end

    elseif inventorySystem == 'qs-pro' then
        return function(items)
            local playerInventory = exports[qsProInv]:getUserInventory()
            if type(items) == 'table' then
                local result = {}
                for k in pairs(items) do result[k] = 0 end
                for _, itemData in pairs(playerInventory) do
                    local name = tostring(itemData.name)
                    if items[name] then
                        result[name] = result[name] + (itemData.count or itemData.amount or 0)
                    end
                end
                return result
            else
                local total = 0
                for _, itemData in pairs(playerInventory) do
                    if tostring(itemData.name) == items then
                        total = total + (itemData.count or itemData.amount or 0)
                    end
                end
                return total
            end
        end

    elseif inventorySystem == 'origen' then
        return function(items)
            local playerInventory = exports[origenInv]:GetInventory()
            local result, count = {}, 0
            if type(items) == 'table' then
                for k in pairs(items) do result[k] = 0 end
                for _, itemData in pairs(playerInventory) do
                    local name = tostring(itemData.name)
                    if items[name] then
                        result[name] = result[name] + (itemData.amount or 0)
                    end
                end
                return result
            else
                for _, itemData in pairs(playerInventory) do
                    if tostring(itemData.name) == items then
                        count = count + (itemData.amount or 0)
                    end
                end
                return count
            end
        end

    elseif Framework == 'esx' then
        return function(items)
            local pd = ESX.GetPlayerData() or {}
            local inv = pd.inventory or {}
            local result, count = {}, 0
            if type(items) == 'table' then
                for k in pairs(items) do result[k] = 0 end
                for _, itemData in pairs(inv) do
                    if items[itemData.name] then
                        result[itemData.name] = (itemData.count or itemData.amount)
                    end
                end
                return result
            else
                for _, itemData in pairs(inv) do
                    if itemData.name == items then
                        return itemData.count or itemData.amount
                    end
                end
                return 0
            end
        end

    elseif Framework == 'qb' then
        return function(items)
            local pd = QBCore.Functions.GetPlayerData() or {}
            local inv = pd.items or {}
            if type(items) == 'table' then
                local result = {}
                for k in pairs(items) do result[k] = 0 end
                for _, itm in ipairs(inv) do
                    if items[itm.name] then
                        result[itm.name] = itm.amount or itm.count
                    end
                end
                return result
            else
                for _, itm in ipairs(inv) do
                    if itm.name == items then
                        return itm.amount or itm.count
                    end
                end
                return 0
            end
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