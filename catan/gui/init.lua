---
-- Graphical User Interface for the Catan game logic back-end.
-- Defines callbacks for LÖVE
--
-- @module catan.gui

require "util.safe"

local platform = require "util.platform"
local TableUtils = require "util.table"

local CatanSchema = require "catan.logic.schema"
local Game = require "catan.logic.game"
local FaceMap = require "catan.logic.FaceMap"
local VertexMap = require "catan.logic.VertexMap"
local EdgeMap = require "catan.logic.EdgeMap"
local Grid = require "catan.logic.grid"

local Sprite = require "catan.gui.Sprite"
local Layer = require "catan.gui.Layer"
local Box = require "catan.gui.Box"

local gui = {}

-- Enable debug commands

gui.debug = os.getenv"DEBUG"

-- GUI constants

gui.SEA_W = 900
gui.SEA_H = 700
gui.BG_MARGIN = 10

gui.LAYER_NAMES = {
    "board",
    "table",
    "inventory",
    "buttons",
}

function gui:ccwdeg2cwrad (a)
    return - math.pi * a / 180.
end

function gui:loadImgDir (dir)
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

function gui:updateDisplayedInventory ()
    local displayedInventory
    if self.game:canDiscard() then
        for _, player in ipairs(self.game.players) do
            if self.game:canDiscard(player) then
                displayedInventory = {
                    player = player,
                    reason = "discarding",
                }
                break -- choose first player that can discard
            end
        end
        assert(displayedInventory ~= nil)
    else
        displayedInventory = {
            player = self.game.player,
            reason = "playing",
        }
    end
    self.displayedInventory = displayedInventory
end

function gui:clearActions ()
    self.actions = {}
    self:afterMove()
end

function gui:clearCardSelection ()
    self.selectedResCards = {}
end

function gui:requestLayerUpdate (layername)
    self.layersPendingUpdate[layername] = true
end

function gui:requestAllLayersUpdate ()
    for i, layername in ipairs(self.LAYER_NAMES) do
        self:requestLayerUpdate(layername)
    end
end

function gui:requestClickableSpriteCacheUpdate ()
    self.clickableSpritesPendingUpdate = true
end

function gui:requestValidation ()
    self.validationPending = true
end

---
-- Callback triggered once at the beginning of the game.
-- @see love2d@love.load
function gui:load ()
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

    self.clickableSprites = {}

    self.actions = {}

    self:afterMove()
end

function gui:iterSprites (f)
    for i, layername in ipairs(self.LAYER_NAMES) do
        local layer = self.layers[layername]
        if layer then
            local ret = layer:iterSprites(f)
            if ret then return ret end
        end
    end
end

---
-- Callback used to draw on the screen every frame.
-- @see love2d@love.draw
function gui:draw ()
    self:iterSprites(function (sprite) sprite:draw() end)
end

function gui:onleftclick (x, y)
    self:iterClickableSprites(function (sprite)
        return sprite:leftclick(x, y)
    end)
end

function gui:onrightclick (x, y)
    self:iterClickableSprites(function (sprite)
        return sprite:rightclick(x, y)
    end)
end

---
-- Callback triggered when a mouse button is pressed.
-- @tparam number x Mouse x position, in pixels
-- @tparam number y Mouse y position, in pixels
-- @tparam number button The button index that was pressed.
-- 1 is the primary mouse button,
-- 2 is the secondary mouse button and
-- 3 is the middle button.
-- Further buttons are mouse dependent.
-- @see love2d@love.mousepressed
function gui:mousepressed (x, y, button)
    if button == 1 then
        self:onleftclick(x, y)
    elseif button == 2 then
        self:onrightclick(x, y)
    end
end

function gui:generateClickableSpritesArray ()
    local cache = {}

    self:iterSprites(function (sprite)
        if sprite:hasCallback() then
            table.insert(cache, sprite)
        end
    end)

    return cache
end

function gui:iterClickableSprites (f)
    for _, sprite in TableUtils:ipairsReversed(self.clickableSprites) do
        local ret = f(sprite)
        if ret then return ret end
    end
end

---
-- Callback triggered when the mouse is moved.
-- @tparam number x Mouse x position, in pixels
-- @tparam number y Mouse y position, in pixels
-- @see love2d@love.mousemoved
function gui:mousemoved (x, y)
    local found = self:iterClickableSprites(function(sprite)
        return sprite:contains(x, y)
    end)

    local ctype = found and "hand" or "arrow"

    if ctype ~= self.ctype then
        local cursor = love.mouse.getSystemCursor(ctype)
        love.mouse.setCursor(cursor)
        self.ctype = ctype
    end
