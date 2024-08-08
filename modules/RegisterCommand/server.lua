-- Function to parse command arguments based on defined parameters.
---@param args table The arguments provided to the command.
---@param params table The parameters definitions for the command.
---@return table? The parsed arguments or nil if validation failed.
local ParseArguments = function(args, params)
    if not params then return args end

    local parsedArgs = {}
    for i, param in ipairs(params) do
        local arg = args[i]
        if param.type == 'number' then
            parsedArgs[param.name] = tonumber(arg)
            if not parsedArgs[param.name] and not param.optional then return nil end
        elseif param.type == 'string' then
            parsedArgs[param.name] = arg
            if not parsedArgs[param.name] and not param.optional then return nil end
        elseif param.type == 'playerId' then
            parsedArgs[param.name] = arg == 'me' and source or tonumber(arg)
            if not parsedArgs[param.name] or not DoesPlayerExist(parsedArgs[param.name]) then
                if not param.optional then return nil end
            end
        elseif param.type == 'longString' then
            parsedArgs[param.name] = table.concat(args, " ", i)
            break
        else
            parsedArgs[param.name] = arg
            if not parsedArgs[param.name] and not param.optional then return nil end
        end
    end

    return parsedArgs
end

-- Storage for registered commands to send as suggestions.
local registeredCommands = {}

-- Initialize chat suggestions on player join.
AddEventHandler('playerJoining', function()
    TriggerClientEvent('chat:addSuggestions', source, registeredCommands)
end)

-- Registers a command with ace permissions and adds chat suggestions.
-- This function allows the registration of game commands with ace permissions checks
-- and provides chat suggestions for better command usage understanding.
---@param command string The command identifier to be registered.
---@param permission string The required ace permission to execute the command.
---@param callback function The function to be called when the command is executed.
---@param help string Optional help text for the command.
---@param params table Optional parameters for the command.
SD.RegisterCommand = function(command, permission, callback, help, params)
    -- Validate the command identifier.
    if type(command) ~= 'string' then
        error(("Invalid command identifier '%s'. Expected a string."):format(tostring(command)))
    end

    -- Validate the permission identifier.
    if type(permission) ~= 'string' then
        error(("Invalid permission identifier '%s'. Expected a string."):format(tostring(permission)))
    end

    -- Validate the callback function.
    if type(callback) ~= 'function' then
        error(("Invalid callback function for command '%s'. Expected a function."):format(command))
    end

    -- Register the command with the specified callback.
    RegisterCommand(command, function(source, args, rawCommand)
        -- Check if the source has the required permission.
        if IsPlayerAceAllowed(source, permission) then
            -- Execute the callback function with the provided arguments.
            local parsedArgs = ParseArguments(args, params)
            if not parsedArgs then
                TriggerEvent('sd_bridge:notification', source, ("Invalid command arguments for command '%s'. Expected: %s"):format(command, json.encode(params)), 'error')
                return
            end

            local success, err = pcall(callback, source, parsedArgs, rawCommand)
            if not success then
                Citizen.Trace(("^1Command '%s' failed to execute!\n%s^0"):format(command, err))
                TriggerEvent('sd_bridge:notification', source, ("Command '%s' failed to execute."):format(command), 'error')
            end
        else
            -- Notify the player about insufficient permissions.
            TriggerEvent('sd_bridge:notification', source, "You do not have permission to use this command.", 'error')
        end
    end, false)

    -- Add the command to chat suggestions.
    local suggestion = {name = '/' .. command, help = help or ""}
    if params then
        suggestion.params = params
    end
    TriggerClientEvent('chat:addSuggestions', -1, {suggestion})
    table.insert(registeredCommands, suggestion)
end

return SD.RegisterCommand