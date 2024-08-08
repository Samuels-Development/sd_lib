---@class SD.VectorCopy
SD.VectorCopy = {}

local previousEntity = nil

--- Converts a vector to a string format.
---@param vec vector2|vector3|vector4 The vector to convert.
---@param arg string The format type ('string' or 'table').
---@return string The string representation of the vector.
local VectorToString = function(vec, arg)
    if arg == 'string' then
        if vec.w then
            return string.format("vector4(%.2f, %.2f, %.2f, %.2f)", vec.x, vec.y, vec.z, vec.w)
        elseif vec.z then
            return string.format("vector3(%.2f, %.2f, %.2f)", vec.x, vec.y, vec.z)
        else
            return string.format("vector2(%.2f, %.2f)", vec.x, vec.y)
        end
    elseif arg == 'table' then
        if vec.w then
            return string.format("{ x = %.2f, y = %.2f, z = %.2f, w = %.2f }", vec.x, vec.y, vec.z, vec.w)
        elseif vec.z then
            return string.format("{ x = %.2f, y = %.2f, z = %.2f }", vec.x, vec.y, vec.z)
        else
            return string.format("{ x = %.2f, y = %.2f }", vec.x, vec.y)
        end
    end
end

--- Draws text on the screen.
-- This function draws text at the specified screen coordinates.
---@param text string The text to display.
---@param x number The x-coordinate on the screen.
---@param y number The y-coordinate on the screen.
local DrawText3D = function(text, x, y)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.35, 0.35)
    SetTextColour(255, 255, 255, 215)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

--- Copies a vector to the user's clipboard using NUI.
---@param text string The text to copy to the clipboard.
local CopyToClipboard = function(text)
    SendNUIMessage({
        type = 'copyToClipboard',
        text = text
    })
    print("Copied to clipboard: " .. text)
    SD.ShowNotification('Coordinates ' .. text .. ' copied to clipboard.', 'success')
end

--- Converts a vector to a string format and copies it to the clipboard.
---@param vec vector2|vector3|vector4 The vector to convert and copy.
---@param arg string The format type ('string' or 'table').
local CopyVectorToClipboard = function(vec, arg)
    local str = VectorToString(vec, arg)
    CopyToClipboard(str)
end

--- Gets the player's current position as a vector2, vector3, or vector4.
---@param vecType string The type of vector ('vector2', 'vector3', or 'vector4').
---@return vector2|vector3|vector4 The player's current position as the specified vector type.
local GetPlayerPosition = function(vecType)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    if vecType == 'vector4' then
        return vector4(pos.x, pos.y, pos.z, heading)
    elseif vecType == 'vector3' then
        return vector3(pos.x, pos.y, pos.z)
    elseif vecType == 'vector2' then
        return vector2(pos.x, pos.y)
    end
end

