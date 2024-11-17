--- @class SD.Inventory
SD.Inventory = {}

local inventorySystem
local codemInv = 'codem-inventory' -- Variable to store the string name codem-inventory
local oxInv = 'ox_inventory' -- Variable to store the string name ox_inventory

if GetResourceState(codemInv) == 'started' then
    inventorySystem = 'codem'
elseif GetResourceState(oxInv) == 'started' then
    inventorySystem = 'ox'
end

--- Dynamically selects the appropriate function to check if a player has an item.
--- @return function The function to check if a player has an item.
local HasItem = function()
    if inventorySystem == 'codem' then
        return function(player, item, source)
            return exports[codemInv]:GetItemsTotalAmount(source, item)
        end
    elseif inventorySystem == 'ox' then
        return function(player, item, source)
            return exports[oxInv]:Search(source, 'count', item)
        end
    else
        if Framework == 'esx' then
            return function(player, item)
                local itemData = player.getInventoryItem(item)
                if itemData then return itemData.count or itemData.amount else return 0 end
            end
        elseif Framework == 'qb' then
            return function(player, item)
                local itemData = player.Functions.GetItemByName(item)
                if itemData then return itemData.amount or itemData.count else return 0 end
            end
        else
            return function()
                error("Unsupported framework or inventory state for HasItem.")
            end
        end
    end
end

local CheckInventory = HasItem()

--- Dynamically selects the appropriate function to check if a player can carry an item.
--- @return function The function to check if a player can carry an item.
local CanCarryItem = function()
    if inventorySystem == 'codem' then
        return function(player, item, count, metadata, source)
            return true
        end
    elseif inventorySystem == 'ox' then
        return function(player, item, count, metadata, source)
            return exports[oxInv]:CanCarryItem(source, item, count, metadata)
        end
    else
        if Framework == 'esx' then
            return function(player, item, count)
                local currentItem = player.getInventoryItem(item)
                if currentItem then
                    local newWeight = player.getWeight() + (currentItem.weight * count)
                    return newWeight <= player.getMaxWeight()
                end
                return false
            end
        elseif Framework == 'qb' then
            return function(player, item, count)
                local totalWeight = QBCore.Player.GetTotalWeight(player.PlayerData.items)
                if not totalWeight then return false end
                local itemInfo = QBCore.Shared.Items[item:lower()]
                if not itemInfo then return false end
                if (totalWeight + (itemInfo['weight'] * count)) <= 120000 then
                    return true
                end
                return false 
            end
        else
            return function()
                error("Unsupported framework for CanCarryItem.")
            end
        end
    end
end

local CanCarry = CanCarryItem()

--- Dynamically selects the appropriate function to add an item to a player's inventory.
--- @return function The function to add an item.
local AddItem = function()
    if inventorySystem == 'codem' then
        return function(player, item, count, metadata, slot, source)
            return exports[codemInv]:AddItem(source, item, count, slot, metadata)
        end
    elseif inventorySystem == 'ox' then
        return function(player, item, count, metadata, slot, source)
            return exports[oxInv]:AddItem(source, item, count, metadata, slot)
        end
    else
        if Framework == 'esx' then
            return function(player, item, count, metadata, slot)
                player.addInventoryItem(item, count, metadata, slot)
            end
        elseif Framework == 'qb' then
            return function(player, item, count, metadata, slot, source)
                player.Functions.AddItem(item, count, slot, metadata)
                TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], 'add', count)
            end
        else
            return function()
                error("Unsupported framework or inventory state for AddItem.")
            end
        end
    end
end

local AddItemToInventory = AddItem()

--- Dynamically selects the appropriate function to remove an item from a player's inventory.
--- @return function The function to remove an item.
local RemoveItem = function()
    if inventorySystem == 'codem' then
        return function(player, item, count, metadata, slot, source)
            return exports[codemInv]:RemoveItem(source, item, count, slot)
        end
    elseif inventorySystem == 'ox' then
        return function(player, item, count, metadata, slot, source)
            return exports[oxInv]:RemoveItem(source, item, count, metadata, slot)
        end
    else
        if Framework == 'esx' then
            return function(player, item, count, metadata, slot)
                player.removeInventoryItem(item, count, metadata, slot)
            end
        elseif Framework == 'qb' then
            return function(player, item, count, slot, metadata, source)
                player.Functions.RemoveItem(item, count, slot, metadata)
                TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], "remove", count)
            end
        else
            return function()
                error("RemoveItem function is not supported in the current framework.")
            end
        end
    end
end

local RemoveItemFromInventory = RemoveItem()

--- Dynamically selects the appropriate function to register a usable item.
--- @return function The function to register a usable item.
local RegisterUsableItem = function()
    if inventorySystem == 'ox' then
        return function(item, cb)
            local exportName = 'use' .. item:gsub("^%l", string.upper)
            exports(exportName, function(event, item, inventory, slot, data)
                if event == 'usingItem' then
                    cb(inventory.id, item, inventory, slot, data)
                end
            end)
        end
    else
        if Framework == 'esx' then
            return function(item, cb)
                ESX.RegisterUsableItem(item, cb)
            end
        elseif Framework == 'qb' then
            return function(item, cb)
                QBCore.Functions.CreateUseableItem(item, cb)
            end
        else
            return function(item, cb)
                error("RegisterUsableItem function is not supported in the current framework.")
            end
        end
    end
end

local RegisterUsableItemInInventory = RegisterUsableItem()

--- Registers a function to be called when a player uses an item.
--- @param item string The item's name.
--- @param cb function The callback function to execute when the item is used.
SD.Inventory.RegisterUsableItem = function(item, cb)
    RegisterUsableItemInInventory(item, cb)
end

--- Returns the amount of a specific item a player has.
--- @param source number The player's server ID.
--- @param item string The item's name.
--- @return number The amount of the specified item the player has.
SD.Inventory.HasItem = function(source, item)
    local player = SD.GetPlayer(source)
    if player == nil then return 0 end
    return CheckInventory(player, item, source)
end

--- Checks if a player can carry an item.
--- @param source number The player's server ID.
--- @param item string The item's name.
--- @param count number The amount of the item to check.
--- @param slot number|nil The inventory slot, if applicable.
--- @param metadata table|nil Additional metadata for the item, if applicable.
--- @return boolean True if the player can carry the item, false otherwise.
SD.Inventory.CanCarry = function(source, item, count, slot, metadata)
    local player = SD.GetPlayer(source)
    if player then
        return CanCarry(player, item, count, slot, source)
    end
    return false
end

--- Adds an item to a player's inventory.
--- @param source number The player's server ID.
--- @param item string The item's name.
--- @param count number The amount of the item to add.
--- @param slot number|nil The inventory slot to add the item to, if applicable.
--- @param metadata table|nil Additional metadata for the item, if applicable.
SD.Inventory.AddItem = function(source, item, count, slot, metadata)
    local player = SD.GetPlayer(source)
    if player then
        AddItemToInventory(player, item, count, metadata, slot, source)
    end
end

--- Removes an item from a player's inventory.
--- @param source number The player's server ID.
--- @param item string The item's name.
--- @param count number The amount of the item to remove.
--- @param slot number|nil The inventory slot to remove the item from, if applicable.
--- @param metadata table|nil Additional metadata for the item, if applicable.
SD.Inventory.RemoveItem = function(source, item, count, slot, metadata)
    local player = SD.GetPlayer(source)
    if player then
        RemoveItemFromInventory(player, item, count, metadata, slot, source)
    end
end

return SD.Inventory
