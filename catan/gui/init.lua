---
-- Renders a game of Catan using LÖVE2D.
--
-- @module catan.gui

local platform = require "util.platform"

local Game = require "catan.logic.game"
local FaceMap = require "catan.logic.facemap"
local VertexMap = require "catan.logic.vertexmap"
local EdgeMap = require "catan.logic.edgemap"
local Grid = require "catan.logic.grid"

local gutil = require "catan.gui.util"
local Sprite = require "catan.gui.sprite"

local catan = {}

-- Environment variables

catan.DEBUG = os.getenv "DEBUG" ~= nil

-- GUI constants

catan.LAYER_NAMES = {
    "board",
    "sidebar",
}

-- Rendering to-do list:
--
-- 1) Sea background - OK
-- 2) Harbors - OK
-- 3) Harbor ships - OK
-- 4) Hex tiles - OK
-- 5) Numbers - OK
-- 6) Robber - OK
-- 7) Roads - OK
-- 8) Settlements/Cities - WIP
-- 9) Die

function catan:loadImgDir (dir)
    local t = {}
    local function setifnil (key, value)
        assert(rawget(t, key) == nil, "key conflict")
        rawset(t, key, value)
    end
    for i, item in ipairs(love.filesystem.getDirectoryItems(dir)) do
        local path = dir .. platform.PATH_SEPARATOR .. item
        local info = love.filesystem.getInfo(path)
        local filetype = info.type
        if filetype == 'file' then
            local name = item:match"(.-)%.?[^%.]*$"
            setifnil(name, love.graphics.newImage(path))
        elseif filetype == 'directory' then
            setifnil(item, self:loadImgDir(path))
        end
    end
    return t
end

function catan:requestLayerUpdate (layername)
    self.layersPendingUpdate[layername] = true
end

function catan:requestAllLayersUpdate ()
    for i, layername in ipairs(self.LAYER_NAMES) do
        self:requestLayerUpdate(layername)
    end
end

function catan:requestValidation ()
    self.validationPending = true
end

function catan:load ()
    love.window.setMode(1400, 900)
    love.window.setTitle"Settlers of Catan"
    love.graphics.setBackgroundColor(love.math.colorFromBytes(17, 78, 232))

    math.randomseed(os.time())

    -- TODO: loading screen (choose players)
    self.game = Game:new()

    self.images = self:loadImgDir"images"

    self.font = love.graphics.newFont(20)

    self.layers = {}

    self.layersPendingUpdate = {}

    self:requestAllLayersUpdate()
    self:requestValidation()
end

function catan:iterSprites (f)
    for i, layername in ipairs(self.LAYER_NAMES) do
        for j, sprite in ipairs(self.layers[layername]) do
            if f(sprite) then
                return
            end
        end
    end
end

function catan:draw ()
    self:iterSprites(function (sprite) sprite:draw() end)
end

function catan:mousepressed (x, y, button)
    if button == 1 then
        self:iterSprites(function (sprite) sprite:leftclick(x, y) end)
    elseif button == 2 then
        self:iterSprites(function (sprite) sprite:rightclick(x, y) end)
    end
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

