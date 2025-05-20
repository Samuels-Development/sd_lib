local CheckForDuty = true -- Only count on duty jobs as part of the HasGroup function.

--- Decide whether to bypass the onduty requirement.
---@param onduty boolean       PlayerData.job.onduty flag
---@param ignoreDuty boolean? If true, bypasses the requirement
---@return boolean
local IsOnDutyAllowed = function(onduty, ignoreDuty)
    if ignoreDuty or not CheckForDuty then
        return true
    end
    return onduty
end

--- Dynamically selects and returns the appropriate function for checking a player's group
--- based on the configured framework.
--- This function caters to different inventory systems and framework specifics,
--- ensuring that the group check is performed accurately and efficiently.
---@return function A group function customized to the active configuration.
local HasGroup = function()
    if Framework == 'esx' then
        return function(player, filter, ignoreDuty)
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

    elseif Framework == 'qb' or Framework == 'qbx' then
        return function(player, filter, ignoreDuty)
            local typeOfFilter = type(filter)
            local groups = { 'job', 'gang' }

            if typeOfFilter == 'string' then
                for _, group in ipairs(groups) do
                    local data = player.PlayerData[group]
                    if data and data.name == filter then
                        if group == 'job' and not IsOnDutyAllowed(data.onduty, ignoreDuty) then
                            return nil
                        end
                        return data.name, data.grade.level
                    end
                end

            elseif typeOfFilter == 'table' then
                if table.type(filter) == 'hash' then
                    for _, group in ipairs(groups) do
                        local data  = player.PlayerData[group]
                        local grade = filter[data and data.name]
                        if data and grade and data.grade.level >= grade then
                            if group == 'job' and not IsOnDutyAllowed(data.onduty, ignoreDuty) then
                                return nil
                            end
                            return data.name, data.grade.level
                        end
                    end

                elseif table.type(filter) == 'array' then
                    for _, wanted in ipairs(filter) do
                        for _, group in ipairs(groups) do
                            local data = player.PlayerData[group]
                            if data and data.name == wanted then
                                if group == 'job' and not IsOnDutyAllowed(data.onduty, ignoreDuty) then
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

-- Assign the dynamically selected function to a local for reuse.
local PlayerHasGroup = HasGroup()

--- Check if the player belongs to a specific group.
-- This function determines if the given player, identified by 'source', belongs to a group specified by 'filter'.
-- An optional 'ignoreDuty' boolean can be passed to bypass the onduty requirement.
-- @param source any                The identifier for the player.
-- @param filter string|table       The group name or filter table.
-- @param ignoreDuty boolean?       If true, skips the onduty check.
-- @return string|nil, number|nil   The matched group name and grade if any.
SD.HasGroup = function(source, filter, ignoreDuty)
    local player = SD.GetPlayer(source)
    if not player then return nil end
    return PlayerHasGroup(player, filter, ignoreDuty)
end

return SD.HasGroup