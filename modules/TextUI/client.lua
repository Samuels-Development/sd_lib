--- @class SD.TextUI
SD.TextUI = {}

local EnableOX = true -- Enable use of ox_lib for TextUI if available
local lastInteractionTime = 0

-- Function to dynamically select the appropriate show and hide functions based on the current configuration.
local TextUI = function()
    if lib ~= nil and EnableOX then
        return function(text, options)
            lib.showTextUI(text, options)
        end, function()
            lib.hideTextUI()
        end
    elseif GetResourceState('cd_drawtextui') == 'started' then
        return function(text)
            TriggerEvent('cd_drawtextui:ShowUI', 'show', text)
        end, function()
            TriggerEvent('cd_drawtextui:HideUI')
        end
    elseif Framework == 'qb' then
        return function(text, options)
            exports['qb-core']:DrawText(text, options and options.position or 'left')
        end, function()
            exports['qb-core']:HideText()
        end
    else
        return function(text)
            error("TextUI system not supported. Text was: " .. text)
        end, function() end
    end
end

-- Initialize the show and hide functions
local ShowTextUI, HideTextUI = TextUI()

-- Table to store points
SD.TextUI.Points = {}
SD.TextUI.Models = {}
SD.TextUI.Entities = {}

--- Adds a point to the list of points.
---@param name string The unique name of the point.
---@param coords vector3 The coordinates of the point.
---@param message string|nil The message to display at the point.
---@param action string|function|nil The event to trigger or the function to call when the key is pressed.
---@param canInteract function|nil A function that returns true/false to determine if interaction is allowed.
---@param distance number The distance within which the interaction is allowed.
---@param options table|nil The options for interaction if multiple are available.
SD.TextUI.AddPoint = function(name, coords, message, action, canInteract, distance, options)
    table.insert(SD.TextUI.Points, { coords = coords, message = message, action = action, canInteract = canInteract, distance = distance, inside = false, secondaryThread = nil })
end

--- Adds a scrollable point to the list of points.
---@param name string The unique name of the point.
---@param coords vector3 The coordinates of the point.
---@param options table The options for interaction.
---@param distance number The distance within which the interaction is allowed.
SD.TextUI.AddScrollablePoint = function(name, coords, options, distance)
    SD.TextUI.Points[name] = {
        coords = coords,
        options = options,
        currentIndex = 1,
        distance = distance,
        inside = false,
        secondaryThread = nil
    }
end

--- Removes a point from the list of points.
---@param name string The unique name of the point to remove.
SD.TextUI.RemovePoint = function(name)
    local point = SD.TextUI.Points[name]
    if point then
        if point.secondaryThread then
            TerminateThread(point.secondaryThread)
            point.secondaryThread = nil
        end
        SD.TextUI.Hide()
        point.inside = false
        SD.TextUI.Points[name] = nil
    end
end

--- Adds a target for specific entities.
---@param entity number The entity to target.
---@param options table The options for interaction.
SD.TextUI.AddTargetEntity = function(entity, options)
    SD.TextUI.Entities[entity] = options
end

--- Removes a target entity.
---@param entity number The entity to remove.
SD.TextUI.RemoveTargetEntity = function(entity)
    if SD.TextUI.Entities[entity] then
        if SD.TextUI.Entities[entity].secondaryThread then
            TerminateThread(SD.TextUI.Entities[entity].secondaryThread)
            SD.TextUI.Entities[entity].secondaryThread = nil
        end
        SD.TextUI.Hide()
        SD.TextUI.Entities[entity].inside = false
        SD.TextUI.Entities[entity] = nil
    end
end

--- Shows the TextUI with the given text and options.
---@param text string The text to display.
---@param options table|nil Options for displaying the text.
SD.TextUI.Show = function(text, options)
    ShowTextUI(text, options)
end

--- Hides the TextUI.
SD.TextUI.Hide = function()
    HideTextUI()
end

