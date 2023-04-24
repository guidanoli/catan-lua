local cast = require "util.schema.cast"

local Option = {}
Option.__index = Option

function Option:validate(t, msg)
    if t ~= nil then
        self.s:validate(t, msg)
    end
end

return function (t)
    return setmetatable({s = cast(t)}, Option)
end
