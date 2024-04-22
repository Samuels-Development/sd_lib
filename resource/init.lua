-- Framework Initialization Functions
local function ESXInit()
    if GetResourceState('es_extended') == 'started' then
        _G.ESX = exports['es_extended']:getSharedObject()
        _G.Framework = 'esx'
    end
end

local function QBCoreInit()
    if GetResourceState('qb-core') == 'started' then
        _G.QBCore = exports['qb-core']:GetCoreObject()
        _G.Framework = 'qb'
    end
end

-- Detect active framework and initialize it
local function DetectFramework()
    local frameworks = {'es_extended', 'qb-core'}
    for _, fw in ipairs(frameworks) do
        if GetResourceState(fw) == 'started' then
            if fw == 'es_extended' then
                ESXInit()
                return 'esx'
            elseif fw == 'qb-core' then
                QBCoreInit()
                return 'qb'
            end
        end
    end
    return nil
end

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