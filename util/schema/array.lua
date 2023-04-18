local cast = require "util.schema.cast"

local Array = {}
Array.__index = Array

function Array:validate(t)
    assert(type(t) == 'table')
    for k, v in pairs(t) do
        assert(type(k) == 'number')
        assert(k >= 1 and k <= #t)
    end
    for i = 1, #t do
        self.e:validate(t[i])
    end
end

return function (t)
    return setmetatable({e = cast(t)}, Array)
end
