local Base = require "util.schema.base"
local cast = require "util.schema.cast"

local Option = Base()

function Option:validate(t, msg)
    if t ~= nil then
        self.s:validate(t, msg)
    end
end

return function (t)
    return Option.__new{s = cast(t)}
end
