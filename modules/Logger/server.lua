--- @class SD.Logger
SD.Logger = {}

local cfg = {
    service     = 'none',
    screenshots = false,
    events      = {},
    discord     = {},
    loki        = {},
    grafana     = {}
}

-- Internal buffers for Loki/Grafana
local logBuffers    = {}
local flushScheduled = false

--- Base64-encodes a string.
---@param data string The string to encode.
---@return string The base64-encoded result.
local Base64Encode = function(data)
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x)
        local bits, byte = '', x:byte()
        for i = 8, 1, -1 do
            bits = bits .. ((byte % 2^i >= 2^(i-1)) and '1' or '0')
        end
        return bits
    end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if #x < 6 then return '' end
        local c = 0
        for i = 1, 6 do
            c = c + (x:sub(i,i) == '1' and 2^(6-i) or 0)
        end
        return b64chars:sub(c+1, c+1)
    end) .. ({ '', '==', '=' })[#data % 3 + 1])
end

--- Builds an HTTP Basic Authorization header value.
---@param user string Username.
---@param pass string Password.
---@return string The 'Basic ...' header value.
local GetAuthHeader = function(user, pass)
    return 'Basic ' .. Base64Encode(user .. ':' .. pass)
end

--- Schedules a flush of buffered logs to Loki/Grafana after a short delay.
local ScheduleFlush = function()
    if flushScheduled then return end
    flushScheduled = true
    SetTimeout(500, function()
        local services = { loki = cfg.loki, grafana = cfg.grafana }
        for name, conf in pairs(services) do
            if next(logBuffers[name] or {}) and conf.endpoint and conf.headers then
                local streams = {}
                for _, stream in pairs(logBuffers[name]) do
                    streams[#streams+1] = stream
                end
                local body = json.encode({ streams = streams })
                PerformHttpRequest(conf.endpoint, function(status)
                    if (name == 'loki' and status ~= 204)
                    or (name == 'grafana' and (status < 200 or status >= 300)) then
                        print(('SD.Logger: %s push failed (status %d)'):format(name, status))
                    end
                end, 'POST', body, conf.headers)
            end
        end
        logBuffers = {}
        flushScheduled = false
    end)
end

--- Initializes the logger with your `logs` config table.
---@param logsConfig table The `logs` table from your resource config.
SD.Logger.Setup = function(logsConfig)
    cfg.service     = logsConfig.service     or cfg.service
    cfg.screenshots = logsConfig.screenshots or cfg.screenshots
    cfg.events      = logsConfig.events      or cfg.events
    cfg.discord     = logsConfig.discord     or cfg.discord

    if logsConfig.loki then
        local l = logsConfig.loki
        cfg.loki.endpoint = l.endpoint or ''
        if not cfg.loki.endpoint:match('^https?://') then
            cfg.loki.endpoint = 'https://' .. cfg.loki.endpoint
        end
        cfg.loki.endpoint = cfg.loki.endpoint:gsub('/+$','') .. '/loki/api/v1/push'
        cfg.loki.headers = { ['Content-Type'] = 'application/json' }
        if l.user and l.password then
            cfg.loki.headers['Authorization'] = GetAuthHeader(l.user, l.password)
        end
        if l.tenant then
            cfg.loki.headers['X-Scope-OrgID'] = l.tenant
        end
    end

    if logsConfig.grafana then
        local g = logsConfig.grafana
        cfg.grafana.endpoint = g.endpoint or ''
        if not cfg.grafana.endpoint:match('^https?://') then
            cfg.grafana.endpoint = 'https://' .. cfg.grafana.endpoint
        end
        cfg.grafana.endpoint = cfg.grafana.endpoint:gsub('/+$','') .. '/loki/api/v1/push'
        cfg.grafana.headers = { ['Content-Type'] = 'application/json' }
        if g.apiKey then
            cfg.grafana.headers['Authorization'] = 'Bearer ' .. g.apiKey
        end
        if g.tenant then
            cfg.grafana.headers['X-Scope-OrgID'] = g.tenant
        end
    end
end

--- Sends a log entry via Discord webhook.
---@param title string The title of the log message.
---@param message string The log message content.
local SendDiscordLog = function(title, message)
    local d = cfg.discord
    assert(d.link and d.link ~= '', 'SD.Logger: discord.link must be set')
    local resourceName = GetCurrentResourceName()
    local fullTitle = string.format('%s - %s', resourceName, title)
    local embed = {{
        color       = d.color       or 14423100,
        title       = '**' .. fullTitle .. '**',
        description = message,
        footer      = { text = os.date('%a %b %d, %I:%M %p'), icon_url = d.footer }
    }}
    local payload = {
        username   = d.name,
        avatar_url = d.image,
        embeds     = embed
    }
    if d.tagEveryone then payload.content = '@everyone' end
    PerformHttpRequest(d.link, function() end, 'POST', json.encode(payload), { ['Content-Type'] = 'application/json' })
end

--- Sends a log entry via FiveM-Manage.
---@param source number The player's server ID.
---@param title string  The title of the log message.
---@param message string The log message content.
local SendFiveMManageLog = function(source, title, message)
    local sdk = cfg.fmsdk or exports.fmsdk
    if not sdk then return end
    if cfg.screenshots then
        sdk:takeServerImage(source, { name = title, description = message })
    else
        sdk:LogMessage('info', message)
    end
end

--- Sends a log entry via FiveM-Err.
---@param source number The player's server ID.
---@param title string  The title of the log message.
---@param message string The log message content.
local SendFiveMErrLog = function(source, title, message)
    local errlog = cfg.fmlogs or exports['fm-logs']
    if not errlog then return end
    errlog:createLog({
        LogType  = 'Generic',
        Message  = message,
        Resource = cfg.resource or GetCurrentResourceName(),
        Source   = source,
    }, { Screenshot = cfg.screenshots })
end

--- Buffers a log stream for Loki/Grafana.
---@param serviceName string 'loki' or 'grafana'.
---@param source number The player's server ID.
---@param event string The event name.
---@param message string The log message content.
local BufferStream = function(serviceName, source, event, message)
    local conf = cfg[serviceName]
    if conf.endpoint == '' then return end
    if not logBuffers[serviceName] then logBuffers[serviceName] = {} end

    local ts = tostring(os.time() * 1e9)
    if not logBuffers[serviceName][event] then
        logBuffers[serviceName][event] = {
            stream = {
                server   = conf.server or GetConvar('sv_projectName', 'fxserver'),
                resource = cfg.resource or GetCurrentResourceName(),
                event    = event
            },
            values = {}
        }
        table.insert(logBuffers[serviceName], logBuffers[serviceName][event])
    end

    logBuffers[serviceName][event].values[#logBuffers[serviceName][event].values + 1] = {
        ts,
        json.encode({ message = message, source = source })
    }

    ScheduleFlush()
end

--- Logs an event using the configured service.
---@param source number|null The player's server ID (nil for Discord-only logs).
---@param title string  The title or event name of the log.
---@param message string The log message content.
SD.Logger.Log = function(source, title, message)
    if cfg.service == 'none' then
        return
    elseif cfg.service == 'discord' then
        SendDiscordLog(title, message)
    elseif cfg.service == 'fivemmanage' then
        SendFiveMManageLog(source, title, message)
    elseif cfg.service == 'fivemerr' then
        SendFiveMErrLog(source, title, message)
    elseif cfg.service == 'loki' then
        BufferStream('loki', source, title, message)
    elseif cfg.service == 'grafana' then
        BufferStream('grafana', source, title, message)
    else
        error("SD.Logger: unsupported service '" .. tostring(cfg.service) .. "'")
    end
end

return SD.Logger
