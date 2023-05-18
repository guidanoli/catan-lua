local Class = require "util.class"

local Sprite = require "catan.gui.sprite"

local Layer = Class "Layer"

function Layer:new ()
    return Layer:__new{}
end

function Layer:addSprite (t)
    local sprite = Sprite.new(t)
    table.insert(self, sprite)
    return sprite
end

return Layer
