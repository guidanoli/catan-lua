---
-- Array of sprites
-- @module catan.gui.layer

local Class = require "util.class"

local Sprite = require "catan.gui.sprite"

---
-- A layer of sprites
-- @type Layer
local Layer = Class "Layer"

---
-- Create an empty layer
-- @treturn catan.gui.layer.Layer the newly-created layer
function Layer:new ()
    return Layer:__new{}
end

---
-- Add sprite to layer
-- @tparam table t input to `Sprite`
-- @treturn catan.gui.sprite.Sprite the newly-created sprite
function Layer:addSprite (t)
    local sprite = Sprite.new(t)
    table.insert(self, sprite)
    return sprite
end

---
-- Input for @{catan.gui.layer:addSpriteLine}
-- @tfield[opt=0] number x the sprite line horizontal coordinate
-- @tfield[opt=0] number y the sprite line vertical coordinate
-- @tfield[opt=0] number sep the horizontal space between sprites
-- @tfield[opt=1] number sx the horizontal scaling factor for all sprites
-- @tfield[opt=sx] number sy the vertical scaling factor for all sprites
-- @tfield[opt='left'] string xalign the horizontal alignment for the whole sprite line
-- @tfield[opt='top'] string yalign the vertical alignment for the whole sprite line
Layer.SpriteLineInput = {}

---
-- Add a horizontal line of sprites
-- @tparam table t array of `Drawable` objects and fields in @{catan.gui.layer.SpriteLineInput}
-- @treturn {catan.gui.sprite.Sprite,...} an array with all the newly-created sprites
function Layer:addSpriteLine (t)
    local x = t.x or 0
    local y = t.y or 0
    local sep = t.sep or 0
    local sx = t.sx or 1
    local sy = t.sy or sx
    local xalign = t.xalign or 'left'
    local yalign = t.yalign or 'top'

    local w = 0
    local first = true
    for i, drawable in ipairs(t) do
        w = w + drawable:getWidth() * sx
        if not first then
            w = w + sep
        end
        first = false
    end

    local maxh = 0
    for i, drawable in ipairs(t) do
        local h = drawable:getHeight()
        if h > maxh then maxh = h end
    end
    maxh = maxh * sy

    if xalign == 'center' then
        x = x - w / 2
    elseif xalign == 'right' then
        x = x - w
    end

    if yalign == 'center' then
        y = y - maxh / 2
    elseif yalign == 'bottom' then
        y = y - maxh
    end

    local sprites = {}

    for i, drawable in ipairs(t) do
        local sprite = self:addSprite{drawable, x=x, y=y, sx=sx, sy=sy}
        table.insert(sprites, sprite)
        x = x + sep + sprite:getWidth()
    end

    return sprites
end

function Layer:iterSprites (f)
    for i, sprite in ipairs(self) do
        local ret = f(sprite)
        if ret then return ret end
    end
end

return Layer
