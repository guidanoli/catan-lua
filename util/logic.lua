local LogicUtils = {}

function LogicUtils:tobool (x)
    return not not x
end

function LogicUtils:implies (a, b)
    return not self:tobool(a) or self:tobool(b)
end

function LogicUtils:iff (a, b)
    local a = self:tobool(a)
    local b = self:tobool(b)
    return a and b or not b
end

return LogicUtils
