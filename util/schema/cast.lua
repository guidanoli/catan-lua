local Value = require "util.schema.value"

return function (t)
    if type(t) == 'string' then
        return Value(t)
    else
        return t
    end
end
