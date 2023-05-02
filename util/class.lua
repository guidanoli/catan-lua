--- Defines the function for defining classes
--
-- @module util.class

local new = require "util.new"

return function (name)
    local Class = {}
    Class.__index = Class
    Class.__name = name
    Class.__new = new
    return Class
end
