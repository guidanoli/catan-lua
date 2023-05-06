require "util.compat"

local platform = require "util.platform"

local Game = require "catan.logic.game"
local FaceMap = require "catan.logic.facemap"
local VertexMap = require "catan.logic.vertexmap"
local Grid = require "catan.logic.grid"

local gutil = require "catan.gui.util"

local catan = {}

-- GUI Constants
catan.DWIDTH = 1200
catan.DHEIGHT = 900
catan.TITLE = "Settlers of Catan"
catan.BGCOLOR = gutil:rgb(17, 78, 232)
catan.HEXSIZE = 75

-- Environment variables
catan.debug = os.getenv "DEBUG" ~= nil

-- Rendering to-do list:
--
-- 1) Sea background - OK
-- 2) Harbors - OK
-- 3) Hex tiles - OK
-- 4) Harbor ships
-- 5) Numbers
-- 6) Robber
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

function catan:getVertexPos (q, r, v)
    local x, y = self:getFaceCenter(q, r)
    if v == 'N' then
        y = y - self.HEXSIZE
    else
        assert(v == 'S')
        y = y + self.HEXSIZE
    end
    return x, y
end

-- Returns angles for north-vertex and south-vertex in CCW degrees
function catan:harbourAnglesFromOrientation (o)
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

function catan:getHarbourAngles (vertex1, vertex2)
    local edge = Grid:edgeInBetween(vertex1, vertex2)

    -- Here, we find the neighbouring face with a hex
    local face
    for i, joinedFace in ipairs(Grid:joins(edge)) do
        if FaceMap:get(self.game.hexmap, joinedFace) then
            face = joinedFace
        end
    end
    assert(face ~= nil, "no neighbouring hex")

    -- Now we calculate the angle of each harbor
    -- depending on the orientation of the edge
    -- in the neighbouring face with a hex
    local o = Grid:edgeOrientationInFace(face, edge)
    local r1, r2 = self:harbourAnglesFromOrientation(o)

    -- Above, we assume vertex1 is a north-vertex and
    -- vertex2 is a south-vertex. If this is not true,
    -- we swap r1 and r2.
    if vertex1.v ~= 'N' then
        assert(vertex1.v == 'S')
        r1, r2 = r2, r1
    end

    -- Now, we convert CCW degrees to CW radians
    r1 = gutil:ccwdeg2cwrad(r1)
    r2 = gutil:ccwdeg2cwrad(r2)

    return r1, r2
end

function catan:updateSprites ()
    self.sprites = {}

    -- Harbors
    do
        local visited = {}
        local boardImg = self.images.harbor.board
        local oy = boardImg:getHeight() / 2
        VertexMap:iter(self.game.harbormap, function (q1, r1, v1, harbor)
            local vertex1 = Grid:vertex(q1, r1, v1)
            VertexMap:set(visited, vertex1, true)
            local adjvertices = Grid:adjacentVertices(vertex1)
            for _, vertex2 in ipairs(adjvertices) do
                if VertexMap:get(visited, vertex2) then
                    local x1, y1 = self:getVertexPos(q1, r1, v1)
                    local x2, y2 = self:getVertexPos(Grid:unpack(vertex2))
                    local a1, a2 = self:getHarbourAngles(vertex1, vertex2)
                    table.insert(self.sprites, {boardImg, x1, y1, a1, nil, nil, nil, oy})
                    table.insert(self.sprites, {boardImg, x2, y2, a2, nil, nil, nil, oy})
                end
            end
        end)
    end

    -- Hexes
    FaceMap:iter(self.game.hexmap, function (q, r, hex)
        local x, y = self:getFaceCenter(q, r)
        local img = assert(self.images.hex[hex], "missing hex sprite")
        local w, h = img:getDimensions()
        local ox, oy = w / 2, h / 2
        local s = self.HEXSIZE / (h / 2)
        table.insert(self.sprites, {img, x, y, nil, s, nil, ox, oy})
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
