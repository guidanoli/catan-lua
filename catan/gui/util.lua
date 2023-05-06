---
-- Utility functions for graphics
--
-- @module catan.gui.util

local util = {}

---
-- Create table with normalized RGB values
-- @tparam number r red component (0-255)
-- @tparam number g green component (0-255)
-- @tparam number b blue component (0-255)
-- @treturn {number, number, number} RGB components (0-1)
function util:rgb (r, g, b)
    return {r/255, g/255, b/255}
end

---
-- Convert CCW degrees to CW radians
-- @tparam number a angle in CCW degrees
-- @treturn number angle in CW radians
function util:ccwdeg2cwrad (a)
    return - math.pi * a / 180.
end

return util
