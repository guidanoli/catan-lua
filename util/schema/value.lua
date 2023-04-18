local Value = {}
Value.__index = Value

function Value:validate(v)
    assert(type(v) == self.vtype)
end

return function (t)
    assert(type(t) == 'string')
    return setmetatable({vtype = t}, Value)
end
