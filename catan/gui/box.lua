---
-- Bounding box
-- @module catan.gui.box

local Class = require "util.class"

local TableUtils = require "util.table"

---
-- @type Box
local Box = Class"Box"

---
-- Input for @{catan.gui.box:new}
-- @tfield number x horizontal coordinate
-- @tfield number y vertical coordinate
-- @tfield number w width
-- @tfield number h height
Box.Input = {}

---
-- Create box
-- @tparam table t see @{catan.gui.box.Input}
-- @treturn catan.gui.box.Box the newly-created box
function Box:new (t)
    assert(type(t.x) == "number", "missing x")
    assert(type(t.y) == "number", "missing y")
    assert(type(t.w) == "number", "missing w")
    assert(type(t.h) == "number", "missing h")
    return Box:__new(t)
end

---
-- Create box from sprite
-- @tparam catan.gui.sprite.Sprite sprite the sprite
-- @treturn catan.gui.box.Box the newly-created box
function Box:fromSprite (sprite)
    return Box:new{
        x = sprite:getX(),
        y = sprite:getY(),
        w = sprite:getWidth(),
        h = sprite:getHeight(),
    }
end

---
-- Create box from the union of boxes
-- @tparam catan.gui.box.Box,... boxes
-- @treturn catan.gui.box.Box the newly-created box
function Box:fromUnion (...)
    local leftXs = {}
    local rightXs = {}
    local topYs = {}
    local bottomYs = {}

    for i, box in ipairs{...} do
        leftXs[i] = box:getLeftX()
        rightXs[i] = box:getRightX()
        topYs[i] = box:getTopY()
        bottomYs[i] = box:getBottomY()
    end

    local leftX = TableUtils:fold(math.min, leftXs)
    local rightX = TableUtils:fold(math.max, rightXs)
    local topY = TableUtils:fold(math.min, topYs)
    local bottomY = TableUtils:fold(math.max, bottomYs)

    return Box:new{
        x = leftX,
        y = topY,
        w = rightX - leftX,
        h = bottomY - topY,
    }
end

---
-- Create box with grown width and height
-- @tparam number dw amount to increase in width
-- @tparam[opt=dw] number dh amount to increase in height
-- @treturn catan.gui.box.Box the newly-created box
function Box:grow (dw, dh)
    if dh == nil then dh = dw end

    return Box:new{
        x = self.x - dw / 2,
        y = self.y - dh / 2,
        w = self.w + dw,
        h = self.h + dh,
    }
end

---
-- Get box width
-- @treturn number the box width
function Box:getWidth ()
    return self.w
end

---
-- Get box height
-- @treturn number the box height
function Box:getHeight ()
    return self.h
end

---
-- Get box left x coordinate
-- @treturn number the box left x coordinate
function Box:getLeftX ()
    return self.x
end

---
-- Get box right x coordinate
-- @treturn number the box right x coordinate
function Box:getRightX ()
    return self.x + self.w
end

---
-- Get box top y coordinate
-- @treturn number the box top y coordinate
function Box:getTopY ()
    return self.y
end

---
-- Get box bottom y coordinate
-- @treturn number the box bottom y coordinate
function Box:getBottomY ()
    return self.y + self.h
end

return Box
