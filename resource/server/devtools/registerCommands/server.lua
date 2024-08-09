-- Register Development Commands
SD.RegisterCommand("copypos", "command.copypos", function(source, args, rawCommand)
    -- Trigger the client event with the provided arguments
    TriggerClientEvent('sd_lib:copyPos', source, args)
end, "Copy the player's position or an object's coordinates.", {
    {name = "vecType", help = "The vector type (vector2, vector3 or vector4)", type = "string", optional = true},
    {name = "format", help = "The format (string or table, default: 'string')", type = "string", optional = true},
    {name = "useRaycast", help = "Use raycast (true/false)", type = "string", optional = true},
    {name = "copyObject", help = "Copy object coordinates (true/false)", type = "string", optional = true}
})

SD.RegisterCommand("getidentifier", "command.getidentifier", function(source, args, rawCommand)
    -- Determine target source (self if not provided)
    local targetSource = tonumber(args.target) or source
    local identifier = SD.GetIdentifier(targetSource)
    
    if identifier then
        TriggerClientEvent('sd_bridge:notification', source, 'Identifier: ' .. identifier, 'success')
        print('Identifier for player ' .. targetSource .. ': ' .. identifier)
    else
        TriggerClientEvent('sd_bridge:notification', source, 'Player not found.', 'error')
        print('Player not found: ' .. targetSource)
    end
end, "Get the identifier of the target player.", {
    {name = "target", help = "The player source ID to get the identifier for (optional)", type = "string", optional = true}
})

-- Register the placeobject command with ace permission check.
SD.RegisterCommand("placeobject", "command.placeobject", function(source, args, rawCommand)
    local model = args.model or 'prop_weed_block_01'
    local format = args.format or 'string'
    local params = {
        model = model,
        format = format
    }
    -- Start the object placement process.
    TriggerClientEvent('sd_lib:placeObject', source, params)
end, "Place an object at the specified location.", {
    {name = "model", help = "The model of the object to place (default: 'prop_weed_block_01')", type = "string", optional = true},
    {name = "format", help = "The format to copy (string or table, default: 'string')", type = "string", optional = true}
})

-- Register clearprops command
SD.RegisterCommand("clearprops", "command.clearprops", function(source, args, rawCommand)
    TriggerClientEvent('sd_lib:clearprops', source)
end, "Clear all placed objects.", {})