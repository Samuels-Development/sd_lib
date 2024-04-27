-- Global variable to store framework details
local frameworkId, frameworkObj

-- Initiliaze a framework and return it's name and object.
local InitFramework = function(framework)
    local objectName if framework == 'es_extended' then objectName = 'es_extended' elseif framework == 'qb-core' or framework == 'qbx_core' then objectName = 'qb-core' end

    if GetResourceState(framework) == 'started' and objectName then
        if objectName == 'es_extended' then
            return 'esx', exports[objectName]:getSharedObject()
        else
            return 'qb', exports[objectName]:GetCoreObject()
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

local sd_lib = 'sd_lib'

-- Initialize export from 'sd_lib' resource
local export = exports[sd_lib]

-- Reuse Lua native function and determine the context (server or client)
local LoadResourceFile = LoadResourceFile
local context = IsDuplicityVersion() and 'server' or 'client'

-- Define a no-operation function for default behavior
local function noop() end

-- Define a function to load modules with the ability to use the framework information
local function loadModule(self, module)
    local dir = ('modules/%s'):format(module)
    local chunk = LoadResourceFile(sd_lib, ('%s/%s.lua'):format(dir, context))
    local shared = LoadResourceFile(sd_lib, ('%s/shared.lua'):format(dir))

    if shared then
        chunk = (chunk and ('%s\n%s'):format(shared, chunk)) or shared
    end

    if chunk then
        -- Define an environment for the module with framework access and global access
        local env = { Framework = frameworkId }
        setmetatable(env, {__index = _G})  -- Use _G to provide access to all global variables and libraries

        -- Load the module code with the specific environment
        local fn, err = load(chunk, ('@@sd_lib/modules/%s/%s.lua'):format(module, context), 't', env)
        if not fn or err then
            return error(('\n^1Error importing module (%s): %s^0'):format(dir, err), 3)
        end

        local result = fn() -- Execute the function with its new environment
        self[module] = result or noop
        return self[module]
    end
end

-- Define API for module calling
local function call(self, index, ...)
    local module = rawget(self, index)

    if not module then
        self[index] = noop
        module = loadModule(self, index)

        if not module then
            local function method(...)
                return export[index](nil, ...)
            end

            if not ... then
                self[index] = method
            end

            return method
        end
    end

    return module
end

-- Define the SD table with metatable for call and index operations
local SD = setmetatable({
    name = sd_lib,
    context = context,
    onCache = function(key, cb)
        AddEventHandler(('sd_lib:cache:%s'):format(key), cb)
    end
}, {
    __index = call,
    __call = call,
})

-- Set the global SD environment
_ENV.SD = SD

-- Load all modules mentioned in the resource metadata
for i = 1, GetNumResourceMetadata(sd_lib, sd_lib) do
    local name = GetResourceMetadata(sd_lib, sd_lib, i - 1)

    if not rawget(SD, name) then
        local module = loadModule(SD, name)

        if type(module) == 'function' then pcall(module) end
    end
end