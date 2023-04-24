local join = require "util.schema.join"
local cast = require "util.schema.cast"

local Mapping = {}
Mapping.__index = Mapping

function Mapping:validate(t, msg)
    assert(type(t) == 'table', msg)
    for k, v in pairs(t) do
        self.k:validate(k, join(msg, k))
        self.v:validate(v, join(msg, v))
    end
end

return function (k, v)
    return setmetatable({k = cast(k), v = cast(v)}, Mapping)
end
