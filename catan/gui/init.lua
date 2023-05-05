local Game = require "catan.logic.game"

local catan = {}

-- Platform constants
catan.PATHSEP = package.config:sub(1, 1)

-- Environment variables
catan.debug = os.getenv "DEBUG" ~= nil

local function rgb (r, g, b)
    return {r/255, g/255, b/255}
end

-- GUI Constants
catan.DWIDTH = 900
catan.DHEIGHT = 900
catan.TITLE = "Settlers of Catan"
catan.BGCOLOR = rgb(17, 78, 232)

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

function catan:loadImgDir (dir)
    local t = {}
    for i, item in ipairs(love.filesystem.getDirectoryItems(dir)) do
        local path = dir .. self.PATHSEP .. item
        local info = love.filesystem.getInfo(path)
        local filetype = info.type
        if filetype == 'file' then
            local name, ext = item:match"(.-)%.?([^%.]*)$"
            if ext:lower() == 'png' then
                t[name] = love.graphics.newImage(path)
            end
        elseif filetype == 'directory' then
            t[item] = self:loadImgDir(path)
        end
    end
    return t
end

function catan:load ()
    love.window.setMode(self.DWIDTH, self.DHEIGHT)
    love.window.setTitle(self.TITLE)
    love.graphics.setBackgroundColor(self.BGCOLOR)

    math.randomseed(os.time())

    -- TODO: loading screen (choose players)
    self.game = Game:new()

    self.images = self:loadImgDir"images"

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
