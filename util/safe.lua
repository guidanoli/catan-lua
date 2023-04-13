setmetatable(_G, {
    __index = function (t, k)
        error(string.format('unset global variable %s', k))
    end,
    __newindex = function (t, k, v)
        warn(string.format('set global variable %s to %s', k, v))
    end,
})
