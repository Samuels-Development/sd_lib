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
-- @param name string A unique name for the log group.
-- @param title string The title of the log message.
-- @param color string The color code or a key for predefined colors.
-- @param message string The log message content.
-- @param tagEveryone boolean Optionally tag everyone in the Discord channel.
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

return SD.Log

--[[
    local Config = {
    webhookURL = "Your_Webhook_URL", -- For Discord or similar services
    logServices = {
        fivemmanage = {
            enabled = false,
            endpoint = 'https://api.fivemanage.com/api/logs/batch',
            key = 'Your_FiveM_Manage_API_Key'
        },
        datadog = {
            enabled = false,
            endpoint = 'https://http-intake.logs.datadoghq.com/api/v2/logs',
            apiKey = 'Your_Datadog_API_Key'
        },
        loki = {
            enabled = false,
            endpoint = 'https://loki-instance/api/v1/push',
            user = 'Your_Loki_User',
            password = 'Your_Loki_Password'
        },
        grafana = {
            enabled = true,
            endpoint = 'https://logs-prod-012.grafana.net',
            basicAuth = {
                username = "867431",
                password = "glc_eyJvIjoiMTEwMzM3NiIsIm4iOiJzdGFjay05MDk2NTAtaGwtd3JpdGUtc2FtdWVsIiwiayI6IjhlOTQ1Smk0N1diYjY2ZU0zZjBkbGFLUiIsIm0iOnsiciI6InByb2QtZXUtd2VzdC0yIn19",
            }
        }
    },
    buffer = {},
    bufferSize = 0,
    maxBuffer = 20,
    flushInterval = 500
}

local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

local base64encode = function(data)
    return ((data:gsub('.', function(x)
        local r, b = '', x:byte()
        for i = 8, 1, -1 do r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c = 0
        for i = 1, 6 do c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0) end
        return b:sub(c + 1, c + 1)
    end)..({ '', '==', '=' })[#data % 3 + 1])
end

local sendLogs = function()
    if Config.bufferSize == 0 then
        return
    end

    for service, settings in pairs(Config.logServices) do
        if settings.enabled then
            local headers = {['Content-Type'] = 'application/json'}
            if service == 'fivemmanage' then
                headers['Authorization'] = settings.key
            elseif service == 'datadog' then
                headers['DD-API-KEY'] = settings.apiKey
            elseif service == 'loki' or service == 'grafana' then
                headers['Authorization'] = 'Basic ' .. base64encode(settings.user .. ':' .. settings.password)
            end

            local body = json.encode(Config.buffer)
            PerformHttpRequest(settings.endpoint, function(status, response, headers)
                -- Optional: Add logging or error handling based on the response
            end, 'POST', body, headers)
        end
    end

    Config.buffer = {}
    Config.bufferSize = 0
end

SetTimeout(Config.flushInterval, sendLogs)

local formatTags = function(source, ...)
    local tagString = ''
    if type(source) == 'number' and source > 0 then
        tagString = ('player:%s'):format(GetPlayerName(source))
        for i = 0, GetNumPlayerIdentifiers(source) - 1 do
            local identifier = GetPlayerIdentifier(source, i)
            tagString = tagString .. ',' .. identifier
        end
    end

    local additionalTags = {...}
    if #additionalTags > 0 then
        tagString = tagString .. ',' .. table.concat(additionalTags, ',')
    end

    return tagString
end

SD.Log = function(source, event, message, ...)
    local tags = formatTags(source, ...)
    local logEntry = {
        hostname = GetConvar('sv_projectName', 'default-server'),
        service = event,
        message = message,
        tags = tags
    }

    table.insert(Config.buffer, logEntry)
    Config.bufferSize = Config.bufferSize + 1

    if Config.bufferSize >= Config.maxBuffer then
        sendLogs()
    end
end

return SD.Log
--]]