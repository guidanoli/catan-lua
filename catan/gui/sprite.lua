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
-- * `.onclick`: callback for when sprite is clicked
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
        r = r,
        sx = sx,
        sy = sy,
        ox = ox,
        oy = oy,
        img = img,
        transform = transform,
        onclick = s.onclick
    }
end

---
-- Get x-scale factor
-- @treturn number x-scale factor
function Sprite:getScaleX ()
    return self.sx or 1
end

---
-- Get y-scale factor
-- @treturn number y-scale factor
function Sprite:getScaleY ()
    return self.sy or self:getScaleX()
end

---
-- Get top-left corner coordinates
-- @treturn number x-coordinate
-- @treturn number y-coordinate
function Sprite:getCoords ()
    return self.x - self.ox * self:getScaleX(),
           self.y - self.oy * self:getScaleY()
end

---
-- Get sprite width
-- @treturn number width
function Sprite:getWidth ()
    local w = self.img:getWidth()
    return w * self:getScaleX()
end

---
-- Get sprite height
-- @treturn number height
function Sprite:getHeight ()
    local h = self.img:getHeight()
    return h * self:getScaleY()
end

---
-- Get sprite dimensions, taking scale into account
-- @treturn number width
-- @treturn number height
function Sprite:getDimensions ()
    local w, h = self.img:getDimensions()
    return w * self.sx, h * self.sy
end

---
-- Draw sprite on screen
function Sprite:draw ()
    love.graphics.draw(self.img, self.transform)
end

return Sprite
