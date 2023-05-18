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

function Layer:iterSprites (f)
    for i, sprite in ipairs(self) do
        local ret = f(sprite)
        if ret then return ret end
    end
end

return Layer
