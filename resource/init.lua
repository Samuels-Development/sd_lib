SD = setmetatable({
    name = 'sd_lib',
    context = IsDuplicityVersion() and 'server' or 'client',
}, {
    __newindex = function(self, key, fn)
        rawset(self, key, fn)
    end,

    __index = function(self, key)
        local dir = ('modules/%s'):format(key)
        local chunk = LoadResourceFile(self.name, ('%s/%s.lua'):format(dir, self.context))
        local shared = LoadResourceFile(self.name, ('%s/shared.lua'):format(dir))

        if shared then
            chunk = (chunk and ('%s\n%s'):format(shared, chunk)) or shared
        end

        if chunk then
            local fn, err = load(chunk, ('@@sd_lib/%s/%s.lua'):format(key, self.context))

            if not fn or err then
                return error(string.format("Error importing module (%s): %s", dir, err), 3)
            end

            rawset(self, key, fn() or noop)

            return self[key]
        end
    end
})