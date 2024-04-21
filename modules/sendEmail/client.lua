--- Table of resources for detecting the phone resource.
local resources = { {name = "qb-phone"}, {name = "qs-smartphone"}, {name = "high-phone"}, {name = "npwd-phone"}, {name = "lb-phone"}, {name = "yflip-phone"}, {name = "gks-phone"} }

--- Selects and returns the most appropriate function for sending an email.
-- This function determines the best method for sending emails based on the configured phone resource.
-- @return function A function tailored to send emails using the determined method.
local SelectEmail = function()
    for _, resource in ipairs(resources) do
        if GetResourceState(resource.name) == 'started' then
            if resource.name == "qb-phone" then
                return function(sender, subject, message)
                    TriggerServerEvent('qb-phone:server:sendNewMail', {
                        sender = sender,
                        subject = subject,
                        message = message,
                    })
                end
            elseif resource.name == "qs-smartphone" then
                return function(sender, subject, message)
                    TriggerServerEvent('qs-smartphone:server:sendNewMail', {
                        sender = sender,
                        subject = subject,
                        message = message,
                        button = {}
                    })
                end
            elseif resource.name == "high-phone" then
                return function(sender, subject, message)
                    local senderData = {
                        address = sender.address or "",
                        name = sender,
                        photo = sender.photo or ""
                    }
                    TriggerServerEvent("high_phone:sendMailFromServer", senderData, subject, message, {})
                end
            elseif resource.name == "npwd-phone" then
                return function(sender, subject, message)
                    exports["npwd"]:createNotification({
                        notisId = "npwd:emailNotification",
                        appId = "EMAIL",
                        content = message,
                        secondaryTitle = subject,
                        keepOpen = false,
                        duration = 5000,
                        path = "/email",
                    })
                end
            elseif resource.name == "lb-phone" or resource.name == "yflip-phone" then
                return function(sender, subject, message)
                    TriggerServerEvent('sd_lib:sendEmail', {
                        sender = sender,
                        subject = subject,
                        message = message,
                        resource = resource.name
                    })
                end
            elseif resource.name == "gks-phone" then
                return function(sender, subject, message)
                    local MailData = {
                        sender = sender,
                        image = '/html/static/img/icons/mail.png',
                        subject = subject,
                        message = message
                    }
                    exports["gksphone"]:SendNewMail(MailData)
                end
            end
        end
    end

    -- Fallback if none of the resources are started
    return function(sender, subject, message)
        error("No supported phone resource is currently running.")
    end
end

--- The chosen method for sending an email, determined at the time of script initialization.
SD.SendEmail = SelectEmail()

return SD.SendEmail