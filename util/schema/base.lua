return function ()
    local Class = {}
    Class.__index = Class
    Class.__call = function (obj, ...)
        Class.validate(obj, ...)
        return ...
    end
    Class.__new = function (t)
        return setmetatable(t, Class)
    end
    return Class
end
