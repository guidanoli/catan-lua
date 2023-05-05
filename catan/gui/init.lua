local Game = require "catan.logic.game"
local FaceMap = require "catan.logic.facemap"

-- Lua 5.1 compat
table.unpack = table.unpack or unpack

local catan = {}

-- Platform constants
catan.PATHSEP = package.config:sub(1, 1)

local function rgb (r, g, b)
    return {r/255, g/255, b/255}
end

-- GUI Constants
catan.DWIDTH = 1200
catan.DHEIGHT = 900
catan.TITLE = "Settlers of Catan"
catan.BGCOLOR = rgb(17, 78, 232)
catan.HEXSIZE = 75

-- Environment variables
catan.debug = os.getenv "DEBUG" ~= nil

-- Rendering to-do list:
--
-- 1) Sea background - OK
-- 2) Hex tiles - OK
-- 3) Harbor ships
-- 4) Harbors
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
    for i, sprite in ipairs(self.sprites) do
        love.graphics.draw(table.unpack(sprite))
    end
end

function catan:mousepressed (...)
    -- TODO: process mouse clicks
end
 
function catan:keypressed (key)
    -- TODO: process key strokes
end

function catan:getFaceCenter (q, r)
    local x0 = self.DWIDTH / 2
    local y0 = self.DHEIGHT / 2
    local size = self.HEXSIZE
    local sqrt3 = math.sqrt(3)
    local x = x0 + size * (sqrt3 * q + sqrt3 / 2 * r)
    local y = y0 + size * (3. / 2 * r)
    return x, y
end

function catan:updateSprites ()
    self.sprites = {}
    FaceMap:iter(self.game.hexmap, function (q, r, hex)
        local xcenter, ycenter = self:getFaceCenter(q, r)
        local img = assert(self.images.hex[hex], "missing hex sprite")
        local w, h = img:getDimensions()
        local s = self.HEXSIZE / (h / 2)
        local x = xcenter - s * w / 2
        local y = ycenter - s * h / 2
        table.insert(self.sprites, {img, x, y, 0, s})
    end)
end

function catan:update (dt)
    if self.updatePending then
        self:updateSprites()
        self.updatePending = false
    end

    -- TODO: update animations using `dt`
end

return catan
