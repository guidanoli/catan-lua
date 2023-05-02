--- Defines the function for instantiating classes
--
-- @module util.new

return function (Class, t)
    return setmetatable(t, Class)
end
