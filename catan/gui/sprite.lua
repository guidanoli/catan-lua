---
-- Game sprites ready to be drawn
--
-- @module catan.gui.sprite

require "util.compat"

local Class = require "util.class"

---
-- @type Sprite
local Sprite = Class "Sprite"

---
-- Create a new sprite
--
-- Table parameter `s` MUST have the following fields:
--
-- * `[1]`: drawable object (Image, Text, etc)
-- * `.x`: x-coordinate (`number`)
-- * `.y`: y-coordinate (`number`)
--
-- and it CAN have:
--
-- * `.r`: clockwise rotation in radians (`number`)
-- * `.sx`: x-scale factor (`number`)
-- * `.sy`: y-scale factor (`number`)
-- * `.ox`: x-origin (`number`)
-- * `.oy`: y-origin (`number`)
-- * `.center`: center image, same as `{.xalign = "center", .yalign = "center"}` (`boolean`)
-- * `.xalign`: how to align the image horizontally, overwrites `.ox` (`"left"`, `"center"`, or `"right"`)
-- * `.yalign`: how to align the image vertically, overwrites `.oy` (`"top"`, `"center"`, or `"bottom"`)
-- * `.onleftclick`: callback for when sprite is clicked with left mouse button
-- * `.onrightclick`: callback for when sprite is clicked with right mouse button
--
-- @tparam table s sprite information
-- @treturn Sprite new sprite
function Sprite.new (s)
    local img = s[1]

    local x = assert(s.x, "missing x")
    local y = assert(s.y, "missing y")

    local r = s.r or 0

    local sx = s.sx or 1
    local sy = s.sy or sx

    local xalign = s.xalign
    local yalign = s.yalign

    if s.center then
        xalign = 'center'
        yalign = 'center'
    end

    local w, h = img:getDimensions()

    local ox
    if xalign == 'right' then
        ox = w
    elseif xalign == 'center' then
        ox = w/2
    else
        ox = s.ox or 0
    end

    local oy
    if yalign == 'top' then
        oy = h
    elseif yalign == 'center' then
        oy = h/2
    else
        oy = s.oy or 0
    end

    local transform = love.math.newTransform(x, y, r, sx, sy, ox, oy)

    return Sprite:__new{
        x = x,
        y = y,
        w = w,
        h = h,
        r = r,
        sx = sx,
        sy = sy,
        ox = ox,
        oy = oy,
        img = img,
        transform = transform,
        onleftclick = s.onleftclick,
        onrightclick = s.onrightclick,
    }
end

---
-- Get top-left corner coordinates
-- @treturn number x-coordinate
-- @treturn number y-coordinate
function Sprite:getCoords ()
    return self.x - self.ox * self.sx,
           self.y - self.oy * self.sy
end

---
-- Get sprite width
-- @treturn number width
function Sprite:getWidth ()
    return self.w * self.sx
end

---
-- Get sprite height
-- @treturn number height
function Sprite:getHeight ()
    return self.h * self.sy
end

---
-- Get sprite dimensions, taking scale into account
-- @treturn number width
-- @treturn number height
function Sprite:getDimensions ()
    return self:getWidth(), self:getHeight()
end

---
-- Draw sprite on screen
function Sprite:draw ()
    love.graphics.draw(self.img, self.transform)
end

---
-- Check if (x, y) is inside sprite
-- @tparam number x x-coordinate
-- @tparam number y y-coordinate
-- @treturn boolean whether point is inside sprite
function Sprite:contains (localX, localY)
    local globalX, globalY = self.transform:inverseTransformPoint(localX, localY)
    return globalX >= 0 and globalX <= self.w and
           globalY >= 0 and globalY <= self.h
end

---
-- If (x, y) is inside sprite, trigger any "left click" callback
-- @tparam number x x-coordinate
-- @tparam number y y-coordinate
-- @param ... forwarded to the callback
-- @return whatever the callback returns
function Sprite:leftclick (x, y, ...)
    if self.onleftclick and self:contains(x, y) then
        return self.onleftclick(...)
    end
end

---
-- If (x, y) is inside sprite, trigger any "right click" callback
-- @tparam number x x-coordinate
-- @tparam number y y-coordinate
-- @param ... forwarded to the callback
-- @return whatever the callback returns
function Sprite:rightclick (x, y, ...)
    if self.onrightclick and self:contains(x, y) then
        return self.onrightclick(...)
    end
end

return Sprite
