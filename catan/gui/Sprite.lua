---
-- Drawable objects with extra rendering information.
--
-- Every sprite carries a drawable object (e.g. an image),
-- and rendering information (which are used when drawing the
-- object onto the screen).
--
-- @classmod catan.gui.Sprite

local Class = require "util.class"

local Sprite = Class "Sprite"

---
-- Create a sprite
-- @tparam Drawable img drawable object
-- @tparam table t sprite metadata
-- @tparam[opt=0] number t.x x-coordinate
-- @tparam[opt=0] number t.y y-coordinate
-- @tparam[opt=0] number t.r clockwise rotation in radians
-- @tparam[opt=1] number t.sx x-scale factor
-- @tparam[opt=sx] number t.sy y-scale factor
-- @tparam[opt=0] number t.ox x-origin
-- @tparam[opt=0] number t.oy y-origin
-- @tparam[opt=true] boolean t.center center image, overwrites `xalign` and `yalign`
-- @tparam[opt='left'] string t.xalign how to align the image horizontally, overwrites `ox` (can be 'left', 'center' or 'right')
-- @tparam[opt='top'] string t.yalign how to align the image vertically, overwrites `oy` (can be 'top', 'center', 'bottom')
-- @tparam function t.onleftclick callback for when sprite is clicked with left mouse button
-- @tparam function t.onrightclick callback for when sprite is clicked with right mouse button
-- @see love2d@Drawable
-- @treturn catan.gui.Sprite the newly-created sprite
function Sprite:new (img, t)
    local x = math.floor(t.x or 0)
    local y = math.floor(t.y or 0)

    local r = t.r or 0

    local sx = t.sx or 1
    local sy = t.sy or sx

    local xalign = t.xalign or 'left'
    local yalign = t.yalign or 'top'

    if t.center then
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
        assert(xalign == 'left')
        ox = t.ox or 0
    end

    local oy
    if yalign == 'bottom' then
        oy = h
    elseif yalign == 'center' then
        oy = h/2
    else
        assert(yalign == 'top')
        oy = t.oy or 0
    end

    local transform = love.math.newTransform(x, y, r, sx, sy, ox, oy)

    return self:__new{
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
        onleftclick = t.onleftclick,
        onrightclick = t.onrightclick,
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
function Sprite:contains (x, y)
    local globalX, globalY = self.transform:inverseTransformPoint(x, y)
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
-- @treturn boolean whether the callback was called
function Sprite:leftclick (x, y)
    if self.onleftclick and self:contains(x, y) then
        self.onleftclick()
        return true
    end
    return false
end

---
-- If (x, y) is inside sprite, trigger any "right click" callback
-- @tparam number x x-coordinate
-- @tparam number y y-coordinate
-- @treturn boolean whether the callback was called
function Sprite:rightclick (x, y)
    if self.onrightclick and self:contains(x, y) then
        self.onrightclick()
        return true
    end
    return false
end

return Sprite
