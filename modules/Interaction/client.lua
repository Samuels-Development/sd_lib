--- @class SD.Interaction
SD.Interaction = {}

SD.Zones = {} -- Table to store zones
SD.Entities = {} -- Table to store entities

-- Function to add a box zone
---@param interactType string The interaction type ('textui' or 'target').
---@param name string The name of the zone.
---@param coords vector3 The coordinates of the zone.
---@param length number The length of the box zone.
---@param width number The width of the box zone.
---@param options table The options for interaction.
---@param debug boolean Enable debugging for the zone.
SD.Interaction.AddBoxZone = function(interactType, name, coords, length, width, options, debug)
    if interactType == 'textui' then
        if #options.options > 1 then
            SD.TextUI.AddScrollablePoint(name, coords, options.options, math.max(length, width))
        else
            local interaction = options.options[1]
            SD.TextUI.AddPoint(name, coords, interaction.label, interaction.action or interaction.event, interaction.canInteract, math.max(length, width))
        end
    else
        local handler = SD.Target.AddBoxZone(name, coords, length, width, options, debug)
        SD.Zones[name] = handler
        return handler
    end
end

-- Function to add a circle zone
---@param interactType string The interaction type ('textui' or 'target').
---@param name string The name of the zone.
---@param coords vector3 The coordinates of the zone.
---@param radius number The radius of the circle zone.
---@param options table The options for interaction.
---@param debug boolean Enable debugging for the zone.
SD.Interaction.AddCircleZone = function(interactType, name, coords, radius, options, debug)
    if interactType == 'textui' then
        if #options.options > 1 then
            SD.TextUI.AddScrollablePoint(name, coords, options.options, radius)
        else
            local interaction = options.options[1]
            SD.TextUI.AddPoint(name, coords, interaction.label, interaction.action or interaction.event, interaction.canInteract, radius)
        end
    else
        local handler = SD.Target.AddCircleZone(name, coords, radius, options, debug)
        SD.Zones[name] = handler
        return handler
    end
end

-- Function to add a target entity
---@param interactType string The interaction type ('textui' or 'target').
---@param entity number The entity to target.
---@param options table The options for interaction.
SD.Interaction.AddTargetEntity = function(interactType, entity, options)
    if interactType == 'textui' then
        SD.TextUI.AddTargetEntity(entity, {
            label = options.options[1].label,
            action = options.options[1].action or options.options[1].event,
            canInteract = options.options[1].canInteract,
            distance = options.distance
        })
        SD.Entities[entity] = true
    else
        SD.Target.AddTargetEntity(entity, options)
        SD.Entities[entity] = true
    end
end

-- Function to remove a target entity
---@param entity number The entity to remove.
SD.Interaction.RemoveTargetEntity = function(entity)
    if SD.Entities[entity] then
        SD.TextUI.RemoveTargetEntity(entity)
        SD.Target.RemoveTargetEntity(entity)
        SD.Entities[entity] = nil
    end
end

-- Function to remove a specific zone
---@param name string The name of the zone to remove.
SD.Interaction.RemoveZone = function(name)
    if SD.Zones[name] then
        SD.Target.RemoveZone(SD.Zones[name])
        SD.Zones[name] = nil
    elseif SD.TextUI.Points[name] then
        SD.TextUI.RemovePoint(SD.TextUI.Points[name].coords)
        SD.TextUI.Points[name] = nil
    end
end

-- Function to remove all zones
SD.Interaction.RemoveAllZones = function()
    if next(SD.Zones) ~= nil then
        for name, handler in pairs(SD.Zones) do
            SD.Target.RemoveZone(handler)
        end
        SD.Zones = {}
    end
end

-- Event handler to remove zones on resource stop
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SD.Interaction.RemoveAllZones()
    end
end)

return SD.Interaction