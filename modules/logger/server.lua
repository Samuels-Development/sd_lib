Config = {
    service = 'datadog', -- Default service; can be changed to 'datadog', 'fivemanage', or 'loki'
    webhookURL = "Your_Webhook_URL", -- Replace with your actual webhook URL
    datadog = {
        key = '7670d5dfaf0895b19060cc1706b44648',
        site = 'datadoghq.eu'
    },
    fivemanage = {
        key = 'your-fivemanage-api-key',
    },
    loki = {
        user = '867431',
        password = 'glc_eyJvIjoiMTEwMzM3NiIsIm4iOiJzdGFjay05MDk2NTAtaGwtd3JpdGUtc2FtdWVsMiIsImsiOiIxM3YzV0tFMHd1VUZzN0k1MnlUNjFkeTIiLCJtIjp7InIiOiJwcm9kLWV1LXdlc3QtMiJ9fQ==',
        endpoint = 'https://logs-prod-012.grafana.net/loki/api/v1/push',
        tenant = 'glc_eyJvIjoiMTEwMzM3NiIsIm4iOiJzdGFjay05MDk2NTAtaGwtd3JpdGUtc2FtdWVsMiIsImsiOiIxM3YzV0tFMHd1VUZzN0k1MnlUNjFkeTIiLCJtIjp7InIiOiJwcm9kLWV1LXdlc3QtMiJ9fQ==',
    }
}

local buffer = {}
local bufferSize = 0
local hostname = "YourServerName" -- Placeholder for your server's hostname

-- Utility to remove color codes
local function removeColorCodes(str)
    return str:gsub("%^%d", ""):gsub("%^#[%dA-Fa-f]+", ""):gsub("~[%a]~", "")
end

hostname = removeColorCodes(hostname)

-- Define headers and endpoint dynamically based on the service
local function getServiceConfig()
    local service = Config.service
    local headers = {}
    local endpoint = ""

    if service == 'datadog' then
        endpoint = ('https://http-intake.logs.%s/api/v2/logs'):format(Config.datadog.site)
        headers = {['Content-Type'] = 'application/json', ['DD-API-KEY'] = Config.datadog.key}
    elseif service == 'fivemanage' then
        endpoint = 'https://api.fivemanage.com/api/logs/batch'
        headers = {['Content-Type'] = 'application/json', ['Authorization'] = Config.fivemanage.key}
    elseif service == 'loki' then
        endpoint = ('%s/loki/api/v1/push'):format(Config.loki.endpoint)
        headers = {['Content-Type'] = 'application/json', ['Authorization'] = getAuthorizationHeader(Config.loki.user, Config.loki.password)}
        if Config.loki.tenant ~= '' then
            headers['X-Scope-OrgID'] = Config.loki.tenant
        end
    else
        endpoint = Config.webhookURL -- Fallback to Discord webhook if no service is selected
        headers = {['Content-Type'] = 'application/json'}
    end

    return endpoint, headers
end

-- Generic log function for all services
local function logMessage(message, tags)
    local endpoint, headers = getServiceConfig()
    table.insert(buffer, {
        level = "info",
        message = message,
        hostname = hostname,
        tags = tags
    })

    bufferSize = bufferSize + 1

    if bufferSize >= 10 then
        PerformHttpRequest(endpoint, function(status, text, headers)
            -- Optionally handle the response
        end, 'POST', json.encode(buffer), headers)

        buffer = {}
        bufferSize = 0
    end
end

-- Public logging interface
function SD.Log(message, tags)
    logMessage(message, tags)
end

return SD
