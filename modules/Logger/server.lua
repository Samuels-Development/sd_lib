local webhookURL = "Your_Webhook_URL" -- Replace with your actual webhook URL
local colors = {['default'] = 14423100}
local logQueue = {}
local logTime = 60 -- Time in seconds to flush the log queue

--- Sends the queued logs for a given log group.
local sendQueue = function(name)
    if #logQueue[name] > 0 then
        local postData = {username = 'SD Logs', embeds = {}}
        
        if logQueue[name][1].content then
            postData.content = '@everyone'
        end

        for _, log in ipairs(logQueue[name]) do
            table.insert(postData.embeds, log.data)
        end

        PerformHttpRequest(logQueue[name][1].webhook, function(err, text, headers)
            -- Optional: Handle the response if needed
        end, 'POST', json.encode(postData), {['Content-Type'] = 'application/json'})

        logQueue[name] = {}
    end
end

-- Background thread for automatic log sending
CreateThread(function()
    local timer = 0
    while true do
        Wait(1000)
        timer = timer + 1
        if timer >= logTime then
            timer = 0
            for name, _ in pairs(logQueue) do
                sendQueue(name)
            end
        end
    end
end)

--- Public interface for logging, exposed through the SD namespace
---@param name string A unique name for the log group.
---@param title string The title of the log message.
---@param color string The color code or a key for predefined colors.
---@param message string The log message content.
---@param tagEveryone boolean Optionally tag everyone in the Discord channel.
SD.Log = function(name, title, color, message, tagEveryone)
    local tag = tagEveryone or false

    if not webhookURL or webhookURL == "" then
        error("Webhook URL is not defined. Please define a webhook URL to receive logs.")
        return
    end

    local embedData = {
        title = title,
        color = colors[color] or colors['default'],
        footer = {text = os.date('%c')},
        description = message,
        author = {
            name = 'SD Logs',
            icon_url = 'https://cdn.discordapp.com/attachments/1002646303139958784/1137442128310567002/samueldevelopment-logo.png',
        },
    }

    logQueue[name] = logQueue[name] or {}
    table.insert(logQueue[name], {webhook = webhookURL, data = embedData, content = tag})

    if #logQueue[name] >= 10 then
        sendQueue(name)
    end
end

return SD.Logger