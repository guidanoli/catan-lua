local cast = require "util.schema.cast"

local Mapping = {}
Mapping.__index = Mapping

function Mapping:validate(t)
    assert(type(t) == 'table')
    for k, v in pairs(t) do
        self.k:validate(k)
        self.v:validate(v)
    end
end

return function (k, v)
    return setmetatable({k = cast(k), v = cast(v)}, Mapping)
end
