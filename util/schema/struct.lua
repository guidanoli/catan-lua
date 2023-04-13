local cast = require "util.schema.cast"

local Struct = {}
Struct.__index = Struct

function Struct:validate(t)
    assert(type(t) == 'table')
    for field in pairs(t) do
        assert(self[field] ~= nil)
    end
    for field, schema in pairs(self) do
        schema:validate(t[field])
    end
end

return function (t)
    assert(type(t) == 'table')
    local schema = {}
    for field, subschema in pairs(t) do
        schema[field] = cast(subschema)
    end
    return setmetatable(schema, Struct)
end