function catan:getEdgeCenter (q, r, e)
    local endpoints = Grid:endpoints(q, r, e)
    assert(#endpoints == 2)
    local x1, y1 = self:getVertexPos(Grid:unpack(endpoints[1]))
    local x2, y2 = self:getVertexPos(Grid:unpack(endpoints[2]))
    return (x1 + x2) / 2, (y1 + y2) / 2
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
    for i, joinedFace in ipairs(Grid:joins(Grid:unpack(edge))) do
        if FaceMap:get(self.game.hexmap, joinedFace) then
            return joinedFace
        end
    end
end

function catan:getJoinedFaceWithoutHex (edge)
    for i, joinedFace in ipairs(Grid:joins(Grid:unpack(edge))) do
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

function catan:getAvailableVerticesForInitialSettlement ()
    local available = {}

    -- Add all vertices to the set
    FaceMap:iter(self.game.hexmap, function (q, r)
        for i, vertex in ipairs(Grid:corners(q, r)) do
            VertexMap:set(available, vertex, true)
        end
    end)

    -- Remove all vertices occupied by some building or next to one
    VertexMap:iter(self.game.buildmap, function (q, r, v)
        VertexMap:set(available, Grid:vertex(q, r, v), nil)
        for i, vertex in ipairs(Grid:adjacentVertices(q, r, v)) do
            VertexMap:set(available, vertex, nil)
        end
    end)

    return available
end

function catan:getAvailableEdgesForInitialRoad ()
    local available = {}

    -- Find the player's building with no protruding roads and
    -- add to the set only those edges that join some face with hex
    VertexMap:iter(self.game.buildmap, function (q, r, v, building)
        if building.player == self.game.player then
            local protrudingEdges = Grid:protrudingEdges(q, r, v)
            for i, edge in ipairs(protrudingEdges) do
                if EdgeMap:get(self.game.roadmap, edge) then
                    return false -- skip to next iteration
                end
            end
            for i, edge in ipairs(protrudingEdges) do
                if self:getJoinedFaceWithHex(edge) then
                    EdgeMap:set(available, edge, true)
                end
            end
            return true -- quit iteration
        end
    end)

    return available
end

function catan:getRoadAngleForEdge (e)
    local r
    if e == 'NE' then
        r = 150
    elseif e == 'NW' then
        r = 210
    else
        assert(e == 'W')
        r = 270
    end
    return gutil:ccwdeg2cwrad(r)
end

function catan:placeInitialSettlement (q, r, v)
    self.game:placeInitialSettlement(Grid:vertex(q, r, v))
    self:requestAllLayersUpdate()
    self:requestValidation()
end

function catan:placeInitialRoad (q, r, e)
    self.game:placeInitialRoad(Grid:edge(q, r, e))
    self:requestAllLayersUpdate()
    self:requestValidation()
end

catan.renderers = {}

function catan.renderers:board ()
    local layer = {}

    local function addSprite (t)
        local sprite = Sprite.new(t)
        table.insert(layer, sprite)
        return sprite
    end

    local W, H = love.window.getMode()
    local hexsize = self:getHexSize()

    -- Harbors
    do
        local boardImg = self.images.harbor.board
        local visited = {}
        local oy = boardImg:getHeight() / 2
        local RES_SIZE = 25 -- size of resource
        local RES_OX = 30 -- x-offset of resource
        local RES_OY = 15 -- y-offset of resource

        VertexMap:iter(self.game.harbormap, function (q1, r1, v1, harbor)
            local vertex1 = Grid:vertex(q1, r1, v1)
            VertexMap:set(visited, vertex1, true)
            local adjvertices = Grid:adjacentVertices(q1, r1, v1)
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
                    local shipSprite = addSprite{shipImg, x=x3, y=y3, center=true}
                    local shipX, shipY = shipSprite:getCoords()
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
        local img = assert(self.images.hex[hex], "missing hex sprite")
        local x, y = self:getFaceCenter(q, r)
        local s = hexsize / (img:getHeight() / 2)
        addSprite{img, x=x, y=y, sx=s, center=true}
    end)

    -- Number tokens
    FaceMap:iter(self.game.numbermap, function (q, r, number)
        local img = assert(self.images.number[tostring(number)], "missing token sprite")
        local x, y = self:getFaceCenter(q, r)
        local s = (0.6 * hexsize) / img:getHeight()
        addSprite{img, x=x, y=y, sx=s, center=true}
    end)

    -- Vertex selection
    if self.game.phase == "placingInitialSettlement" then
        local available = self:getAvailableVerticesForInitialSettlement()
        local img = self.images.selection
        VertexMap:iter(available, function (q, r, v)
            local x, y = self:getVertexPos(q, r, v)
            addSprite{
                img,
                x = x,
                y = y,
                sx = 0.5,
                center = true,
                onleftclick = function ()
                    self:placeInitialSettlement(q, r, v)
                end,
            }
        end)
    end

    -- Edge selection
    if self.game.phase == "placingInitialRoad" then
        local available = self:getAvailableEdgesForInitialRoad()
        local img = self.images.selection
        EdgeMap:iter(available, function (q, r, e)
            local x, y = self:getEdgeCenter(q, r, e)
            addSprite{
                img,
                x = x,
                y = y,
                sx = 0.5,
                center = true,
                onleftclick = function ()
                    self:placeInitialRoad(q, r, e)
                end
            }
        end)
    end

    -- Roads
    do
        EdgeMap:iter(self.game.roadmap, function (q, r, e, player)
            local x, y = self:getEdgeCenter(q, r, e)
            local r = self:getRoadAngleForEdge(e)
            local img = assert(self.images.road[player], "missing road image")
            addSprite{img, x=x, y=y, r=r, sx=0.25, center=true}
        end)
    end

    -- Buildings
    do
        VertexMap:iter(self.game.buildmap, function (q, r, v, building)
            local x, y = self:getVertexPos(q, r, v)
            if building.kind == "settlement" then
                local img = assert(self.images.settlement[building.player], "missing settlement image")
                addSprite{img, x=x, y=y, sx=0.5, center=true}
            else
                assert(building.kind == "city")
                -- TODO: render cities
            end
        end)
    end

    -- Robber
    do
        local img = self.images.robber
        local x, y = self:getFaceCenter(Grid:unpack(self.game.robber))
        local s = (0.8 * hexsize) / img:getHeight()
        addSprite{img, x=x, y=y, sx=s, center=true}
    end

    return layer
end

function catan.renderers:sidebar ()
    local layer = {}

    local function addSprite (t)
        local sprite = Sprite.new(t)
        table.insert(layer, sprite)
        return sprite
    end

    local W, H = love.window.getMode()

    do
        local sidebarImg = self.images.sidebar
        local s = H / sidebarImg:getHeight()
        local sidebarSprite = addSprite{sidebarImg, x=W, y=0, sx=s, xalign='right'}
        local sidebarX, sidebarY = sidebarSprite:getCoords()

        local ITEM_OX = 120
        local ITEM_OY = 5
        local ITEM_XSEP = 26

        local itemX = sidebarX + ITEM_OX * s
        local itemY = sidebarY + ITEM_OY * s

        local function addItemSprite (img)
            local sprite = addSprite{img, x=itemX, y=itemY, xalign='center'}
            local x = itemX
            itemX = itemX + sprite:getWidth() + ITEM_XSEP
            return x
        end

        local RES_X = addItemSprite(self.images.card.res.back)
        local DEV_X = addItemSprite(self.images.card.dev.back)
        local KNIGHT_X = addItemSprite(self.images.card.dev.knight)
        local ROAD_X = addItemSprite(self.images.card.dev.road)

        local PLAYERS_OX = 57
        local PLAYERS_OY = 48

        local playerX = sidebarX + PLAYERS_OX * s
        local playerY = sidebarY + PLAYERS_OY * s

        local scoreX = playerX + 37

        local boxImg = self.images.playerbox

        local TEXT_OY = boxImg:getHeight() / 2

        local BLACK = {0, 0, 0}
        local WHITE = {1, 1, 1}

        local function addCenteredTextSprite (textstring, x, color)
            local text = love.graphics.newText(self.font, {color, textstring})
            local y = playerY + TEXT_OY
            addSprite{text, x=x, y=y, center=true}
        end

        for i, player in ipairs(self.game.players) do
            if player == self.game.player then
                addSprite{boxImg, x=playerX, y=playerY}
            end

            local circleImg = assert(self.images.circle[player], "missing circle sprite")
            local sprite = addSprite{circleImg, x=playerX, y=playerY}

            local scoreColor = (player == "white") and BLACK or WHITE

            addCenteredTextSprite(self.game:getNumberOfVictoryPoints(player), scoreX, scoreColor)
            addCenteredTextSprite(self.game:getNumberOfResourceCards(player), RES_X, BLACK)
            addCenteredTextSprite(self.game:getNumberOfDevelopmentCards(player), DEV_X, BLACK)
            addCenteredTextSprite(self.game:getArmySize(player), KNIGHT_X, BLACK)
            addCenteredTextSprite("?", ROAD_X, BLACK)

            playerY = playerY + sprite:getHeight()
        end
    end

    return layer
end

function catan:update (dt)
    for layername in pairs(self.layersPendingUpdate) do
        local layer = self.renderers[layername](self)
        assert(layer, string.format('could not render layer "%s"', layername))
        self.layers[layername] = layer
        self.layersPendingUpdate[layername] = nil
    end

    if self.validationPending then
        self.game:validate()
        self.validationPending = false
    end

    -- TODO: update animations using `dt`
end

return catan
