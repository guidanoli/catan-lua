local Base = require "util.schema.base"

local Value = Base()

function Value:validate(v, msg)
    assert(type(v) == self.vtype, msg)
end

return function (t)
    assert(type(t) == 'string')
    return Value.__new{vtype = t}
end
