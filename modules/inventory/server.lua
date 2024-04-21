--- @class SD.Inventory
SD.Inventory = {}

local ox_inventory = 'ox_inventory' -- Variable to store the name for ox_inventory, case changed.
local invState = GetResourceState('ox_inventory') -- Check if ox_inventory is started.

-- Function to dynamically select the appropriate AddItem function based on the current configuration.
local HasItem = function()
    -- If using a custom inventory like 'ox_inventory'.
    if invState == 'started' then
        return function(player, item)
            -- Direct call to 'ox_inventory' export for item count.
            return exports[ox_inventory]:Search(source, 'count', item)
        end
    else
        -- Framework-specific item check functions.
        if Framework == 'esx' then
            return function(player, item)
                -- ESX inventory check.
                local item = player.getInventoryItem(item)
                return item.count or item.amount
            end
        elseif Framework == 'qb' then
            return function(player, item)
                -- QB-Core inventory check.
                local item = player.Functions.GetItemByName(item)
                return item.amount or item.count
            end
        else
            -- Fallback for unsupported frameworks or configurations.
            return function()
                error("Unsupported framework or inventory state for HasItem.")
            end
        end
    end
end

-- Utilize the dynamically selected function for checking items in the inventory.
local CheckInventory = HasItem()

-- Function to dynamically select the appropriate AddItem function based on the current configuration.
local AddItem = function()
    if invState == 'started' then
        -- Integration with ox_inventory
        return function(player, item, count, metadata, slot)
            return exports[ox_inventory]:AddItem(source, item, count, metadata, slot)
        end
    else
        -- Framework-specific functions
        if Framework == 'esx' then
            return function(player, item, count, metadata, slot)
                player.addInventoryItem(item, count, metadata, slot)
            end
        elseif Framework == 'qb' then
            return function(player, item, count, metadata, slot)
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

-- Utilize the dynamically selected function for adding items to the inventory.
local AddItemToInventory = AddItem()

-- Function to dynamically select the appropriate AddWeapon function based on the current configuration.
local AddWeapon = function()
    if Framework == 'esx' then
        -- ESX framework weapon addition logic.
        return function(player, weapon, ammo)
            player.addWeapon(weapon, ammo)
        end
    elseif Framework == 'qb' then
        return function(player, weapon, ammo)
            -- Example: player.Functions.AddWeapon(weapon, ammo)
            error("AddWeapon function for QB-Core needs customization.")
        end
    else
        -- Fallback or error for unsupported frameworks.
        return function()
            error("AddWeapon function is not supported in the current framework.")
        end
    end
end

-- Utilize the dynamically selected function for adding items to the inventory.
local AddWeaponToInventory = AddWeapon()

-- Function to dynamically select the appropriate RemoveItem function based on the current configuration.
local RemoveItem = function()
    if invState == 'started' then
        -- Integration with 'ox_inventory' for removing an item.
        return function(player, item, count, metadata, slot)
            return exports[ox_inventory]:RemoveItem(source, item, count, metadata, slot)
        end
    else
        -- Framework-specific item removal functions.
        if Framework == 'esx' then
            return function(player, item, count, metadata, slot)
                player.removeInventoryItem(item, count, metadata, slot)
            end
        elseif Framework == 'qb' then
            return function(player, item, count, slot, metadata)
                player.Functions.RemoveItem(item, count, slot, metadata)
                TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], "remove", count)
            end
        else
            -- Fallback or error for unsupported frameworks.
            return function()
                error("RemoveItem function is not supported in the current framework.")
            end
        end
    end
end

-- Utilize the dynamically selected function for removing items to the inventory.
local RemoveItemFromInventory = RemoveItem()

--- Registers a function to be called when a player uses an item.
-- @param item string The item's name.
-- @param cb function The callback function to execute when the item is used.
SD.Inventory.RegisterUsableItem = function(item, cb)
    if Framework == 'esx' then
        ESX.RegisterUsableItem(item, cb)
    elseif Framework == 'qb' then
        QBCore.Functions.CreateUseableItem(item, cb)
    end
end

--- Returns the amount of a specific item a player has.
-- @param source number The player's server ID.
-- @param item string The item's name.
-- @return number The amount of the specified item the player has.
SD.Inventory.HasItem = function(source, item)
    local player = SD.GetPlayer(source)
    if player == nil then return 0 end

    return CheckInventory(player, item)  -- Custom internal function to check inventory.
end

--- Adds an item to a player's inventory.
-- @param source number The player's server ID.
-- @param item string The item's name.
-- @param count number The amount of the item to add.
-- @param slot number|nil The inventory slot to add the item to, if applicable.
-- @param metadata table|nil Additional metadata for the item, if applicable.
SD.Inventory.AddItem = function(source, item, count, slot, metadata)
    local player = SD.GetPlayer(source)
    if player then AddItemToInventory(player, item, count, slot, metadata)  -- Custom internal function to add items.
    end
end

--- Adds a weapon to a player's inventory.
-- @param source number The player's server ID.
-- @param weapon string The weapon's name.
-- @param ammo number The amount of ammo for the weapon.
SD.Inventory.AddWeapon = function(source, weapon, ammo)
    local player = SD.GetPlayer(source)
    if player then AddWeaponToInventory(player, weapon, ammo)  -- Custom internal function to add weapons.
    end
end

--- Removes an item from a player's inventory.
-- @param source number The player's server ID.
-- @param item string The item's name.
-- @param count number The amount of the item to remove.
-- @param slot number|nil The inventory slot to remove the item from, if applicable.
-- @param metadata table|nil Additional metadata for the item, if applicable.
SD.Inventory.RemoveItem = function(source, item, count, slot, metadata)
    local player = SD.GetPlayer(source)
    if player then RemoveItemFromInventory(player, item, count, slot, metadata)  -- Custom internal function to remove items.
    end
end

return SD.Inventory