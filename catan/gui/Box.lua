---
-- A rectangle with width, height, and `(x, y)` coordinates.
--
--    -- (0, 0)      (5, 0)
--    -- o-----------o
--    -- |           |
--    -- |           |
--    -- o-----------o
--    -- (0, 4)      (5, 4)
--
--    local box = Box:new{w=5, h=4, x=0, y=0}
--
--    print(box:getWidth())   --> 5
--    print(box:getHeight())  --> 4
--    print(box:getLeftX())   --> 0
--    print(box:getRightX())  --> 5
--    print(box:getTopY())    --> 0
--    print(box:getBottomY()) --> 4
--
--    -- (-10, 20)            (15, 20)
--    -- o--------------------o
--    -- |                    |
--    -- |                    |
--    -- |                    |
--    -- |                    |
--    -- o--------------------o
--    -- (-10, 24)            (15, 24)
--
--    local biggerBox = box:grow(20, 40)
--
--    print(biggerBox:getWidth())   --> 25
--    print(biggerBox:getHeight())  --> 44
--    print(biggerBox:getLeftX())   --> -10
--    print(biggerBox:getRightX())  --> 15
--    print(biggerBox:getTopY())    --> 20
--    print(biggerBox:getBottomY()) --> 24
--
--    -- (0, 0)      (5, 0)                       (0, 0)              (12, 0)
--    -- o---------------o                        o-------------------o
--    -- |               |                        |                   |
--    -- |        (4, 2) |       (12, 2)          |                   |
--    -- |        o------+-------o                |                   |
--    -- |        |      |       |          ===>  |                   |
--    -- o--------+------o       |                |                   |
--    -- (0, 7)   |      (5, 7)  |                |                   |
--    --          |              |                |                   |
--    --          o--------------o                o-------------------o
--    --          (4, 10)        (12, 10)         (0, 10)             (12, 10)  
--
--    local box1 = Box:new{w=5, h=7, x=0, y=0}
--    local box2 = Box:new{w=10, h=8, x=4, y=2}
--    local box1u2 = Box:fromUnion(box1, box2)
--
--    print(box1u2:getWidth())   --> 12
--    print(box1u2:getHeight())  --> 10
--    print(box1u2:getLeftX())   --> 0
--    print(box1u2:getRightX())  --> 12
--    print(box1u2:getTopY())    --> 0
--    print(box1u2:getBottomY()) --> 10
--
-- @classmod catan.gui.Box

local Class = require "util.class"

local TableUtils = require "util.table"

local Box = Class "Box"

---
-- Create box.
-- @tparam table t box data
-- @tparam number t.x x coordinate
-- @tparam number t.y y coordinate
-- @tparam number t.w width
-- @tparam number t.h height
-- @treturn catan.gui.Box a newly-created box
function Box:new (t)
    assert(type(t.x) == "number", "missing x")
    assert(type(t.y) == "number", "missing y")
    assert(type(t.w) == "number", "missing w")
    assert(type(t.h) == "number", "missing h")
    return self:__new(t)
end

---
-- Create box from sprite.
-- @tparam Sprite sprite the sprite
-- @treturn catan.gui.Box a newly-created box
function Box:fromSprite (sprite)
    return self:new{
        x = sprite:getX(),
        y = sprite:getY(),
        w = sprite:getWidth(),
        h = sprite:getHeight(),
    }
end

---
-- Create box from the union of boxes.
-- Must pass at least one box.
-- @tparam catan.gui.Box ... boxes
-- @treturn catan.gui.Box a newly-created box
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

    return self:new{
        x = leftX,
        y = topY,
        w = rightX - leftX,
        h = bottomY - topY,
    }
end

---
-- Grow a box by width and height.
-- @tparam number dw amount to increase symmetrically in width
-- @tparam[opt=dw] number dh amount to symmetrically increase in height
-- @treturn catan.gui.Box a newly-created box
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
-- Get box width.
-- @treturn number the box width
function Box:getWidth ()
    return self.w
end

---
-- Get box height.
-- @treturn number the box height
function Box:getHeight ()
    return self.h
end

---
-- Get box left x coordinate.
-- @treturn number the box left x coordinate
function Box:getLeftX ()
    return self.x
end

---
-- Get box right x coordinate.
-- @treturn number the box right x coordinate
function Box:getRightX ()
    return self.x + self.w
end

---
-- Get box top y coordinate.
-- @treturn number the box top y coordinate
function Box:getTopY ()
    return self.y
end

---
-- Get box bottom y coordinate.
-- @treturn number the box bottom y coordinate
function Box:getBottomY ()
    return self.y + self.h
end

return Box
