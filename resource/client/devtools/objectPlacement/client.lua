---@class object 
SD.ObjectPlacement = {}

local PlacingObject = false
local CurrentModel, CurrentObject, CurrentCoords, CurrentRotation = nil, nil, nil, nil
local PlacedObjects = {}

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
---@return boolean, vector3 Whether the raycast hit something and the coordinates of the hit.
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
    local _, hit, coords, _, _ = GetShapeTestResult(rayHandle)
    return hit, coords
end

--- Sets the text message for a Scaleform button.
-- This function sets the text message that appears next to a control button in the instructional buttons display.
---@param text string The text message to display.
local ButtonMessage = function(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

--- Adds a control button to the Scaleform instructional buttons display.
-- This function adds a specified control button to the instructional buttons display using Scaleform.
--@param ControlButton number The control button to add (e.g., the key code for the button).
local Button = function(ControlButton)
    N_0xe83a3e3557a56640(ControlButton)
end

--- Sets up instructional buttons using Scaleform.
-- This function sets up the instructional buttons displayed on the screen.
---@param scaleform string The name of the Scaleform to use.
---@return any The loaded Scaleform movie.
local SetupScaleform = function(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Wait(0)
    end

    DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 0, 0)

    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    Button(GetControlInstructionalButton(2, 44, true))
    ButtonMessage("Cancel")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    Button(GetControlInstructionalButton(2, 38, true))
    ButtonMessage("Place object")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    Button(GetControlInstructionalButton(2, 174, true))
    Button(GetControlInstructionalButton(2, 175, true))
    ButtonMessage("Rotate object (Z-axis)")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(3)
    Button(GetControlInstructionalButton(2, 172, true))
    Button(GetControlInstructionalButton(2, 173, true))
    ButtonMessage("Pitch object (X-axis)")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(4)
    Button(GetControlInstructionalButton(2, 21, true))
    ButtonMessage("Hold Shift to fine-tune rotation (1 degree)")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    return scaleform
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

--- Cancels the object placement process.
-- This function deletes the current preview object and resets the placement state.
local CancelPlacement = function()
    DeleteObject(CurrentObject)
    PlacingObject = false
    CurrentObject = nil
    CurrentCoords = nil
    CurrentModel = nil
    CurrentRotation = nil
end

--- Places the object at the current coordinates.
-- This function places the object at the current coordinates and prints its information.
local PlaceObject = function(params)
    local placedObject = CreateObjectNoOffset(CurrentModel, CurrentCoords.x, CurrentCoords.y, CurrentCoords.z, true, false, true)
    SetEntityRotation(placedObject, CurrentRotation.x, CurrentRotation.y, CurrentRotation.z, 2, true)
    FreezeEntityPosition(placedObject, false)
    table.insert(PlacedObjects, placedObject)
    local placedCoords = GetEntityCoords(placedObject)
    local placedRotation = GetEntityRotation(placedObject, 2)
    if not CurrentModel then return end
    
    local modelString = string.format("Model: %s, Coords: (%.2f, %.2f, %.2f), Rotation: (%.2f, %.2f, %.2f)", 
    CurrentModel, placedCoords.x, placedCoords.y, placedCoords.z, placedRotation.x, placedRotation.y, placedRotation.z)
    
    -- Determine the format for the clipboard
    local clipboardFormat = params.format or 'string'
    local clipboardText = ""

    if clipboardFormat == 'table' then
        clipboardText = string.format("{ x = %.2f, y = %.2f, z = %.2f, w = %.2f }", 
        placedCoords.x, placedCoords.y, placedCoords.z, placedRotation.z)
    else
        clipboardText = string.format("vector4(%.2f, %.2f, %.2f, %.2f)", 
        placedCoords.x, placedCoords.y, placedCoords.z, placedRotation.z)
    end
    
    -- Copy to clipboard using NUI callback
    SendNUIMessage({
        type = 'copyToClipboard',
        text = clipboardText
    })
    
    print(modelString)
    print(clipboardText)

    -- Clean up
    CancelPlacement()
end

-- Function to ensure variables are valid
local EnsureValid = function(var, default)
    if var == nil then
        return {x = default, y = default, z = default}
    else
        if var.x == nil then var.x = default end
        if var.y == nil then var.y = default end
        if var.z == nil then var.z = default end
    end
    return var
end

--- Starts the object placement process.
-- This function initializes the placement process for the specified model.
---@param params table The parameters for object placement (model, etc.).
SD.ObjectPlacement.Start = function(params)
    local model = params.model
    local highlightColor = {r = 128, g = 0, b = 128, a = 128}
    local lastRotationTime = 0
    local rotationCooldown = 200

    -- Load the model
    SD.LoadModel(model)
    CurrentModel = model

    -- Main loop for object placement
    CreateThread(function()
        PlacingObject = true
        CurrentRotation = vector3(0.0, 0.0, 0.0)

        -- Create the preview object
        CurrentObject = CreateObjectNoOffset(model, 1.0, 1.0, 1.0, false, false, false)
        SetEntityAlpha(CurrentObject, highlightColor.a, false)
        SetEntityCollision(CurrentObject, false, false)
        FreezeEntityPosition(CurrentObject, true)
        SetEntityRotation(CurrentObject, CurrentRotation.x, CurrentRotation.y, CurrentRotation.z, 2, true)

        -- Scaleform for instructional buttons
        local form = SetupScaleform("instructional_buttons")

        while PlacingObject do
            Wait(1)

            -- Raycast to detect where the player is aiming
            local hit, coords = RayCastGamePlayCamera(20.0)
            if hit then
                CurrentCoords = coords
                SetEntityCoords(CurrentObject, coords.x, coords.y, coords.z, false, false, false, true)
            end

            -- Draw instructional buttons
            DrawScaleformMovieFullscreen(form, 255, 255, 255, 255, 0)

            -- Ensure CurrentCoords and CurrentRotation are valid
            CurrentCoords = EnsureValid(CurrentCoords, 0)
            CurrentRotation = EnsureValid(CurrentRotation, 0)

            -- Display current coordinates, heading, and tilt
            DrawText3D(string.format("Coords: (%.2f, %.2f, %.2f)", CurrentCoords.x, CurrentCoords.y, CurrentCoords.z), 0.5, 0.85)
            DrawText3D(string.format("Rotation: (X: %.2f, Y: %.2f, Z: %.2f)", CurrentRotation.x, CurrentRotation.y, CurrentRotation.z), 0.5, 0.88)

            local rotationIncrement = IsControlPressed(0, 21) and 1 or 10  -- Control key is 36

            -- Get the current time
            local currentTime = GetGameTimer()

            -- Rotate object on Z-axis
            if currentTime - lastRotationTime > rotationCooldown then
                if IsControlJustPressed(0, 174) then
                    CurrentRotation = vector3(CurrentRotation.x, CurrentRotation.y, CurrentRotation.z + rotationIncrement)
                    if CurrentRotation.z > 360 then CurrentRotation = vector3(CurrentRotation.x, CurrentRotation.y, 0.0) end
                    lastRotationTime = currentTime
                end

                if IsControlJustPressed(0, 175) then
                    CurrentRotation = vector3(CurrentRotation.x, CurrentRotation.y, CurrentRotation.z - rotationIncrement)
                    if CurrentRotation.z < 0 then CurrentRotation = vector3(CurrentRotation.x, CurrentRotation.y, 360.0) end
                    lastRotationTime = currentTime
                end

                -- Pitch object on X-axis
                if IsControlJustPressed(0, 172) then
                    CurrentRotation = vector3(CurrentRotation.x + rotationIncrement, CurrentRotation.y, CurrentRotation.z)
                    if CurrentRotation.x > 360 then CurrentRotation = vector3(0.0, CurrentRotation.y, CurrentRotation.z) end
                    lastRotationTime = currentTime
                end

                if IsControlJustPressed(0, 173) then
                    CurrentRotation = vector3(CurrentRotation.x - rotationIncrement, CurrentRotation.y, CurrentRotation.z)
                    if CurrentRotation.x < 0 then CurrentRotation = vector3(360.0, CurrentRotation.y, CurrentRotation.z) end
                    lastRotationTime = currentTime
                end

                SetEntityRotation(CurrentObject, CurrentRotation.x, CurrentRotation.y, CurrentRotation.z, 2, true)
            end

            -- Place object
            if IsControlJustPressed(0, 38) then
                PlaceObject(params)
            end

            -- Cancel placement
            if IsControlJustPressed(0, 44) then
                CancelPlacement()
            end
        end
    end)
end

RegisterNetEvent('sd_lib:placeObject', function(params)
    SD.ObjectPlacement.Start(params)
end)

--- Cleanup function to delete all placed objects
local CleanupPlacedObjects = function()
    for _, obj in ipairs(PlacedObjects) do
        if DoesEntityExist(obj) then
            DeleteObject(obj)
        end
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        CleanupPlacedObjects()
    end
end)

RegisterNetEvent('sd_lib:clearObjects', function()
    CleanupPlacedObjects()
end)