CreateThread(function()
    while true do
        local coords = GetEntityCoords(PlayerPedId())
        local closestPoint = nil
        local closestEntity = nil

        -- Check points
        for name, point in pairs(SD.TextUI.Points) do
            local distance = #(coords - point.coords)
            if distance <= point.distance and (not point.canInteract or point.canInteract()) then
                closestPoint = point
                break
            elseif point.inside then
                point.inside = false
                SD.TextUI.Hide()
                if point.secondaryThread then
                    TerminateThread(point.secondaryThread)
                    point.secondaryThread = nil
                end
            end
        end

        -- Check entities
        for entity, options in pairs(SD.TextUI.Entities) do
            if DoesEntityExist(entity) then
                local entityCoords = GetEntityCoords(entity)
                local distance = #(coords - entityCoords)
                if distance <= options.distance and (not options.canInteract or options.canInteract(entity)) then
                    closestEntity = { entity = entity, options = options }
                    break
                elseif options.inside then
                    options.inside = false
                    SD.TextUI.Hide()
                    if options.secondaryThread then
                        TerminateThread(options.secondaryThread)
                        options.secondaryThread = nil
                    end
                end
            elseif options.inside then
                options.inside = false
                SD.TextUI.Hide()
                if options.secondaryThread then
                    TerminateThread(options.secondaryThread)
                    options.secondaryThread = nil
                end
            end
        end

        if closestPoint then
            if not closestPoint.inside then
                closestPoint.inside = true
                if closestPoint.options then
                    local displayText = string.format("[E] %s  %s", closestPoint.options[closestPoint.currentIndex].label, "↕")
                    SD.TextUI.Show(displayText, { position = 'right-center' })
                    closestPoint.secondaryThread = CreateThread(function()
                        while closestPoint.inside do
                            if IsControlJustReleased(0, 38) then -- E key
                                local currentTime = GetGameTimer()
                                if currentTime - lastInteractionTime >= 5000 then
                                    lastInteractionTime = currentTime
                                    local selectedOption = closestPoint.options[closestPoint.currentIndex]
                                    if type(selectedOption.event) == "string" then
                                        TriggerEvent(selectedOption.event)
                                    elseif type(selectedOption.action) == "function" then
                                        selectedOption.action()
                                    end
                                end
                            elseif IsControlJustReleased(0, 241) then -- Scroll Wheel Up
                                closestPoint.currentIndex = (closestPoint.currentIndex - 2) % #closestPoint.options + 1
                                SD.TextUI.Show(string.format("[E] %s  %s", closestPoint.options[closestPoint.currentIndex].label, "↕"), { position = 'right-center' })
                            elseif IsControlJustReleased(0, 242) then -- Scroll Wheel Down
                                closestPoint.currentIndex = closestPoint.currentIndex % #closestPoint.options + 1
                                SD.TextUI.Show(string.format("[E] %s  %s", closestPoint.options[closestPoint.currentIndex].label, "↕"), { position = 'right-center' })
                            end
                            Wait(0) -- Check every frame
                        end
                    end)
                else
                    local displayText = string.format("[E] %s", closestPoint.message)
                    SD.TextUI.Show(displayText, { position = 'right-center' })
                    closestPoint.secondaryThread = CreateThread(function()
                        while closestPoint.inside do
                            if IsControlJustReleased(0, 38) then -- E key
                                local currentTime = GetGameTimer()
                                if currentTime - lastInteractionTime >= 5000 then
                                    lastInteractionTime = currentTime
                                    if type(closestPoint.action) == "string" then
                                        TriggerEvent(closestPoint.action or closestPoint.event)
                                    elseif type(closestPoint.action) == "function" then
                                        closestPoint.action()
                                    end
                                end
                            end
                            Wait(0) -- Check every frame
                        end
                    end)
                end
            end
        elseif closestEntity then
            if not closestEntity.options.inside then
                closestEntity.options.inside = true
                local displayText = string.format("[E] %s", closestEntity.options.label)
                SD.TextUI.Show(displayText, { position = 'right-center' })
                closestEntity.options.secondaryThread = CreateThread(function()
                    while closestEntity.options.inside do
                        if IsControlJustReleased(0, 38) then -- E key
                            local currentTime = GetGameTimer()
                            if currentTime - lastInteractionTime >= 5000 then
                                lastInteractionTime = currentTime
                                if type(closestEntity.options.action) == "string" then
                                    TriggerEvent(closestEntity.options.action)
                                elseif type(closestEntity.options.action) == "function" then
                                    closestEntity.options.action(closestEntity.entity)
                                end
                            end
                        end
                        Wait(0) -- Check every frame
                    end
                end)
            end
        end

        -- Clean up removed entities from SD.TextUI.Entities table
        for entity in pairs(SD.TextUI.Entities) do
            if not DoesEntityExist(entity) then
                SD.TextUI.Entities[entity] = nil
            end
        end

        Wait(500) -- Check every 500 ms.
    end
end)

return SD.TextUI