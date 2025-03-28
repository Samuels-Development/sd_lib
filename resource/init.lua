--[[
    Code originally sourced from ox_lib (https://github.com/overextended/ox_lib).
    This code has been modified and adapted for use in this project.
    
    This file is licensed under LGPL-3.0 or higher 
    (<https://www.gnu.org/licenses/lgpl-3.0.en.html>).
    
    Copyright (c) 2025 Linden 
    (<https://github.com/thelindat/fivem>).
]]

-- Global variable to store framework details
local frameworkId, frameworkObj

-- Initiliaze a framework and return it's name and object.
local InitFramework = function(framework)
    local objectName if framework == 'es_extended' then objectName = 'es_extended' elseif framework == 'qb-core' or framework == 'qbx_core' then objectName = 'qb-core' end

    if GetResourceState(framework) == 'started' and objectName then
        if objectName == 'es_extended' then
            return 'esx', exports[objectName]:getSharedObject()
        elseif objectName == 'qb-core' then
            if framework == 'qbx_core' then
                return 'qbx', exports[objectName]:GetCoreObject()
            else
                return 'qb', exports[objectName]:GetCoreObject()
            end
        end
    end
    return nil, nil
end

-- Function to automatically detect a framework and initialize the 'id' and object of said framework.
local DetectFramework = function()
    local frameworks = {'es_extended', 'qb-core', 'qbx_core'}
    for _, fw in ipairs(frameworks) do
        local id, obj = InitFramework(fw)
        if id then
            return id, obj
        end
    end
    return nil, nil
end

-- Detect and store the framework at the start
frameworkId, frameworkObj = DetectFramework()
if frameworkId == 'qb' then _ENV['QBCore'] = frameworkObj elseif frameworkId == 'esx' then _ENV['ESX'] = frameworkObj end

-- Initialization of 'sd_lib' and context determination
local sd_lib = 'sd_lib'
local context = IsDuplicityVersion() and 'server' or 'client'

-- SD Table with metatable for handling module loading and framework integration
SD = setmetatable({
    name = sd_lib,
    context = context,
}, {
    __newindex = function(self, key, fn)
        rawset(self, key, fn)
    end,

    __index = function(self, key)
        local frameworkName = DetectFramework() -- Detect and set the framework first
        local dir = ('modules/%s'):format(key)
        local chunk = LoadResourceFile(self.name, ('%s/%s.lua'):format(dir, self.context))
        local shared = LoadResourceFile(self.name, ('%s/shared.lua'):format(dir))

        if shared then
            chunk = (chunk and ('%s\n%s'):format(shared, chunk)) or shared
        end

        if chunk then
            local env = {Framework = frameworkName}
            setmetatable(env, {__index = _G}) -- Provide access to global variables and libraries
            
            local fn, err = load(chunk, ('@@sd_lib/%s/%s.lua'):format(key, self.context), 't', env)

            if not fn or err then
                return error(string.format("Error importing module (%s): %s", dir, err), 3)
            end

            rawset(self, key, fn() or noop)

            return self[key]
        end
    end
})