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
-- Table parameter `t` MUST have the following fields:
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
--
-- @tparam table t sprite information
-- @treturn Sprite new sprite
function Sprite.new (t)
    local img = t[1]
    local w, h = img:getDimensions()

    local xalign = t.xalign
    local yalign = t.yalign

    if t.center then
        xalign = 'center'
        yalign = 'center'
    end

    if xalign == 'right' then
        t.ox = w
    elseif xalign == 'center' then
        t.ox = w/2
    elseif t.ox == nil then
        t.ox = 0
    end

    if yalign == 'top' then
        t.oy = h
    elseif yalign == 'center' then
        t.oy = h/2
    elseif t.oy == nil then
        t.oy = 0
    end

    return Sprite:__new(t)
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
    local w = self[1]:getWidth()
    return w * self:getScaleX()
end

---
-- Get sprite height
-- @treturn number height
function Sprite:getHeight ()
    local h = self[1]:getHeight()
    return h * self:getScaleY()
end

---
-- Get sprite dimensions, taking scale into account
-- @treturn number width
-- @treturn number height
function Sprite:getDimensions ()
    local w, h = self[1]:getDimensions()
    return w * self.sx, h * self.sy
end

---
-- Draw sprite on screen
function Sprite:draw ()
    love.graphics.draw(
        self[1],
        self.x,
        self.y,
        self.r,
        self.sx,
        self.sy,
        self.ox,
        self.oy
    )
end

return Sprite