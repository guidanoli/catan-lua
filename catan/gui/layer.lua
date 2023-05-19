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

---
-- Table cell in  @{catan.gui.layer:addSpriteTable}
-- @tfield Drawable drawable the drawable object
-- @tfield[opt=1] number sx the horizontal scaling factor
-- @tfield[opt=sx] number sy the vertical scaling factor
Layer.SpriteTableCell = {}

---
-- Input for @{catan.gui.layer:addSpriteTable}
-- @tfield[opt=1] number n number of table lines
-- @tfield[opt=1] number m number of table columns
-- @tfield[opt=0] number x the sprite line horizontal coordinate
-- @tfield[opt=0] number y the sprite line vertical coordinate
-- @tfield[opt=0] number xsep the horizontal space between sprites
-- @tfield[opt=0] number ysep the vertical space between sprites
-- @tfield[opt='left'] string xalign the horizontal alignment for the whole sprite line
-- @tfield[opt='top'] string yalign the vertical alignment for the whole sprite line
Layer.SpriteTableInput = {}

---
-- Add a table of sprites
-- @tparam table t 2D array of @{catan.gui.layer.SpriteTableCell} and fields in @{catan.gui.layer.SpriteLineInput}
-- @treturn {{catan.gui.sprite.Sprite,...},...} 2D array with all the newly-created sprites
function Layer:addSpriteTable (t)
    local n = t.n or 1
    local m = t.m or 1
    local x = t.x or 0
    local y = t.y or 0
    local xsep = t.xsep or 0
    local ysep = t.ysep or 0
    local xalign = t.xalign or 'left'
    local yalign = t.yalign or 'top'

    local lineHeights = {}
    for i = 1, n do
        lineHeights[i] = 0
    end

    local columnWidths = {}
    for j = 1, m do
        columnWidths[j] = 0
    end

    for i = 1, n do
        local line = t[i]
        if line then
            for j = 1, m do
                local cell = line[j]
                if cell then
                    local w, h = cell.drawable:getDimensions()
                    local sx = cell.sx or 1
                    local sy = cell.sy or sx
                    lineHeights[i] = math.max(lineHeights[i], h * sy)
                    columnWidths[j] = math.max(columnWidths[j], w * sx)
                end
            end
        end
    end

    local h = 0
    for i, lineHeight in ipairs(lineHeights) do
        if i == 1 then
            h = h + lineHeight
        else
            h = h + ysep + lineHeight
        end
    end

    local w = 0
    for j, columnWidth in ipairs(columnWidths) do
        if j == 1 then
            w = w + columnWidth
        else
            w = w + xsep + columnWidth
        end
    end

    local x0
    if xalign == 'left' then
        x0 = x
    elseif xalign == 'center' then
        x0 = x - w / 2
    else
        assert(xalign == 'right')
        x0 = x - w
    end

    local y0
    if yalign == 'top' then
        y0 = y
    elseif yalign == 'center' then
        y0 = y - h / 2
    else
        assert(yalign == 'bottom')
        y0 = y - h
    end

    local sprites = {}
    for i = 1, n do
        sprites[i] = {}
    end

    y = y0
    for i = 1, n do
        local line = t[i]
        if line then
            x = x0
            for j = 1, m do
                local cell = line[j]
                if cell then
                    sprites[i][j] = self:addSprite{
                        cell.drawable,
                        x = x + columnWidths[j] / 2,
                        y = y + lineHeights[i] / 2,
                        sx = cell.sx,
                        sy = cell.sy,
                        center = true,
                    }
                end
                x = x + columnWidths[j] + xsep
            end
        end
        y = y + lineHeights[i] + ysep
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
