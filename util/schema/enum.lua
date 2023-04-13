local Enum = {}
Enum.__index = Enum

function Enum:validate(v)
    assert(type(v) == 'string')
    assert(self[v] == true)
end

return function (t)
    assert(type(t) == 'table')
    local schema = {}
    for _, field in pairs(t) do
        assert(type(field) == 'string')
        schema[field] = true
    end
    return setmetatable(schema, Enum)
end
