--- Event handler to display update doorlocks.
-- Listens for an event and updates a door using the configured method upon receiving it.
RegisterNetEvent('sd_lib:doorToggle', function(data)
    SD.Doorlock.UpdateState(data)
end)

-- Event Handler to display emails, specifically from lb-phone and yflip-phone.
RegisterNetEvent('sd_lib:sendEmail', function(data)
    local src = source
    if data.resource == 'lb-phone' then
        local number = exports["lb-phone"]:GetEquippedPhoneNumber(src)
        local player = exports["lb-phone"]:GetEmailAddress(number)
        local success, id = exports["lb-phone"]:SendMail({
            to = player,
            sender = data.sender,
            subject = data.subject,
            message = data.message,
        })
    elseif data.resource == 'yflip-phone' then
        local playerId = SD.GetIdentifier(src)
        local number = exports["yflip-phone"]:GetPhoneNumberByIdentifier(playerId)
         exports["yflip-phone"]:SendMail({
            title = data.subject,
            sender = 'https://fivem.samueldev.shop',
           senderDisplayName = data.sender,
            content = data.message,
        }, 'phoneNumber', number)
     end
end)

-- Register a callback to get the identifier of the target player
SD.Callback.Register('sd_lib:getIdentifier', function(source)
    local identifier = SD.GetIdentifier(source)
    return(identifier)
end)

-- Register a callback to get the gender of the target player
SD.Callback.Register('sd_lib:getGender', function(source)
    local gender = SD.GetGender(source)
    return(gender)
end)

SD.CheckVersion('sd-versions/sd_lib') -- Check version of specified resource