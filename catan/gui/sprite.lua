---
-- Game sprites ready to be drawn
--
-- @module catan.gui.sprite

local Class = require "util.class"

---
-- @type Sprite
local Sprite = Class "Sprite"

---
-- Input to @{catan.gui.sprite:new}
-- @tfield Drawable 1 image
-- @tfield[opt=0] number x x-coordinate
-- @tfield[opt=0] number y y-coordinate
-- @tfield[opt=0] number r clockwise rotation in radians
-- @tfield[opt=1] number sx x-scale factor
-- @tfield[opt=sx] number sy y-scale factor
-- @tfield[opt=0] number ox x-origin
-- @tfield[opt=0] number oy y-origin
-- @tfield[opt=true] boolean center center image, overwrites `xalign` and `yalign`
-- @tfield[opt='left'] string xalign how to align the image horizontally, overwrites `ox` (can be 'left', 'center' or 'right')
-- @tfield[opt='top'] string yalign how to align the image vertically, overwrites `oy` (can be 'top', 'center', 'bottom')
-- @tfield function onleftclick callback for when sprite is clicked with left mouse button
-- @tfield function onrightclick callback for when sprite is clicked with right mouse button
Sprite.Input = {}

---
-- Create a sprite
-- @tparam table s see @{catan.gui.sprite.Input}
-- @see love2d@Drawable
-- @treturn catan.gui.sprite.Sprite the newly-created sprite
function Sprite.new (s)
    local img = s[1]

    local x = math.floor(s.x or 0)
    local y = math.floor(s.y or 0)

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
    if yalign == 'bottom' then
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
-- Get top-left corner x-coordinate
-- @treturn number x-coordinate
function Sprite:getX ()
    return self.x - self.ox * self.sx
end

---
-- Get top-left corner y-coordinate
-- @treturn number y-coordinate
function Sprite:getY ()
    return self.y - self.oy * self.sy
end

---
-- Get top-left corner coordinates
-- @treturn number x-coordinate
-- @treturn number y-coordinate
function Sprite:getCoords ()
    return self:getX(), self:getY()
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
-- Check if sprite has callback
-- @treturn boolean whether sprite has callback
function Sprite:hasCallback ()
    return self.onleftclick ~= nil or self.onrightclick ~= nil
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