--- Converts a rotation vector to a direction vector.
-- This function converts rotation angles (in degrees) to a normalized direction vector.
---@param rotation vector3 The rotation angles (x, y, z).
---@return vector3 The normalized direction vector.
local RotationToDirection = function(rotation)
    local adjustedRotation = {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction = {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

--- Performs a raycast from the gameplay camera.
-- This function performs a raycast in the direction the gameplay camera is facing.
---@param distance number The maximum distance for the raycast.
---@return boolean, vector3, number Whether the raycast hit something, the coordinates of the hit, and the entity hit.
local RayCastGamePlayCamera = function(distance)
    local cameraRotation = GetGameplayCamRot(2)
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination = {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    local rayHandle = StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 7)
    local _, hit, coords, _, entity = GetShapeTestResult(rayHandle)
    return hit, coords, entity
end

--- Performs a raycast and gets the hit position.
---@return vector3, number The position where the raycast hit and the entity hit.
local GetRaycastPosition = function()
    local hit, coords, entity = RayCastGamePlayCamera(20.0)
    if hit then
        return coords, entity
    else
        return nil, nil
    end
end

--- Draws a line from the player to the raycast hit position.
---@param startPos vector3 The starting position of the line.
---@param endPos vector3 The ending position of the line.
local DrawRaycastLine = function(startPos, endPos)
    if #(startPos - endPos) <= 20.0 then
        DrawLine(startPos.x, startPos.y, startPos.z, endPos.x, endPos.y, endPos.z, 128, 0, 128, 255)
    end
end

--- Highlights an entity by drawing an outline.
---@param entity number The entity to highlight.
local HighlightEntity = function(entity)
    if DoesEntityExist(entity) then
        SetEntityDrawOutline(entity, true)
        SetEntityDrawOutlineColor(0, 255, 0, 255)
        SetEntityDrawOutlineShader(1)
    end
end

--- Restores an entity's outline.
---@param entity number The entity to restore.
local RestoreEntity = function(entity)
    if DoesEntityExist(entity) then
        SetEntityDrawOutline(entity, false)
    end
end

--- Copies the player's current position to the clipboard.
---@param vecType string The type of vector ('vector2', 'vector3', or 'vector4').
---@param arg string The format type ('string' or 'table').
SD.VectorCopy.CopyPlayerPosition = function(vecType, arg)
    local vec = GetPlayerPosition(vecType)
    CopyVectorToClipboard(vec, arg)
end

--- Handles raycast copying with visual feedback.
---@param vecType string The type of vector ('vector2', 'vector3', or 'vector4').
---@param arg string The format type ('string' or 'table').
---@param copyObject boolean Whether to copy the object's coordinates.
SD.VectorCopy.CopyRaycastPosition = function(vecType, arg, copyObject)
    local ped = PlayerPedId()
    local startPos = GetEntityCoords(ped)
    local endPos, entity = GetRaycastPosition()

    if endPos then
        if #(startPos - endPos) <= 20.0 then
            DrawRaycastLine(startPos, endPos)
        end
        if copyObject and entity and DoesEntityExist(entity) then
            if previousEntity and previousEntity ~= entity then
                RestoreEntity(previousEntity)
            end
            HighlightEntity(entity)
            previousEntity = entity
        end
        DrawText3D("Press E to copy coordinates, Backspace to cancel", 0.5, 0.85)
        if IsControlJustPressed(0, 38) then -- E key
            local vec
            if copyObject and entity and DoesEntityExist(entity) then
                local objCoords = GetEntityCoords(entity)
                if vecType == 'vector4' then
                    local heading = GetEntityHeading(entity)
                    vec = vector4(objCoords.x, objCoords.y, objCoords.z, heading)
                elseif vecType == 'vector3' then
                    vec = vector3(objCoords.x, objCoords.y, objCoords.z)
                elseif vecType == 'vector2' then
                    vec = vector2(objCoords.x, objCoords.y)
                end
            else
                if vecType == 'vector4' then
                    local heading = GetEntityHeading(ped)
                    vec = vector4(endPos.x, endPos.y, endPos.z, heading)
                elseif vecType == 'vector3' then
                    vec = vector3(endPos.x, endPos.y, endPos.z)
                elseif vecType == 'vector2' then
                    vec = vector2(endPos.x, endPos.y)
                end
            end
            CopyVectorToClipboard(vec, arg)
            if previousEntity then
                RestoreEntity(previousEntity)
                previousEntity = nil
            end
        elseif IsControlJustPressed(0, 177) then -- Backspace key
            if previousEntity then
                RestoreEntity(previousEntity)
                previousEntity = nil
            end
        end
    elseif previousEntity then
        RestoreEntity(previousEntity)
        previousEntity = nil
    end
end

-- Command to copy the player's position
RegisterNetEvent('sd_lib:copyPos', function(args)
    local vecType = args.vecType or 'vector3'
    local format = args.format or 'string'
    local useRaycast = args.useRaycast == 'true'
    local copyObject = args.copyObject == 'true'

    if useRaycast then
        CreateThread(function()
            local isRaycasting = true
            while isRaycasting do
                Wait(0)
                SD.VectorCopy.CopyRaycastPosition(vecType, format, copyObject)
                if IsControlJustPressed(0, 177) then -- Backspace key to exit raycasting mode
                    isRaycasting = false
                end
            end
        end)
    else
        SD.VectorCopy.CopyPlayerPosition(vecType, format)
    end
end)