end

function gui:getHexSize ()
    return self.SEA_H / 11
end

function gui:getFaceCenter (q, r)
    local x0 = self.SEA_W / 2
    local y0 = self.SEA_H / 2
    local hexsize = self:getHexSize()
    local sqrt3 = math.sqrt(3)
    local x = x0 + hexsize * (sqrt3 * q + sqrt3 / 2 * r)
    local y = y0 + hexsize * (3. / 2 * r)
    return x, y
end

function gui:getVertexPos (q, r, v)
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

function gui:getEdgeCenter (q, r, e)
    local endpoints = Grid:endpoints(q, r, e)
    assert(#endpoints == 2)
    local x1, y1 = self:getVertexPos(Grid:unpack(endpoints[1]))
    local x2, y2 = self:getVertexPos(Grid:unpack(endpoints[2]))
    return (x1 + x2) / 2, (y1 + y2) / 2
end


-- Returns angles for north-vertex and south-vertex in CCW degrees
function gui:harborAnglesFromOrientation (o)
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

function gui:getJoinedFaceWithHex (edge)
    for i, joinedFace in ipairs(Grid:joins(Grid:unpack(edge))) do
        if self.game.hexmap:get(joinedFace) then
            return joinedFace
        end
    end
end

function gui:getJoinedFaceWithoutHex (edge)
    for i, joinedFace in ipairs(Grid:joins(Grid:unpack(edge))) do
        if not self.game.hexmap:get(joinedFace) then
            return joinedFace
        end
    end
end

function gui:getHarborAngles (vertex1, vertex2)
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
    r1 = self:ccwdeg2cwrad(r1)
    r2 = self:ccwdeg2cwrad(r2)

    return r1, r2, edge
end

function gui:getShipImageFromHarbor (harbor)
    if harbor == 'generic' then
        return self.images.harbor.ship3to1
    else
        return self.images.harbor.ship2to1
    end
end

function gui:getHexCorners ()
    local corners = VertexMap:new()

    self.game.hexmap:iter(function (q, r)
        for i, vertex in ipairs(Grid:corners(q, r)) do
            corners:set(vertex, true)
        end
    end)

    return corners
end

function gui:getHexBorders ()
    local borders = EdgeMap:new()

    self.game.hexmap:iter(function (q, r)
        for i, edge in ipairs(Grid:borders(q, r)) do
            borders:set(edge, true)
        end
    end)

    return borders
end

function gui:getRoadAngleForEdge (e)
    local r
    if e == 'NE' then
        r = 150
    elseif e == 'NW' then
        r = 210
    else
        assert(e == 'W')
        r = 270
    end
    return self:ccwdeg2cwrad(r)
end

function gui:afterMove ()
    self:clearCardSelection()
    self:updateDisplayedInventory()
    self:requestAllLayersUpdate()
    self:requestClickableSpriteCacheUpdate()
    self:requestValidation()
end

function gui:printProduction (production)
    production:iter(function (player, res, n)
        print(('Player %s won %d %s %s.'):format(player, n, res,
                                                 n == 1 and "card" or "cards"))
    end)
end

function gui:printRobbery (victim, res)
    print(('Player %s robbed a %s card from Player %s'):format(self.game.player, res, victim))
end

function gui:placeInitialSettlement (vertex)
    local production = self.game:placeInitialSettlement(vertex)

    self:printProduction(production)

    self:afterMove()
end

function gui:placeInitialRoad (edge)
    self.game:placeInitialRoad(edge)
    self:afterMove()
end

gui.DEVCARD_NAMES = {
    knight = "Knight",
    roadbuilding = "Road Building",
    yearofplenty = "Year Of Plenty",
    monopoly = "Monopoly",
    victorypoint = "Victory Point",
}

function gui:buyDevelopmentCard ()
    local kind = self.game:buyDevelopmentCard()

    local name = assert(self.DEVCARD_NAMES[kind], "unknown development card")

    print(('Player %s bought a %s card'):format(self.game.player, name))

    self:afterMove()
end

function gui:roll ()
    local dice = {}
    local N = 2 -- number of dice
    for i = 1, N do
        dice[i] = math.random(1, 6)
    end

    local production = self.game:roll(dice)

    self:printProduction(production)

    self:afterMove()
end

function gui:endTurn ()
    self.game:endTurn()

    self:afterMove()
end

function gui:moveRobber (face)
    local victim, res = self.game:moveRobber(face)

    if victim and res then
        self:printRobbery(victim, res)
    end

    self:afterMove()
end

function gui:chooseVictim (victim)
    local res = self.game:chooseVictim(victim)

    self:printRobbery(victim, res)

    self:afterMove()
end

function gui:discard (player, rescards)
    self.game:discard(player, rescards)

    self:afterMove()
end

function gui:startBuildingRoadAction ()
    self.actions.edge = {
        filter = function (edge)
            return self.game:canBuildRoad(edge)
        end,
        onleftclick = function (edge)
            self:buildRoad(edge)
        end,
    }

    self:afterMove()
end

function gui:buildRoad (edge)
    self.game:buildRoad(edge)

    self.actions.edge = nil

    self:afterMove()
end

function gui:startBuildingSettlementAction ()
    self.actions.vertex = {
        filter = function (vertex)
            return self.game:canBuildSettlement(vertex)
        end,
        onleftclick = function (vertex)
            self:buildSettlement(vertex)
        end,
    }

    self:afterMove()
end

function gui:buildSettlement (vertex)
    self.game:buildSettlement(vertex)

    self.actions.vertex = nil

    self:afterMove()
end

function gui:startBuildingCityAction ()
    self.actions.vertex = {
        filter = function (vertex)
            return self.game:canBuildCity(vertex)
        end,
        onleftclick = function (vertex)
            self:buildCity(vertex)
        end,
    }

    self:afterMove()
end

function gui:buildCity (vertex)
    self.game:buildCity(vertex)

    self.actions.vertex = nil

    self:afterMove()
end

gui.renderers = {}

function gui.renderers:board ()
    local layer = Layer:new()

    local W, H = love.window.getMode()
    local hexsize = self:getHexSize()

    -- Harbors
    do
        local boardImg = self.images.harbor.board
        local oy = boardImg:getHeight() / 2
        local RES_SIZE = 25 -- size of resource
        local RES_OX = 30 -- x-offset of resource
        local RES_OY = 15 -- y-offset of resource

        local visited = VertexMap:new()

        self.game.harbormap:iter(function (q1, r1, v1, harbor)
            local vertex1 = Grid:vertex(q1, r1, v1)
            visited:set(vertex1, true)
            local adjvertices = Grid:adjacentVertices(q1, r1, v1)
            for _, vertex2 in ipairs(adjvertices) do
                if visited:get(vertex2) then
                    local x1, y1 = self:getVertexPos(q1, r1, v1)
                    local x2, y2 = self:getVertexPos(Grid:unpack(vertex2))
                    local a1, a2, edge = self:getHarborAngles(vertex1, vertex2)
                    layer:addSprite(boardImg, {x=x1, y=y1, r=a1, oy=oy})
                    layer:addSprite(boardImg, {x=x2, y=y2, r=a2, oy=oy})

                    local seaFace = self:getJoinedFaceWithoutHex(edge)
                    local x3, y3 = self:getFaceCenter(Grid:unpack(seaFace))
                    local shipImg = self:getShipImageFromHarbor(harbor)
                    local shipSprite = layer:addSprite(shipImg, {x=x3, y=y3, center=true})
                    local shipX, shipY = shipSprite:getCoords()
                    local resImg = self.images.resource[harbor]
                    if resImg ~= nil then
                        local s = RES_SIZE / resImg:getHeight()
                        local x4 = shipX + RES_OX
                        local y4 = shipY + RES_OY
                        layer:addSprite(resImg, {x=x4, y=y4, sx=s})
                    end
                end
            end
        end)
    end

    -- Hexes
    self.game.hexmap:iter(function (q, r, hex)
        local img = assert(self.images.hex[hex], "missing hex sprite")
        local x, y = self:getFaceCenter(q, r)
        local s = hexsize / (img:getHeight() / 2)
        layer:addSprite(img, {x=x, y=y, sx=s, center=true})
    end)

    -- Face action
    do
        local faceAction = self.actions.face

        if faceAction == nil then
            if self.game:canMoveRobber() then
                faceAction = {
                    filter = function (face)
                        return self.game:canMoveRobber(face)
                    end,
                    onleftclick = function (face)
                        self:moveRobber(face)
                    end,
                }
            end
        end

        if faceAction ~= nil then
            local img = self.images.selection
            self.game.hexmap:iter(function (q, r)
                local face = Grid:face(q, r)
                if faceAction.filter(face) then
                    local x, y = self:getFaceCenter(q, r)
                    layer:addSprite(img, {
                        x = x,
                        y = y,
                        center = true,
                        onleftclick = function ()
                            faceAction.onleftclick(face)
                        end,
                    })
                end
            end)
        end
    end

    -- Vertex action
    do
        local vertexAction = self.actions.vertex

        if vertexAction == nil then
            if self.game:canPlaceInitialSettlement() then
                vertexAction = {
                    filter = function (vertex)
                        return self.game:canPlaceInitialSettlement(vertex)
                    end,
                    onleftclick = function (vertex)
                        self:placeInitialSettlement(vertex)
                    end,
                }
            end
        end

        if vertexAction ~= nil then
            local hexCorners = self:getHexCorners()
            local img = self.images.selection
            hexCorners:iter(function (q, r, v)
                local vertex = Grid:vertex(q, r, v)
                if vertexAction.filter(vertex) then
                    local x, y = self:getVertexPos(q, r, v)
                    layer:addSprite(img, {
                        x = x,
                        y = y,
                        sx = 0.5,
                        center = true,
                        onleftclick = function ()
                            vertexAction.onleftclick(vertex)
                        end,
                    })
                end
            end)
        end
    end

    -- Edge action
    do
        local edgeAction = self.actions.edge

        if edgeAction == nil then
            if self.game:canPlaceInitialRoad() then
                edgeAction = {
                    filter = function (edge)
                        return self.game:canPlaceInitialRoad(edge)
                    end,
                    onleftclick = function (edge)
                        self:placeInitialRoad(edge)
                    end,
                }
            end
        end

        if edgeAction ~= nil then
            local hexBorders = self:getHexBorders()
            local img = self.images.selection
            hexBorders:iter(function (q, r, e)
                local edge = Grid:edge(q, r, e)
                if edgeAction.filter(edge) then
                    local x, y = self:getEdgeCenter(q, r, e)
                    layer:addSprite(img, {
                        x = x,
                        y = y,
                        sx = 0.5,
                        center = true,
                        onleftclick = function ()
                            edgeAction.onleftclick(edge)
                        end
                    })
                end
            end)
        end
    end

    -- Number tokens
    self.game.numbermap:iter(function (q, r, number)
        local img = assert(self.images.number[tostring(number)], "missing token sprite")
        local x, y = self:getFaceCenter(q, r)
        local s = (0.6 * hexsize) / img:getHeight()
        layer:addSprite(img, {x=x, y=y, sx=s, center=true})
    end)

    -- Roads
    do
        self.game.roadmap:iter(function (q, r, e, player)
            local x, y = self:getEdgeCenter(q, r, e)
            local r = self:getRoadAngleForEdge(e)
            local img = assert(self.images.road[player], "missing road image")
            layer:addSprite(img, {x=x, y=y, r=r, sx=0.25, center=true})
        end)
    end

    -- Buildings
    do
        self.game.buildmap:iter(function (q, r, v, building)
            local x, y = self:getVertexPos(q, r, v)
            local onleftclick
            local player = building.player
            if self.game:canChooseVictim(player) then
                onleftclick = function ()
                    self:chooseVictim(player)
                end
            end
            if building.kind == "settlement" then
                local img = assert(self.images.settlement[building.player], "missing settlement image")
                layer:addSprite(img, {x=x, y=y, sx=0.5, center=true, onleftclick=onleftclick})
            else
                assert(building.kind == "city")
                local img = assert(self.images.city[building.player], "missing city image")
                layer:addSprite(img, {x=x, y=y, sx=0.4, center=true, onleftclick=onleftclick})
            end
        end)
    end

    -- Robber
    do
        local img = self.images.robber
        local x, y = self:getFaceCenter(Grid:unpack(self.game.robber))
        local s = (0.8 * hexsize) / img:getHeight()
        layer:addSprite(img, {x=x, y=y, sx=s, center=true})
    end

    return layer
end

function gui:newText (color, text)
    return love.graphics.newText(self.font, {color, text})
end

gui.ARROW_COLOR_FOR_REASON = {
    playing = "yellow",
    discarding = "red",
}

function gui:renderTable (layer, x, y)
    local TABLE_XSEP = 20
    local TABLE_YSEP = 10
    local BLACK = {0, 0, 0}
    local RED = {0.8, 0, 0}

    local function redIff (cond)
        return cond and RED or BLACK
    end

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

    local W = self.images.card.res.back:getWidth()

    local function scaleToWidth (img)
        return {
            img,
            sx = W / img:getWidth(),
        }
    end

    table.insert(t, {
        nil,
        nil,
        self.images.card.res.back,
        self.images.card.dev.back,
        scaleToWidth(self.images.knight),
        scaleToWidth(self.images.roads),
        scaleToWidth(self.images.vp),
    })

    for _, player in ipairs(self.game.players) do
        local numResCards = self.game:getNumberOfResourceCards(player)
        local isNumResCardsAboveLimit = self.game:isNumberOfResourceCardsAboveLimit(numResCards)
        local hasLargestArmy = self.game.largestarmy == player
        local hasLongestRoad = self.game.longestroad == player
        local arrow

        if player == self.displayedInventory.player then
            local arrowColor = self.ARROW_COLOR_FOR_REASON[self.displayedInventory.reason]
            local arrowImg = assert(self.images.arrow[arrowColor], "arrow sprite missing")
            arrow = {arrowImg, sx=0.3}
        end

        table.insert(t, {
            arrow,
            {
                self.images.settlement[player],
                sx = 0.5,
            },
            self:newText(redIff(isNumResCardsAboveLimit), numResCards),
            self:newText(BLACK, self.game:getNumberOfDevelopmentCards(player)),
            self:newText(redIff(hasLargestArmy), self.game:getArmySize(player)),
            self:newText(redIff(hasLongestRoad), self.game:getLongestRoadLength(player)),
            self:newText(BLACK, self.game:getNumberOfVictoryPoints(player)),
        })

        -- increment the number of lines
        t.n = t.n + 1
    end

    return layer:addSpriteTable(t)
end

function gui:renderDice (layer, x, y)
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

function gui.renderers:table ()
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

function gui:addToSelectedCardCount (res, n)
    local player = self.displayedInventory.player
    local count = self.game:getNumberOfResourceCardsOfType(player, res)
    local selectedCount = (self.selectedResCards[res] or 0)
    local newSelectedCount = selectedCount + n
    if newSelectedCount >= 0 and newSelectedCount <= count then
        self.selectedResCards[res] = newSelectedCount
        self:requestLayerUpdate"inventory"
        self:requestClickableSpriteCacheUpdate()
    end
end

function gui:selectResCard (res)
    self:addToSelectedCardCount(res, 1)
end

function gui:unselectResCard (res)
    self:addToSelectedCardCount(res, -1)
end

function gui:getNumberOfSelectedResCards ()
    local n = 0
    for res, count in pairs(self.selectedResCards) do
        n = n + count
    end
    return n
end

function gui.renderers:inventory ()
    local layer = Layer:new()

    local W, H = love.window.getMode()

    -- Margin between box and edge of window
    local XMARGIN = 20
    local YMARGIN = XMARGIN

    -- Separation between card sequences
    local XSEP = 10

    -- Separation between card groups
    local YSEP = 10

    -- Card height
    local CARD_H
    do
        local cardImg = self.images.card.dev.knight
        CARD_H = cardImg:getHeight()
    end

    do
        local CARD_COUNT_SX = 0.5
        local BLACK = {0, 0, 0}
        local RED = {0.8, 0, 0}
        local GREEN = {0, 0.5, 0}

        -- Bounding box
        local box

        local function addToBox (anotherBox)
            if box == nil then
                box = anotherBox
            else
                box = Box:fromUnion(box, anotherBox)
            end
        end

        local function addCardSequence (x, y, img, count, onleftclick)
            if count == 0 then
                return -- don't render anything
            else
                assert(count > 0)
            end

            local imgW = img:getWidth()

            local t = {
                m = count,
                x = x,
                y = y,
                xsep = -imgW * 3 / 4,
                yalign = 'bottom',
            }

            local line = {}
            for i = 1, count do
                table.insert(line, {
                    img,
                    onleftclick = onleftclick,
                })
            end
            table.insert(t, line)

            local tableBox = layer:addSpriteTable(t)

            local tableRightX = tableBox:getRightX()
            local tableTopY = tableBox:getTopY()

            local cardCountCircleSprite = layer:addSprite(
                self.images.cardcount,
                {
                    x = tableRightX,
                    y = tableTopY,
                    center = true,
                    sx = CARD_COUNT_SX,
                }
            )

            local cardCountTextSprite = layer:addSprite(
                self:newText(BLACK, count),
                {
                    x = tableRightX,
                    y = tableTopY,
                    center = true,
                }
            )

            local sequenceBox = Box:fromUnion(
                tableBox,
                Box:fromSprite(cardCountCircleSprite),
                Box:fromSprite(cardCountTextSprite)
            )

            addToBox(sequenceBox)

            return sequenceBox
        end

        local x0 = XMARGIN
        local y0 = H - YMARGIN

        local x = x0
        local y = y0

        local player = self.displayedInventory.player
        local reason = self.displayedInventory.reason

        local rescards = self.game.rescards[player]
        local hasCardInInventory = false

        for _, res in ipairs(TableUtils:sortedKeys(rescards)) do
            local img = assert(self.images.card.res[res], "missing rescard sprite")
            local totalCount = assert(rescards[res])
            local sequenceBox

            if reason == "playing" then
                sequenceBox = addCardSequence(x, y, img, totalCount)
            else
                assert(reason == "discarding")
                local selectedCount = self.selectedResCards[res] or 0
                local count = totalCount - selectedCount
                assert(count >= 0)
                sequenceBox = addCardSequence(x, y, img, count, function ()
                    self:selectResCard(res)
                end)
            end

            if sequenceBox then
                x = sequenceBox:getRightX() + XSEP
                hasCardInInventory = true
            end
        end

        local devcards = self.game.devcards[player]

        local devcardhist = {}
        for _, devcard in ipairs(devcards) do
            if devcard.roundPlayed == nil then
                local kind = devcard.kind
                devcardhist[kind] = (devcardhist[kind] or 0) + 1
            end
        end

        for devcard, count in pairs(devcardhist) do
            local img = assert(self.images.card.dev[devcard], "missing devcard sprite")
            local sequenceBox = addCardSequence(x, y, img, count)

            if sequenceBox then
                x = sequenceBox:getRightX() + XSEP
                hasCardInInventory = true
            end
        end

        local y0 = y0 - CARD_H - YMARGIN

        -- Inventory text
        if hasCardInInventory then
            local textSprite = layer:addSprite(
                self:newText(BLACK, "Inventory"),
                {
                    x = x0,
                    y = y0,
                    yalign = "bottom",
                }
            )

            local textBox = Box:fromSprite(textSprite)

            addToBox(textBox)

            y0 = textBox:getTopY() - YMARGIN
        end

        local x = x0
        local y = y0

        for _, res in ipairs(TableUtils:sortedKeys(self.selectedResCards)) do
            local img = assert(self.images.card.res[res], "missing rescard sprite")
            local count = assert(self.selectedResCards[res])
            local sequenceBox = addCardSequence(x, y, img, count, function ()
                self:unselectResCard(res)
            end)

            if sequenceBox then
                x = sequenceBox:getRightX() + XSEP
            end
        end

        local y0 = y0 - CARD_H - YMARGIN

        -- Selection text
        local numSelectedCards = self:getNumberOfSelectedResCards()

        if reason == "discarding" then
            local rescards = self.selectedResCards
            local playerCanDiscard = self.game:canDiscard(player, rescards)

            local expectedNumOfCards = self.game:getNumberOfResourceCardsToDiscard(player)
            local text = ('To be discarded (%d/%d)'):format(numSelectedCards, expectedNumOfCards)
            local color = playerCanDiscard and GREEN or RED

            local textSprite = layer:addSprite(
                self:newText(color, text),
                {
                    x = x0,
                    y = y0,
                    yalign = "bottom",
                }
            )

            local textBox = Box:fromSprite(textSprite)

            addToBox(textBox)

            if playerCanDiscard then
                local okImg = self.images.btn.ok

                local okSprite = layer:addSprite(
                    okImg,
                    {
                        x = textBox:getRightX() + XSEP,
                        y = y0,
                        yalign = "bottom",
                        sx = textBox:getHeight() / okImg:getHeight(),
                        onleftclick = function ()
                            self:discard(player, rescards)
                        end,
                    }
                )

                local okBox = Box:fromSprite(okSprite)

                addToBox(okBox)
            end

            y0 = box:getTopY() - YMARGIN
        end

        if box then
            local grownBox = box:grow(2 * self.BG_MARGIN)
            local sprite = Sprite:new(self.images.smoke, {
                x = grownBox.x,
                y = grownBox.y,
                sx = grownBox.w,
                sy = grownBox.h,
            })
            table.insert(layer, 1, sprite)
        end
    end

    return layer
end

function gui.renderers:buttons ()
    local layer = Layer:new()

    local W, H = love.window.getMode()
    local XMARGIN = 20
    local YMARGIN = XMARGIN
    local XSEP = 10
    local NBUTTONS = 1

    local noAction = next(self.actions) == nil

    -- Choose button image depending on condition
    -- If condition is true, chooses the "active" variant
    -- Otherwise, chooses the "inactive" one
    -- Also, asserts such image exists
    local function chooseButtonImg (btnfolder, cond)
        return assert(btnfolder[cond and "active" or "inactive"], "missing button sprite")
    end

    -- Create a new cell
    -- t : {
    --   folder : table,
    --   check : function,
    --   action : function,
    -- }
    local function newCell (t)
        local active = t.check() and noAction

        local cell = {
            chooseButtonImg(t.folder, active),
            onleftclick = function ()
                if noAction then
                    local ok, err = t.check()
                    if ok then
                        t.action()
                    else
                        print('Error: ' .. err)
                    end
                else
                    print('Error: ongoing action')
                end
            end,
        }

        return cell
    end

    do
        local line = {
            newCell{
                folder = self.images.btn.road,
                check = function ()
                    return self.game:canBuildRoad()
                end,
                action = function ()
                    self:startBuildingRoadAction()
                end,
            },
            newCell{
                folder = self.images.btn.settlement,
                check = function ()
                    return self.game:canBuildSettlement()
                end,
                action = function ()
                    self:startBuildingSettlementAction()
                end,
            },
            newCell{
                folder = self.images.btn.city,
                check = function ()
                    return self.game:canBuildCity()
                end,
                action = function ()
                    self:startBuildingCityAction()
                end,
            },
            newCell{
                folder = self.images.btn.devcard,
                check = function ()
                    return self.game:canBuyDevelopmentCard()
                end,
                action = function ()
                    self:buyDevelopmentCard()
                end,
            },
            newCell{
                folder = self.images.btn.roll,
                check = function ()
                    return self.game:canRoll()
                end,
                action = function ()
                    self:roll()
                end,
            },
            newCell{
                folder = self.images.btn.endturn,
                check = function ()
                    return self.game:canEndTurn()
                end,
                action = function ()
                    self:endTurn()
                end,
            },
        }

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

---
-- Callback used to update the state of the game every frame.
-- @tparam number dt Time since the last update in seconds.
-- @see love2d@love.update
function gui:update (dt)
    for layername in pairs(self.layersPendingUpdate) do
        local layer = self.renderers[layername](self)
        assert(layer, ('could not render layer "%s"'):format(layername))
        self.layers[layername] = layer
        self.layersPendingUpdate[layername] = nil
    end

    if self.clickableSpritesPendingUpdate then
        self.clickableSprites = self:generateClickableSpritesArray()
        self.clickableSpritesPendingUpdate = false
    end

    if self.validationPending then
        self.game:validate()
        self.validationPending = false
    end

    -- TODO: update animations using `dt`
end

gui.DEAL_COMMANDS = {
    b = 'brick',
    l = 'lumber',
    o = 'ore',
    g = 'grain',
    w = 'wool',
}

---
-- Callback triggered when a key is pressed.
-- @tparam string key Character of the pressed key.
-- @see love2d@love.keypressed
function gui:keypressed (key)
    if key == "escape" then
        self:clearActions()
    end

    if self.debug then
        local rescard = self.DEAL_COMMANDS[key]
        if rescard ~= nil then
            if self.game.phase == "playingTurns" then
                local rescards = self.game.rescards[self.game.player]
                rescards[rescard] = (rescards[rescard] or 0) + 1
                print("Gave 1 " .. rescard .. " to player " .. self.game.player)
                self:afterMove()
            else
                print("Cannot deal cards in this phase")
            end
        end
    end
end

return gui
