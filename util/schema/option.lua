local cast = require "util.schema.cast"

local Option = {}
Option.__index = Option

function Option:validate(t)
    local ok, err = pcall(function()
        return self.schema:validate(t)
    end)
    assert(ok or t == nil, err)
end

return function (t)
    local schema = { schema = cast(t) }
    return setmetatable(schema, Option)
end
