local Game = require "catan.logic.game"

local catan = {}

catan.debug = os.getenv "DEBUG" ~= nil

function catan:load ()
    love.window.setMode(1280, 720)
    love.window.setTitle("Settlers of Catan")

    math.randomseed(os.time())

    -- TODO: loading screen (choose players)
    self.game = Game:new()

    self.images = {}
    -- TODO: load images

    self.updatePending = true
end
 
function catan:draw ()
    -- TODO: use cached info to draw stuff on the window
end

function catan:mousepressed (...)
    -- TODO: process mouse clicks
end
 
function catan:keypressed (key)
    -- TODO: process key strokes
end

function catan:update (dt)
    if self.updatePending then
        -- TODO: update whatever needs to be updated
        self.updatePending = false
    end

    -- TODO: update animations using `dt`
end

return catan
