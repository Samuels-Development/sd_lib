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

SetTimeout(1000, function()
    TriggerClientEvent('chat:addSuggestions', -1, registeredCommands)
end)

-- Adds the ace to the principal.
local AddAce = function(principal, ace, allow)
    if type(principal) == 'number' then
        principal = 'player.'..principal
    end

    ExecuteCommand(('add_ace %s %s %s'):format(principal, ace, allow and 'allow' or 'deny'))
end

-- Registers a command with optional ace permissions and adds chat suggestions.
---@param command string The command identifier to be registered.
---@param permission string|table|nil The required ace permission(s) to execute the command (optional).
---@param callback function The function to be called when the command is executed.
---@param help string Optional help text for the command (optional).
---@param params table Optional parameters for the command (optional).
SD.RegisterCommand = function(command, permission, callback, help, params)
    -- Validate the command identifier.
    if type(command) ~= 'string' then
        error(("Invalid command identifier '%s'. Expected a string."):format(tostring(command)))
    end

    -- Validate the callback function.
    if type(callback) ~= 'function' then
        error(("Invalid callback function for command '%s'. Expected a function."):format(command))
    end

    -- Command handler
    local commandHandler = function(source, args, rawCommand)
        local parsedArgs = ParseArguments(args, params)
        if not parsedArgs then
            TriggerClientEvent('sd_bridge:notification', source, ("Invalid command arguments for command '%s'. Expected: %s"):format(command, json.encode(params)), 'error')
            return
        end

        local success, err = pcall(callback, source, parsedArgs, rawCommand)
        if not success then
            Citizen.Trace(("^1Command '%s' failed to execute!\n%s^0"):format(command, err))
            TriggerClientEvent('sd_bridge:notification', source, ("Command '%s' failed to execute."):format(command), 'error')
        end
    end

    -- Register the command, applying restriction only if permission is provided
    print(permission and true or false)
    RegisterCommand(command, commandHandler, permission and true or false)

    -- Add the command to chat suggestions if help text or parameters are provided.
    if help or params then
        local suggestion = {name = '/' .. command, help = help or ""}
        if params then
            suggestion.params = params
        end
        TriggerClientEvent('chat:addSuggestions', -1, {suggestion})
        table.insert(registeredCommands, suggestion)
    end

    -- If a permission is specified, register it in ACE.
    if permission then
        local ace = ('command.%s'):format(command)
        local restrictedType = type(permission)

        if restrictedType == 'string' and not IsPrincipalAceAllowed(permission, ace) then
            AddAce(permission, ace, true)
        elseif restrictedType == 'table' then
            for _, perm in ipairs(permission) and not IsPrincipalAceAllowed(permission, ace) do
                AddAce(perm, ace, true)
            end
        end
    end
end

return SD.RegisterCommand