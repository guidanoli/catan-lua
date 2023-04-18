local cast = require "util.schema.cast"

local Option = {}
Option.__index = Option

function Option:validate(t)
    local ok, err = pcall(function()
        return self.s:validate(t)
    end)
    assert(ok or t == nil, err)
end

return function (t)
    return setmetatable({s = cast(t)}, Option)
end
