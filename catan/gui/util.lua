---
-- Utility functions for graphics
--
-- @module catan.gui.util

local util = {}

---
-- Convert CCW degrees to CW radians
-- @tparam number a angle in CCW degrees
-- @treturn number angle in CW radians
function util:ccwdeg2cwrad (a)
    return - math.pi * a / 180.
end

return util
