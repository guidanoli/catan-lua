--- Protects the global table from writes and misses
--
-- Emits a warning whenever one tries to read from or write to an unset key
-- in the global table `_G`.
--
-- This module can be useful to debug, as these events usually go unnoticed.
--
-- @module util.safe

setmetatable(_G, {
    __index = function (t, k)
        warn(string.format('unset global variable %s', k))
    end,
    __newindex = function (t, k, v)
        warn(string.format('set global variable %s to %s', k, v))
    end,
})

warn('@on')
