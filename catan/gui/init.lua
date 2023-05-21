---
-- Renders a game of Catan using LÖVE2D.
--
-- @module catan.gui

local platform = require "util.platform"
local TableUtils = require "util.table"

local Game = require "catan.logic.game"
local FaceMap = require "catan.logic.facemap"
local VertexMap = require "catan.logic.vertexmap"
local EdgeMap = require "catan.logic.edgemap"
local Grid = require "catan.logic.grid"

local gutil = require "catan.gui.util"
local Sprite = require "catan.gui.sprite"
local Layer = require "catan.gui.layer"

local catan = {}

-- Environment variables

catan.DEBUG = os.getenv "DEBUG" ~= nil

-- GUI constants

catan.SEA_W = 900
catan.SEA_H = 800
catan.BG_MARGIN = 10

catan.LAYER_NAMES = {
    "board",
    "table",
    "inventory",
    "buttons",
}

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

function catan:requestClickableSpriteCacheUpdate ()
    self.clickableSprites = nil
end

function catan:requestValidation ()
    self.validationPending = true
end

function catan:load ()
    love.window.setMode(1400, 1000)
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
        local layer = self.layers[layername]
        if layer then
            local ret = layer:iterSprites(f)
            if ret then return ret end
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

function catan:mousemoved (x, y)
    local clickableSprites = self.clickableSprites

    if clickableSprites == nil then
        clickableSprites = {}
        self:iterSprites(function (sprite)
            if sprite:hasCallback() then
                table.insert(clickableSprites, sprite)
            end
        end)
        self.clickableSprites = clickableSprites
    end

    local found = false
    for _, sprite in ipairs(clickableSprites) do
        if sprite:contains(x, y) then
            found = true
            break
        end
    end

    local ctype = found and "hand" or "arrow"

    if ctype ~= self.ctype then
        local cursor = love.mouse.getSystemCursor(ctype)
        love.mouse.setCursor(cursor)
        self.ctype = ctype
    end
end

function catan:keypressed (key)
    -- TODO: process key strokes
end

function catan:getHexSize ()
    return self.SEA_H / 12
end

function catan:getFaceCenter (q, r)
    local x0 = self.SEA_W / 2
    local y0 = self.SEA_H / 2
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

function catan:afterMove ()
    self:requestAllLayersUpdate()
    self:requestClickableSpriteCacheUpdate()
    self:requestValidation()
end

function catan:printProduction (production)
    FaceMap:iter(production, function (q, r, hexProduction)
        VertexMap:iter(hexProduction, function (q, r, v, buildingProduction)
            local player = buildingProduction.player
            local numCards = buildingProduction.numCards
            local res = buildingProduction.res
            print(string.format('Player %s won %d %s %s.',
                                player, numCards, res,
                                numCards == 1 and "card" or "cards"))
        end)
    end)
end

function catan:placeInitialSettlement (q, r, v)
    local production = self.game:placeInitialSettlement(Grid:vertex(q, r, v))

    self:printProduction(production)

    self:afterMove()
end

function catan:placeInitialRoad (q, r, e)
    self.game:placeInitialRoad(Grid:edge(q, r, e))
    self:afterMove()
end

function catan:roll ()
    local dice = {}
    local N = 2 -- number of dice
    for i = 1, N do
        dice[i] = math.random(1, 6)
    end

    local production = self.game:roll(dice)

    self:printProduction(production)

    self:afterMove()
end

function catan:endTurn()
    self.game:endTurn()

    self:afterMove()
end

catan.renderers = {}

