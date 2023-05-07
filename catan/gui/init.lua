---
-- Renders a game of Catan using LÖVE2D.
--
-- @module catan.gui

require "util.compat"

local platform = require "util.platform"

local Game = require "catan.logic.game"
local FaceMap = require "catan.logic.facemap"
local VertexMap = require "catan.logic.vertexmap"
local Grid = require "catan.logic.grid"

local gutil = require "catan.gui.util"

local catan = {}

-------------------------
-- Environment variables
-------------------------

---
-- Debug mode
catan.debug = os.getenv "DEBUG" ~= nil

-- Rendering to-do list:
--
-- 1) Sea background - OK
-- 2) Harbors - OK
-- 3) Harbor ships - OK
-- 4) Hex tiles - OK
-- 5) Numbers - OK
-- 6) Robber - OK
-- 7) Roads
-- 8) Settlements/Cities
-- 9) Die

function catan:loadImgDir (dir)
    local t = {}
    for i, item in ipairs(love.filesystem.getDirectoryItems(dir)) do
        local path = dir .. platform.PATH_SEPARATOR .. item
        local info = love.filesystem.getInfo(path)
        local filetype = info.type
        if filetype == 'file' then
            local name = item:match"(.-)%.?[^%.]*$"
            assert(t[name] == nil, "key conflict")
            t[name] = love.graphics.newImage(path)
        elseif filetype == 'directory' then
            assert(t[item] == nil, "key conflict")
            t[item] = self:loadImgDir(path)
        end
    end
    return t
end

function catan:load ()
    love.window.setMode(1400, 900)
    love.window.setTitle"Settlers of Catan"
    love.graphics.setBackgroundColor(gutil:rgb(17, 78, 232))

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

function catan:getHexSize ()
    local W, H = love.window.getMode()
    return H / 12
end

function catan:getFaceCenter (q, r)
    local W, H = love.window.getMode()
    local x0 = W * 0.3
    local y0 = H * 0.5
    local hexsize = self:getHexSize()
    local sqrt3 = math.sqrt(3)
    local x = x0 + hexsize * (sqrt3 * q + sqrt3 / 2 * r)
    local y = y0 + hexsize * (3. / 2 * r)
    return x, y
end

function catan:getVertexPos (q, r, v)
    local x, y = self:getFaceCenter(q, r)
    local hexsize = self:getHexSize()
    if v == 'N' then
        y = y - hexsize
    else
        assert(v == 'S')
        y = y + hexsize
    end
    return x, y
end

-- Returns angles for north-vertex and south-vertex in CCW degrees
function catan:harborAnglesFromOrientation (o)
    if o == 'NE' then
        return 30, 90
    elseif o == 'NW' then
        return 150, 90
    elseif o == 'W' then
        return 150, -150
    elseif o == 'SW' then
        return -90, -150
    elseif o == 'SE' then
        return -90, -30
    else
        assert(o == 'E')
        return 30, -30
    end
end

function catan:getJoinedFaceWithHex (edge)
    for i, joinedFace in ipairs(Grid:joins(edge)) do
        if FaceMap:get(self.game.hexmap, joinedFace) then
            return joinedFace
        end
    end
end

function catan:getJoinedFaceWithoutHex (edge)
    for i, joinedFace in ipairs(Grid:joins(edge)) do
        if not FaceMap:get(self.game.hexmap, joinedFace) then
            return joinedFace
        end
    end
end

function catan:getHarborAngles (vertex1, vertex2)
    -- First, we get the edge between the vertices
    local edge = Grid:edgeInBetween(vertex1, vertex2)

    -- Then, we get the face joined by the edge
    -- which has a hex on top of it
    local face = self:getJoinedFaceWithHex(edge)
    assert(face ~= nil, "no joined face with hex")

    -- Now we calculate the angle of each harbor
    -- depending on the orientation of the edge
    -- in the neighbouring face with a hex
    local o = Grid:edgeOrientationInFace(face, edge)
    local r1, r2 = self:harborAnglesFromOrientation(o)

    -- Above, we assume vertex1 is a north-vertex and
    -- vertex2 is a south-vertex. If this is not true,
    -- we swap r1 and r2.
    if vertex1.v ~= 'N' then
        assert(vertex1.v == 'S')
        assert(vertex2.v == 'N')
        r1, r2 = r2, r1
    else
        assert(vertex2.v == 'S')
    end

    -- Now, we convert CCW degrees to CW radians
    r1 = gutil:ccwdeg2cwrad(r1)
    r2 = gutil:ccwdeg2cwrad(r2)

    return r1, r2, edge
