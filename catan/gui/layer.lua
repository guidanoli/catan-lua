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
-- Table cell in  @{catan.gui.layer:addSpriteTable}
-- @tfield Drawable 1 the drawable object
-- @tfield[opt=1] number sx the horizontal scaling factor
-- @tfield[opt=sx] number sy the vertical scaling factor
-- @tfield[opt=nil] function onleftclick left-click callback
-- @tfield[opt=nil] function onrightclick right-click callback
-- @see love2d@Drawable
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
-- @tfield[opt=nil] Drawable bgimg background image
-- @tfield[opt=0] number bgmargin background margin
Layer.SpriteTableInput = {}

---
-- Add a table of sprites
-- @tparam table t 2D array of @{catan.gui.layer.SpriteTableCell} or `Drawable` and fields in @{catan.gui.layer.SpriteTableInput}
-- @treturn {{catan.gui.sprite.Sprite,...},...} 2D array with all the newly-created sprites
-- @see love2d@Drawable
function Layer:addSpriteTable (t)
    local n = t.n or 1
    local m = t.m or 1
    local x = t.x or 0
    local y = t.y or 0
    local xsep = t.xsep or 0
    local ysep = t.ysep or 0
    local xalign = t.xalign or 'left'
    local yalign = t.yalign or 'top'
    local bgimg = t.bgimg
    local bgmargin = t.bgmargin or 0

    local lineHeights = {}
    for i = 1, n do
        lineHeights[i] = 0
    end

    local columnWidths = {}
    for j = 1, m do
        columnWidths[j] = 0
    end

    local function cellimg (cell)
        if type(cell) == 'table' then
            return cell[1]
        else
            return cell
        end
    end

    local function cellsx (cell)
        if type(cell) == 'table' then
            return cell.sx
        end
    end

    local function cellsy (cell)
        if type(cell) == 'table' then
            return cell.sy
        end
    end

    local function cellonleftclick (cell)
        if type(cell) == 'table' then
            return cell.onleftclick
        end
    end

    local function cellonrightclick (cell)
        if type(cell) == 'table' then
            return cell.onrightclick
        end
    end

    for i = 1, n do
        local line = t[i]
        if line then
            for j = 1, m do
                local cell = line[j]
                if cell then
                    local w, h = cellimg(cell):getDimensions()
                    local sx = cellsx(cell) or 1
                    local sy = cellsy(cell) or sx
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

    if bgimg ~= nil then
        self:addSprite{
            bgimg,
            x = x0 - bgmargin,
            y = y0 - bgmargin,
            sx = w + 2 * bgmargin,
            sy = h + 2 * bgmargin,
        }
    end

    y = y0
    for i = 1, n do
        local line = t[i]
        if line then
            x = x0
            for j = 1, m do
                local cell = line[j]
                if cell then
                    self:addSprite{
                        cellimg(cell),
                        x = x + columnWidths[j] / 2,
                        y = y + lineHeights[i] / 2,
                        sx = cellsx(cell),
                        sy = cellsy(cell),
                        onleftclick = cellonleftclick(cell),
                        onrightclick = cellonrightclick(cell),
                        center = true,
                    }
                end
                x = x + columnWidths[j] + xsep
            end
        end
        y = y + lineHeights[i] + ysep
    end

    if bgimg == nil then
        return {
            x = x0,
            y = y0,
            w = w,
            h = h,
        }
    else
        return {
            x = x0 - bgmargin,
            y = y0 - bgmargin,
            w = w + 2 * bgmargin,
            h = h + 2 * bgmargin,
        }
    end
end

function Layer:iterSprites (f)
    for i, sprite in ipairs(self) do
        local ret = f(sprite)
        if ret then return ret end
    end
end

return Layer
