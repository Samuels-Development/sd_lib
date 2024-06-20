--- Table of supported inventory systems.
local inventories = { {name = "ox_inventory"}, {name = "qs-inventory"}, {name = "qb-inventory"}, {name = "ps-inventory"}, {name = "lj-inventory"} }

--- Selects and returns the most appropriate function for retrieving item image paths
-- based on the configured inventory system. This approach abstracts inventory-specific paths
-- into a unified interface, facilitating a clean and maintainable way to interact
-- with item images across different inventory systems.
---@return function A function that, when called with an item name, returns the corresponding file path for the item's image.
local SelectInventoryImagePath = function()
    for _, resource in ipairs(inventories) do
        if GetResourceState(resource.name) == 'started' then
            if resource.name == "ox_inventory" then
                return function(item)
                    return string.format("nui://%s/web/images/%s.png", resource.name, item)
                end
            elseif resource.name == "qb-inventory" or resource.name == "lj-inventory" or resource.name == "ps-inventory" or resource.name == "qs-inventory" then
                return function(item)
                    return string.format("nui://%s/html/images/%s.png", resource.name, item)
                end
            end
        end
    end

    -- Fallback function for unsupported or no started inventory systems.
    return function(item)
        error(string.format("Unsupported inventory system. Unable to retrieve image path for item: %s", item))
        return nil
    end
end

-- Assign the dynamically selected function to SD.GetItemImage
local GetImagePathForItem = SelectInventoryImagePath()

--- Retrieves the file path for an item's image, abstracting inventory-specific path logic.
--- This function serves as a wrapper that calls a pre-defined function based on the current inventory system,
--- optimized for performance by determining the appropriate function during script initialization.
---@param item string The name of the item to retrieve the image path for.
---@return string|nil Returns the file path for the item's image if found; returns nil if an error occurs.
SD.GetItemImage = function(item)
    return GetImagePathForItem(item)
end

return SD.GetItemImage