local loaded = {}
local resource = GetCurrentResourceName()

--- Loads and returns a module from "<path>.lua" in this resource.
---@param path string -- module path without “.lua”
---@return any -- return value of the module
function SD.Require(path)
    if loaded[path] then
        return loaded[path]
    end

    local fileContents = LoadResourceFile(resource, path .. '.lua')
    if not fileContents then
        error(("Module '%s' not found in @%s/%s.lua"):format(path, resource, path), 2)
    end

    local fn, compileErr = load(
        fileContents,('@@%s/%s.lua'):format(resource, path),'t',_ENV)
    if not fn then
        error(("Error loading module '%s': %s"):format(path, compileErr), 2)
    end

    local result = fn()
    loaded[path] = (result == nil) and true or result
    return loaded[path]
end

return SD.Require