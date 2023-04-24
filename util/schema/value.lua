local Value = {}
Value.__index = Value

function Value:validate(v, msg)
    assert(type(v) == self.vtype, msg)
end

return function (t)
    assert(type(t) == 'string')
    return setmetatable({vtype = t}, Value)
end
