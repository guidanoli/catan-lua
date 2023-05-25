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

setmetatable(_G, {
    __index = function (t, k)
        warn(string.format('unset global variable %s', k))
    end,
    __newindex = function (t, k, v)
        warn(string.format('set global variable %s to %s', k, v))
    end,
})
