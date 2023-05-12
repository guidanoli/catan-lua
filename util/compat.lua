---
-- Creates a compatibility layer for Lua 5.1
--
-- Defines the following variables:
--
-- * `table.unpack` (from `unpack`)
-- * `math.type`
--
-- @module util.compat

table.unpack = table.unpack or unpack

if math.type == nil then
    function math.type(n)
        if type(n) == "number" then
            if math.floor(n) == n then
                return "integer"
            else
                return "float"
            end
        else
            error("not a number", 2)
        end
    end
end