end

function catan:getShipImageFromHarbor (harbor)
    if harbor == 'generic' then
        return self.images.harbor.ship3to1
    else
        return self.images.harbor.ship2to1
    end
end

function catan:constructSpriteList ()
    local sprites = {}

    local function addSprite(t)
        table.insert(sprites, {t[1], t.x, t.y, t.r, t.sx, t.sy, t.ox or 0, t.oy or 0})
    end

    local function addCentralizedSprite(t)
        local w, h = t[1]:getDimensions()
        local ox, oy = w/2, h/2
        t.ox = ox
        t.oy = oy
        addSprite(t)
        return t.x - ox, t.y - oy
    end

    local W, H = love.window.getMode()
    local hexsize = self:getHexSize()

    -- Harbors
    do
        local visited = {}
        local boardImg = self.images.harbor.board
        local oy = boardImg:getHeight() / 2
        local RES_SIZE = 25 -- size of resource
        local RES_OX = 30 -- x-offset of resource
        local RES_OY = 15 -- y-offset of resource
        VertexMap:iter(self.game.harbormap, function (q1, r1, v1, harbor)
            local vertex1 = Grid:vertex(q1, r1, v1)
            VertexMap:set(visited, vertex1, true)
            local adjvertices = Grid:adjacentVertices(vertex1)
            for _, vertex2 in ipairs(adjvertices) do
                if VertexMap:get(visited, vertex2) then
                    local x1, y1 = self:getVertexPos(q1, r1, v1)
                    local x2, y2 = self:getVertexPos(Grid:unpack(vertex2))
                    local a1, a2, edge = self:getHarborAngles(vertex1, vertex2)
                    addSprite{boardImg, x=x1, y=y1, r=a1, oy=oy}
                    addSprite{boardImg, x=x2, y=y2, r=a2, oy=oy}

                    local seaFace = self:getJoinedFaceWithoutHex(edge)
                    local x3, y3 = self:getFaceCenter(Grid:unpack(seaFace))
                    local shipImg = self:getShipImageFromHarbor(harbor)
                    local shipX, shipY = addCentralizedSprite{shipImg, x=x3, y=y3}
                    local resImg = self.images.resource[harbor]
                    if resImg ~= nil then
                        local s = RES_SIZE / resImg:getHeight()
                        local x4 = shipX + RES_OX
                        local y4 = shipY + RES_OY
                        addSprite{resImg, x=x4, y=y4, sx=s}
                    end
                end
            end
        end)
    end

    -- Hexes
    FaceMap:iter(self.game.hexmap, function (q, r, hex)
        local x, y = self:getFaceCenter(q, r)
        local img = assert(self.images.hex[hex], "missing hex sprite")
        local s = hexsize / (img:getHeight() / 2)
        addCentralizedSprite{img, x=x, y=y, sx=s}
    end)

    -- Number tokens
    FaceMap:iter(self.game.numbermap, function (q, r, number)
        local x, y = self:getFaceCenter(q, r)
        local img = assert(self.images.number[tostring(number)], "missing hex sprite")
        local s = (0.6 * hexsize) / img:getHeight()
        addCentralizedSprite{img, x=x, y=y, sx=s}
    end)

    -- Robber
    do
        local x, y = self:getFaceCenter(Grid:unpack(self.game.robber))
        local img = self.images.robber
        local s = (0.8 * hexsize) / img:getHeight()
        addCentralizedSprite{img, x=x, y=y, sx=s}
    end

    -- Sidebar
    do
        local x, y = W, 0
        local img = self.images.sidebar
        local w, h = img:getDimensions()
        local s = H / h
        addSprite{img, x=W, y=0, sx=s, ox=w}
    end

    return sprites
end

function catan:update (dt)
    if self.updatePending then
        self.sprites = self:constructSpriteList()
        self.updatePending = false
    end

    -- TODO: update animations using `dt`
end

return catan
