--- @class SD.Interaction
SD.Interaction = {}

-- Function to add a circle zone
---@param interactType string The interaction type ('textui' or 'target').
---@param name string The name of the zone.
---@param coords vector3 The coordinates of the zone.
---@param radius number The radius of the circle zone.
---@param options table The options for interaction.
---@param debug boolean Enable debugging for the zone.
SD.Interaction.AddCircleZone = function(interactType, name, coords, radius, options, debug)
    if interactType == 'textui' then
        SD.TextUI.AddPoint(coords, options.options[1].label, options.options[1].action, options.options[1].canInteract, radius)
    else
        SD.Target.AddCircleZone(name, coords, radius, options, debug)
    end
end

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
        SD.TextUI.AddPoint(coords, options.options[1].label, options.options[1].action, options.options[1].canInteract, math.max(length, width))
    else
        SD.Target.AddBoxZone(name, coords, length, width, options, debug)
    end
end

-- Function to add a target model
---@param interactType string The interaction type ('textui' or 'target').
---@param models table The models to target.
---@param options table The options for interaction.
SD.Interaction.AddTargetModel = function(interactType, models, options)
    if interactType == 'textui' then
        SD.TextUI.AddTargetModel(models, options)
    else
        SD.Target.AddTargetModel(models, options)
    end
end

-- Function to add a target entity
---@param interactType string The interaction type ('textui' or 'target').
---@param entity number The entity to target.
---@param options table The options for interaction.
SD.Interaction.AddTargetEntity = function(interactType, entity, options)
    if interactType == 'textui' then
        SD.TextUI.AddTargetEntity(entity, options)
    else
        SD.Target.AddTargetEntity(entity, options)
    end
end

return SD.Interaction