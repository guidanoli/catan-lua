local Base = require "util.schema.base"
local join = require "util.schema.join"
local cast = require "util.schema.cast"

local Mapping = Base()

function Mapping:validate(t, msg)
    assert(type(t) == 'table', msg)
    for k, v in pairs(t) do
        self.k:validate(k, join(msg, k))
        self.v:validate(v, join(msg, v))
    end
end

return function (k, v)
    return Mapping.__new{k = cast(k), v = cast(v)}
end
