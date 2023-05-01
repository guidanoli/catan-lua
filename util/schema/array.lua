local Base = require "util.schema.base"
local cast = require "util.schema.cast"
local join = require "util.schema.join"

local Array = Base()

function Array:validate(t, msg)
    msg = msg or ''
    assert(type(t) == 'table', msg)
    for k, v in pairs(t) do
        assert(type(k) == 'number', join(msg, k))
        assert(k >= 1 and k <= #t, join(msg, k))
    end
    for i = 1, #t do
        self.e:validate(t[i], join(msg, i))
    end
end

return function (t)
    return Array.__new{e = cast(t)}
end