function catan.renderers:board ()
    local layer = Layer:new()

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
                    layer:addSprite{boardImg, x=x1, y=y1, r=a1, oy=oy}
                    layer:addSprite{boardImg, x=x2, y=y2, r=a2, oy=oy}

                    local seaFace = self:getJoinedFaceWithoutHex(edge)
                    local x3, y3 = self:getFaceCenter(Grid:unpack(seaFace))
                    local shipImg = self:getShipImageFromHarbor(harbor)
                    local shipSprite = layer:addSprite{shipImg, x=x3, y=y3, center=true}
                    local shipX, shipY = shipSprite:getCoords()
                    local resImg = self.images.resource[harbor]
                    if resImg ~= nil then
                        local s = RES_SIZE / resImg:getHeight()
                        local x4 = shipX + RES_OX
                        local y4 = shipY + RES_OY
                        layer:addSprite{resImg, x=x4, y=y4, sx=s}
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
        layer:addSprite{img, x=x, y=y, sx=s, center=true}
    end)

    -- Number tokens
    FaceMap:iter(self.game.numbermap, function (q, r, number)
        local img = assert(self.images.number[tostring(number)], "missing token sprite")
        local x, y = self:getFaceCenter(q, r)
        local s = (0.6 * hexsize) / img:getHeight()
        layer:addSprite{img, x=x, y=y, sx=s, center=true}
    end)

    -- Vertex selection
    if self.game.phase == "placingInitialSettlement" then
        local available = self:getAvailableVerticesForInitialSettlement()
        local img = self.images.selection
        VertexMap:iter(available, function (q, r, v)
            local x, y = self:getVertexPos(q, r, v)
            layer:addSprite{
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
            layer:addSprite{
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
            layer:addSprite{img, x=x, y=y, r=r, sx=0.25, center=true}
        end)
    end

    -- Buildings
    do
        VertexMap:iter(self.game.buildmap, function (q, r, v, building)
            local x, y = self:getVertexPos(q, r, v)
            if building.kind == "settlement" then
                local img = assert(self.images.settlement[building.player], "missing settlement image")
                layer:addSprite{img, x=x, y=y, sx=0.5, center=true}
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
        layer:addSprite{img, x=x, y=y, sx=s, center=true}
    end

    return layer
end

function catan:newText (color, text)
    return love.graphics.newText(self.font, {color, text})
end

function catan:renderTable (layer, x, y)
    local TABLE_XSEP = 20
    local TABLE_YSEP = 10
    local BLACK = {0, 0, 0}

    local t = {
        n = 1,
        m = 7,
        x = x,
        y = y,
        xalign = 'center',
        xsep = TABLE_XSEP,
        ysep = TABLE_YSEP,
        bgimg = self.images.smoke,
        bgmargin = self.BG_MARGIN,
    }

    table.insert(t, {
        nil,
        nil,
        self.images.card.res.back,
        self.images.card.dev.back,
        self.images.card.dev.knight,
        self.images.card.dev.roadbuilding,
        self.images.card.dev.victorypoint,
    })

    for _, player in ipairs(self.game.players) do
        table.insert(t, {
            (player == self.game.player) and {
                self.images.arrow,
                sx = 0.3,
            },
            {
                self.images.settlement[player],
                sx = 0.5,
            },
            self:newText(BLACK, self.game:getNumberOfResourceCards(player)),
            self:newText(BLACK, self.game:getNumberOfDevelopmentCards(player)),
            self:newText(BLACK, self.game:getArmySize(player)),
            self:newText(BLACK, "?"),
            self:newText(BLACK, self.game:getNumberOfVictoryPoints(player)),
        })

        -- increment the number of lines
        t.n = t.n + 1
    end

    return layer:addSpriteTable(t)
end

function catan:renderDice (layer, x, y)
    local DICE_XSEP = 10
    local DICE_SX = 0.5

    local line = {}

    for _, die in ipairs(self.game.dice) do
        table.insert(line, {
            assert(self.images.dice[tostring(die)], "missing die sprite"),
            sx = DICE_SX,
        })
    end

    local t = {
        line,
        m = #line,
        x = x,
        y = y,
        xalign = 'center',
        xsep = DICE_XSEP,
    }

    return layer:addSpriteTable(t)
end

function catan.renderers:table ()
    local layer = Layer:new()

    local W, H = love.window.getMode()
    local YSEP = 20

    local TABLE_X = self.SEA_W
    local TABLE_Y = 0
    local TABLE_W = W - self.SEA_W

    local BOX_MARGIN = 10

    local x = TABLE_X + TABLE_W / 2
    local y = YSEP

    -- Table (public info)
    do
        local bounds = self:renderTable(layer, x, y)
        y = bounds.y + bounds.h + YSEP
    end

    -- Dice
    if self.game.dice ~= nil then
        local bounds = self:renderDice(layer, x, y)
        y = bounds.y + bounds.h + YSEP
    end

    return layer
end

function catan.renderers:inventory ()
    local layer = Layer:new()

    local W, H = love.window.getMode()
    local XMARGIN = 20
    local YMARGIN = XMARGIN
    local XSEP = 10

    do
        local x0 = XMARGIN
        local x = x0
        local y = H - YMARGIN

        local hasCard = false
        local rightX
        local topY

        local CARD_COUNT_SX = 0.5
        local BLACK = {0, 0, 0}

        local player = self.game.player

        local function addCardSequence (img, count)
            hasCard = true

            local imgW = img:getWidth()

            local t = {
                m = count,
                x = x,
                y = y,
                xsep = -imgW * 3 / 4,
                yalign = 'bottom',
            }

            local line = {}
            for i = 1, count do table.insert(line, img) end
            table.insert(t, line)

            local bounds = layer:addSpriteTable(t)

            rightX = bounds.x + bounds.w
            topY = bounds.y

            local cardCountSprite = layer:addSprite{
                self.images.cardcount,
                x = rightX,
                y = topY,
                center = true,
                sx = CARD_COUNT_SX,
            }

            layer:addSprite{
                self:newText(BLACK, count),
                x = rightX,
                y = topY,
                center = true,
            }

            x = rightX + XSEP

            -- we need to know the right-most x and top-most y for the correct rendering
            -- of the translucent white background of the cards
            rightX = cardCountSprite:getX() + cardCountSprite:getWidth()
            topY = cardCountSprite:getY()
        end

        local rescards = self.game.rescards[player]
        for _, res in ipairs(TableUtils:sortedKeys(rescards)) do
            local img = assert(self.images.card.res[res], "missing rescard sprite")
            local count = assert(rescards[res])
            addCardSequence(img, count)
        end

        local devcards = self.game.devcards[player]
        local devcardhist = {}
        for _, devcard in ipairs(devcards) do
            if devcard.roundPlayed == nil then
                local kind = devcard.kind
                local count = devcardhist[kind] or 0
                devcardhist[kind] = count + 1
            end
        end

        for devcard, count in pairs(devcardhist) do
            local img = assert(self.images.card.dev[devcard], "missing devcard sprite")
            addCardSequence(img, count)
        end

        if hasCard then
            table.insert(layer, 1, Sprite.new{
                self.images.smoke,
                x = x0 - self.BG_MARGIN,
                y = y + self.BG_MARGIN,
                sx = rightX - x0 + 2 * self.BG_MARGIN,
                sy = y - topY + 2 * self.BG_MARGIN,
                yalign = "bottom"
            })
        end
    end

    return layer
end

function catan.renderers:buttons ()
    local layer = Layer:new()

    local W, H = love.window.getMode()
    local XMARGIN = 20
    local YMARGIN = XMARGIN
    local XSEP = 10
    local NBUTTONS = 1

    -- Choose button image depending on condition
    -- If condition is true, chooses the "active" variant
    -- Otherwise, chooses the "inactive" one
    -- Also, asserts such image exists
    local function chooseButtonImg (btnfolder, cond)
        return assert(btnfolder[cond and "active" or "inactive"], "missing button sprite")
    end

    do
        local line = {}

        do
            local canRoll = self.game:canRoll()

            local cell = {
                chooseButtonImg(self.images.btn.roll, canRoll),
            }

            if canRoll then
                function cell.onleftclick ()
                    self:roll()
                end
            end

            table.insert(line, cell)
        end

        do
            local canEndTurn = self.game:canEndTurn()

            local cell = {
                chooseButtonImg(self.images.btn.endturn, canEndTurn),
            }

            if canEndTurn then
                function cell.onleftclick ()
                    self:endTurn()
                end
            end

            table.insert(line, cell)
        end

        local t = {
            line,
            m = #line,
            x = W - XMARGIN,
            y = H - YMARGIN,
            xalign = "right",
            yalign = "bottom",
            xsep = XSEP,
        }

        layer:addSpriteTable(t)
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
