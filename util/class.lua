---
-- Defines classes and how to instantiate them.
--
--    local Class = require "util.class"
--    local Dog = Class "Dog"
--    local bob = Dog:__new{name = "Bob"}
--    print(bob)                   --> Dog: 0x55b03f40fa70
--    print(bob.name)              --> Bob
--    print(Dog:__isinstance{})    --> false
--    print(Dog:__isinstance(bob)) --> true
--
-- @module util.class

local function new (Class, t)
    return setmetatable(t, Class)
end

local function isinstance (Class, t)
    return Class == getmetatable(t)
end

return function (name)
    local Class = {}
    Class.__index = Class
    Class.__name = name
    Class.__new = new
    Class.__isinstance = isinstance
    return Class
end
