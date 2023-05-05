local Game = require "catan.logic.game"

local catan = {}

-- Environment variables
catan.debug = os.getenv "DEBUG" ~= nil

-- GUI Constants
catan.DWIDTH = 1280
catan.DHEIGHT = 720
catan.TITLE = "Settlers of Catan"
catan.BGCOLOR = {0, 0, 1}

-- Rendering to-do list:
--
-- 1) Sea background - OK
-- 2) Harbor ships
-- 3) Harbors
-- 4) Hex tiles
-- 5) Numbers
-- 6) Robber
-- 7) Roads
-- 8) Settlements/Cities
-- 9) Die

function catan:load ()
    love.window.setMode(self.DWIDTH, self.DHEIGHT)
    love.window.setTitle(self.TITLE)
    love.graphics.setBackgroundColor(self.BGCOLOR)

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
