local CheckForDuty = true -- Only count on duty jobs as part of the HasGroup function.

--- Dynamically selects and returns the appropriate function for checking a player's group
--- based on the configured framework.
--- This function caters to different inventory systems and framework specifics,
--- ensuring that the group check is performed accurately and efficiently.
-- @return function A group function customized to the active configuration.
local HasGroup = function()
    if Framework == 'esx' then
        return function(player, filter)
            local typeOfFilter = type(filter)

            if typeOfFilter == 'string' then
                if player.job.name == filter then
                    return player.job.name, player.job.grade
                end
            elseif typeOfFilter == 'table' then
                if table.type(filter) == 'hash' then
                    local grade = filter[player.job.name]
                    if grade and grade <= player.job.grade then
                        return player.job.name, player.job.grade
                    end
                elseif table.type(filter) == 'array' then
                    for _, jobName in ipairs(filter) do
                        if player.job.name == jobName then
                            return player.job.name, player.job.grade
                        end
                    end
                end
            end

            return nil
        end
    elseif Framework == 'qb' then
        return function(player, filter)
            local typeOfFilter = type(filter)
            local groups = { 'job', 'gang' }

            if typeOfFilter == 'string' then
                for _, group in ipairs(groups) do
                    local data = player.PlayerData[group]
                    if data and data.name == filter then
                        if group == 'job' and CheckForDuty and not player.PlayerData.job.onduty then
                            return nil
                        end
                        return data.name, data.grade.level
                    end
                end
            elseif typeOfFilter == 'table' then
                if table.type(filter) == 'hash' then
                    for _, group in ipairs(groups) do
                        local data = player.PlayerData[group]
                        local grade = filter[data.name]
                        if grade and grade <= data.grade.level then
                            if group == 'job' and CheckForDuty and not player.PlayerData.job.onduty then
                                return nil
                            end
                            return data.name, data.grade.level
                        end
                    end
                elseif table.type(filter) == 'array' then
                    for _, groupName in ipairs(filter) do
                        for _, group in ipairs(groups) do
                            local data = player.PlayerData[group]
                            if data and data.name == groupName then
                                if group == 'job' and CheckForDuty and not player.PlayerData.job.onduty then
                                    return nil
                                end
                                return data.name, data.grade.level
                            end
                        end
                    end
                end
            end

            return nil
        end
    else
        -- Fallback function for unsupported frameworks.
        return function() return false end
    end
end

-- Assign the dynamically selected function to SD.HasGroup.
local PlayerHasGroup = HasGroup()

SD.HasGroup = function(source, filter)
    local player = SD.GetPlayer(source)
    return PlayerHasGroup(player, filter)
end

return SD.HasGroup