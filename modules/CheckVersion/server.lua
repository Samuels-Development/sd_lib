--- Checks for updates by comparing the local version of a resource with its latest version on GitHub.
---@param repo string The GitHub repository in the format 'owner/repository'.
SD.CheckVersion = function(repo)
    local resource = GetInvokingResource() or GetCurrentResourceName()
    local currentVersion = GetResourceMetadata(resource, 'Version', 0)
    if currentVersion then
        currentVersion = currentVersion:match('%d+%.%d+%.%d+')
    end

    if not currentVersion then
        return print("^1Unable to determine current resource version for '^2" .. resource .. "^1' ^0")
    end

    print('^3Checking for updates for ^2' .. resource .. '^3...^0')
    SetTimeout(1000, function()
        local url = ('https://api.github.com/repos/%s/releases/latest'):format(repo)
        PerformHttpRequest(url, function(status, response)
            if status ~= 200 then 
                print('^1Failed to fetch release information for ^2' .. resource .. '^1. HTTP status: ' .. status .. '^0')
                return
            end
            response = json.decode(response)
            if response and response.prerelease then
                print('^3Skipping prerelease for ^2' .. resource .. '^3.^0')
                return
            end
        
            local latestVersion = response and response.tag_name:match('%d+%.%d+%.%d+')
            if not latestVersion then
                print('^1Failed to get a valid latest version for ^2' .. resource .. '^1.^0')
                return
            end
        
            if latestVersion == currentVersion then
                print('^2' .. resource .. ' ^3is up-to-date with version ^2' .. currentVersion .. '^3.^0')
                return
            end
        
            local cv = {table.unpack(SD.String.Split(currentVersion, '%.'))}
            local lv = {table.unpack(SD.String.Split(latestVersion, '%.'))}
        
            for i = 1, #cv do
                local current, minimum = tonumber(cv[i]), tonumber(lv[i])
                if current < minimum then
                    local releaseNotes = response.body or "No release notes available."
                    
                    -- Check if release notes exceed one line
                    local standardizedMessage = "Check release or changelog channel on Discord!"
                    local message = releaseNotes:find("\n") and standardizedMessage or releaseNotes
                    
                    print('^3An update is available for ^2' .. resource .. '^3 (current version: ^2' .. currentVersion .. '^3)\r\nLatest version: ^2' .. latestVersion .. '^3\r\nRelease Notes: ^7' .. message)
                    break
                elseif current > minimum then
                    print('^2' .. resource .. ' ^3has a newer local version (^2' .. currentVersion .. '^3) than the latest public release (^2' .. latestVersion .. '^3).^0')
                    break
                end
            end
        end, 'GET', '')
    end)
end

return SD.CheckVersion