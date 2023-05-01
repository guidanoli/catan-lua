local Base = require "util.schema.base"
local join = require "util.schema.join"
local cast = require "util.schema.cast"

local Struct = Base()

function Struct:validate(t, msg)
    assert(type(t) == 'table', msg)
    for field in pairs(t) do
        assert(self[field] ~= nil, join(msg, field))
    end
    for field, schema in pairs(self) do
        schema:validate(t[field], join(msg, field))
    end
end

return function (t)
    assert(type(t) == 'table')
    local schema = {}
    for field, subschema in pairs(t) do
        schema[field] = cast(subschema)
    end
    return Struct.__new(schema)
end
