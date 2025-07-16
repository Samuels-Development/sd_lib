--- Event handler to display update doorlocks.
-- Listens for an event and updates a door using the configured method upon receiving it.
RegisterNetEvent('sd_lib:doorToggle', function(data)
    SD.Doorlock.UpdateState(data)
end)

-- Event Handler to display emails, specifically from lb-phone, yflip-phone & okokPhone.
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
    elseif data.resource == 'high-phone' then
        ---@class Media
        ---@field type '"image"' | '"video"'   -- Type of media content
        ---@field url string                   -- Media URL

        ---@class Contact
        ---@field number string                -- Contact's phone number
        ---@field name string                  -- Contact's name
        ---@field photo string                 -- Contact's photo URL

        ---@class Note
        ---@field title string                 -- Note title
        ---@field content string               -- Note content

        ---@class Attachment
        ---@field type '"media"' | '"contact"' | '"note"'  -- Attachment type
        ---@field content Media | Contact | Note           -- Content depends on the type 

        ---@class MessageData
        ---@field sender string              -- Sender phone number
        ---@field recipients string | string[] -- One or more recipient numbers
        ---@field subject string | nil             -- (Optional) Mail subject, if applicable
        ---@field content string             -- Message content
        ---@field attachments Attachment[] | nil  -- (Optional) List of attachments

        ---Sending Mail https://docs.high-scripts.com/phone/exports/server#sendmail
        ---@info data MessageData           -- Message data
        ---@info source? number             -- (Optional) Player's ID, only needed if sending on behalf of a player
        ---@info exports['high-phone']:sendMail(data, source)

        local account = exports['high-phone']:getPlayerMailAccount(src)
        if account and account.address then
            local emailData = {
                sender = data.sender,   -- 	Sender phone number
                recipients = { account.address },
                subject = data.subject,
                content = data.message,
                attachments = {} -- Optional attachments
            }
            exports['high-phone']:sendMail(emailData)
        end
    elseif data.resource == 'yseries' then
        local emailData = {
            title = data.subject,
            sender = 'email@example.com',
            senderDisplayName = data.sender,
            content = data.message,
            actions = {}, -- Optional actions
            attachments = {} -- Optional attachments
        }
        local receiverType = 'source'
        local receiver = src
        exports["yseries"]:SendMail(emailData, receiverType, receiver)
    elseif data.resource == 'yflip-phone' then
        local playerId = SD.GetIdentifier(src)
        local number = exports["yflip-phone"]:GetPhoneNumberByIdentifier(playerId)
        exports["yflip-phone"]:SendMail({
            title = data.subject,
            sender = 'https://fivem.samueldev.shop',
            senderDisplayName = data.sender,
            content = data.message,
        }, 'phoneNumber', number)
    elseif data.resource == 'okokPhone' then
        local email = exports.okokPhone:getEmailAddressFromSource(src)
        if email then
            local newEmail = {
                sender = data.sender,
                recipients = {email},
                subject = data.subject,
                body = data.message,
            }
            local emailId = exports.okokPhone:sendEmail(newEmail)
        end
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

-- Register a callback to get the full name of the target player, on client
SD.Callback.Register('sd_lib:getFullName', function(source)
    local fullName = SD.GetFullName(source)
    return(fullName)
end)

-- Register a callback to get the first name
SD.Callback.Register('sd_lib:getFirstName', function(source)
    local firstName = SD.GetFirstName(source)
    return(firstName)
end)

-- Register a callback to get the last name
SD.Callback.Register('sd_lib:getLastName', function(source)
    local lastName = SD.GetLastName(source)
    return(lastName)
end)

SD.CheckVersion('Samuels-Development/sd_lib') -- Check version of specified resource