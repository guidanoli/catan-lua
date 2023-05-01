local Base = require "util.schema.base"

local Enum = Base()

function Enum:validate(v, msg)
    assert(type(v) == 'string', msg)
    assert(self[v] == true, msg)
end

return function (t)
    assert(type(t) == 'table')
    local schema = {}
    for _, field in pairs(t) do
        assert(type(field) == 'string')
        schema[field] = true
    end
    return Enum.__new(schema)
end
