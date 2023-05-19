---
-- Array of sprites
-- @module catan.gui.layer

local Class = require "util.class"

local Sprite = require "catan.gui.sprite"

---
-- @type Layer
local Layer = Class "Layer"

---
-- Create an empty layer
-- @treturn Layer the newly-created layer
function Layer:new ()
    return Layer:__new{}
end

---
-- Add sprite to layer
-- @tparam {Sprite,...} t input to `Sprite`
-- @treturn Sprite the newly-created sprite
function Layer:addSprite (t)
    local sprite = Sprite.new(t)
    table.insert(self, sprite)
    return sprite
end

---
-- Add a horizontal line of sprites
-- @tparam {Drawable,...,x=number,y=number,sep=number,xalign=string,yalign=string}
--         line an array of `Drawable` inputs and some paramaters about positioning
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
