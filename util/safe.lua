---
-- Protects the global table from writes and misses.
--
-- Emits a warning whenever one tries to read from or write to an unset key
-- in the global table `_G`.
--
--    require "util.safe"
--
--    print(foo) --> Lua warning: unset global variable foo
--    bar = 123  --> Lua warning: set global variable bar to 123
--
-- @module util.safe

local warn = warn

if warn == nil then
    warn = function (msg)
        io.stderr:write(msg .. '\n')
    end
else
    warn'@on'
end

local function loc (f)
    local info = debug.getinfo(f + 1, "Sln")
    local source = info.source:sub(2)
    local line = info.currentline
    local funcname = info.name
    return ('%s:%d (function %s)'):format(source, line, funcname)
end

setmetatable(_G, {
    __index = function (t, k)
        warn(string.format('unset global variable %s in %s', k, loc(2)))
    end,
    __newindex = function (t, k, v)
        warn(string.format('set global variable %s to %s in %s', k, v, loc(2)))
    end,
})
