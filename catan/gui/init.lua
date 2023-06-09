---
-- Graphical User Interface for the Catan game logic back-end.
-- Defines callbacks for LÖVE
--
-- @module catan.gui

require "util.safe"

local platform = require "util.platform"
local TableUtils = require "util.table"

local CatanSchema = require "catan.logic.schema"
local CatanConstants = require "catan.logic.constants"
local Game = require "catan.logic.Game"
local FaceMap = require "catan.logic.FaceMap"
local VertexMap = require "catan.logic.VertexMap"
local EdgeMap = require "catan.logic.EdgeMap"
local Grid = require "catan.logic.grid"

local Sprite = require "catan.gui.Sprite"
local Layer = require "catan.gui.Layer"
local Box = require "catan.gui.Box"

local gui = {}

-- I/O constants

gui.STATE_FILE = "state.lua"

-- Enable debug commands

gui.debug = os.getenv"DEBUG"

-- GUI constants

gui.LBAR_W = 100

gui.SEA_W = 900
gui.SEA_H = 700
gui.BG_MARGIN = 10

gui.RANK_W = 500

gui.LAYER_NAMES = {
    "board",
    "table",
    "inventory",
    "buttons",
}

gui.BLACK = {0, 0, 0}
gui.WHITE = {1, 1, 1}
gui.RED = {0.8, 0, 0}
gui.GREEN = {0, 0.5, 0}

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

function gui:getDiscardSelectionText ()
    local player = self.displayedInventory.player
    local rescards = self.myCards
    local playerCanDiscard = self.game:canDiscard(player, rescards)

    local numSelectedCards = TableUtils:sum(self.myCards)
    local expectedNumOfCards = self.game:getNumberOfResourceCardsToDiscard(player)

    local text = ('To be discarded (%d/%d)'):format(numSelectedCards, expectedNumOfCards)
    local color = playerCanDiscard and self.GREEN or self.RED

    return {
        text = text,
        color = color,
        showbtn = playerCanDiscard,
        onleftclick = function ()
            self:discard(player, rescards)
        end,
    }
end

function gui:getNextPlayerToReply ()
    for _, player in ipairs(self.game.players) do
        if player ~= self.game.player and self.tradeReplies[player] == nil then
            if self:canTradeWithPlayer(player) then
                return player
            end
        end
    end
end

function gui:getDisplayedInventory ()
    if self.game:canDiscard() then
        for _, player in ipairs(self.game.players) do
            if self.game:canDiscard(player) then
                return {
                    player = player,
                    canSelectMyCards = true,
                    canPlayCards = false,
                    tableArrowColor = "red",
                    createSelectionText = function ()
                        return self:getDiscardSelectionText()
                    end,
                }
            end
        end
    end
    if self.tradeStatus == "replying" then
        local player = self:getNextPlayerToReply()
        if player == nil then
            return {
                player = self.game.player,
                canSelectMyCards = false,
                canSelectTheirCards = false,
                showTheirCards = true,
                canPlayCards = false,
                tableArrowColor = "yellow",
                inventoryArrow = "right",
            }
        else
            return {
                player = player,
                canSelectMyCards = false,
                canSelectTheirCards = false,
                showTheirCards = true,
                canPlayCards = false,
                tableArrowColor = "green",
                inventoryArrow = "right",
                acceptButton = function ()
                    self:replyToTradeProposal'accepted'
                end,
                rejectButton = function ()
                    self:replyToTradeProposal'rejected'
                end,
            }
        end
    end
    if self.tradeStatus ~= nil then
        local okButton
        if self:canProposeTrade() then
            okButton = function ()
                self:proposeTrade()
            end
        end
        return {
            player = self.game.player,
            canSelectMyCards = true,
            canSelectTheirCards = true,
            showTheirCards = true,
            canPlayCards = false,
            tableArrowColor = "yellow",
            inventoryArrow = "right",
            okButton = okButton,
        }
    end
    if self.volatile.playingYearOfPlentyCard then
        local okButton
        if self:canPlayYearOfPlentyCard() then
            okButton = function ()
                self:playYearOfPlentyCard()
            end
        end
        return {
            player = self.game.player,
            canSelectMyCards = false,
            canSelectTheirCards = true,
            showTheirCards = true,
            canPlayCards = false,
            tableArrowColor = "yellow",
            inventoryArrow = "left",
            okButton = okButton,
        }
    end
    if self.volatile.playingMonopolyCard then
        local okButton
        if self:canPlayMonopolyCard() then
            okButton = function ()
                self:playMonopolyCard()
            end
        end
        return {
            player = self.game.player,
            canSelectMyCards = false,
            canSelectTheirCards = true,
            showTheirCards = true,
            canPlayCards = false,
            tableArrowColor = "yellow",
            inventoryArrow = "left",
            okButton = okButton,
        }
    end
    return {
        player = self.game.player,
        canSelectMyCards = self.game:canTrade(),
        canSelectTheirCards = false,
        showTheirCards = false,
        canPlayCards = true,
        tableArrowColor = "yellow",
    }
end

function gui:updateDisplayedInventory ()
    self.displayedInventory = assert(self:getDisplayedInventory())
end

function gui:getFaceAction ()
    if self.game:canMoveRobber() then
        return {
            filter = function (face)
                return self.game:canMoveRobber(face)
            end,
            onleftclick = function (face)
                self:moveRobber(face)
            end,
            message = 'robber movement',
        }
    end
end

function gui:getVertexAction ()
    if self.game:canPlaceInitialSettlement() then
        return {
            filter = function (vertex)
                return self.game:canPlaceInitialSettlement(vertex)
            end,
            onleftclick = function (vertex)
                self:placeInitialSettlement(vertex)
            end,
            message = 'settlement placement',
        }
    elseif self.volatile.buildingSettlement then
        return {
            filter = function (vertex)
                return self.game:canBuildSettlement(vertex)
            end,
            onleftclick = function (vertex)
                self:buildSettlement(vertex)
            end,
            message = 'settlement construction',
        }
    elseif self.volatile.buildingCity then
        return {
            filter = function (vertex)
                return self.game:canBuildCity(vertex)
            end,
            onleftclick = function (vertex)
                self:buildCity(vertex)
            end,
            message = 'settlement upgrade',
        }
    end
end

function gui:getEdgeAction ()
    if self.game:canPlaceInitialRoad() then
        return {
            filter = function (edge)
                return self.game:canPlaceInitialRoad(edge)
            end,
            onleftclick = function (edge)
                self:placeInitialRoad(edge)
            end,
            message = 'road placement',
        }
    elseif self.volatile.buildingRoad then
        return {
            filter = function (edge)
                return self.game:canBuildRoad(edge)
            end,
            onleftclick = function (edge)
                self:buildRoad(edge)
            end,
            message = 'road construction',
        }
    end
end

function gui:updateGridActions ()
    self.actions = {
        face = self:getFaceAction(),
        vertex = self:getVertexAction(),
        edge = self:getEdgeAction(),
    }
end

function gui:escape ()
    self.volatile = {}

    if self.tradeStatus == nil or self.tradeStatus == "settingUp" then
        self:refresh()
    else
        self:clearTradeReplies()
        self:startTrading()
    end
end

function gui:openStateFile (...)
    local fp, err = io.open(self.STATE_FILE, ...)

    if fp == nil then
        print('Error: ' .. err)
    end

    return fp
end

function gui:save ()
    local fp = self:openStateFile("w")

    if fp then
        fp:write(self.game:serialize())
        fp:close()
    end
end

function gui:open ()
    local fp = self:openStateFile()

    if fp then
        local str = fp:read"*a"
        fp:close()

        local g, err = Game:deserialize(str)

        if g then
            self.game = g
            self:refresh()
        else
            print('Error: ' .. err)
        end
    end
end

function gui:stopTrading ()
    self.tradeStatus = nil
end

function gui:clearTradeReplies ()
    self.tradeReplies = {}
end

function gui:clearCardSelection ()
    self.myCards = {}
    self.theirCards = {}
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
    love.window.setMode(self.LBAR_W + self.SEA_W + self.RANK_W, 1000)
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

    self.volatile = {}

    self:refresh()
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
    local x0 = self.LBAR_W + self.SEA_W / 2
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
    assert(edge ~= nil, "no edge in between")

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

function gui:refresh ()
    self:stopTrading()
    self:clearTradeReplies()
    self:clearCardSelection()
    self:updateDisplayedInventory()
    self:updateGridActions()
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
    self:refresh()
end

function gui:placeInitialRoad (edge)
    self.game:placeInitialRoad(edge)
    self:refresh()
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

    self:refresh()
end

function gui:roll ()
    local dice = {}
    local N = 2 -- number of dice
    for i = 1, N do
        dice[i] = math.random(1, 6)
    end

    local production = self.game:roll(dice)

    self:printProduction(production)

    self:refresh()
end

function gui:endTurn ()
    self.game:endTurn()

    self:refresh()
end

function gui:moveRobber (face)
    local victim, res = self.game:moveRobber(face)
    if victim and res then
        self:printRobbery(victim, res)
    end
    self:refresh()
end

function gui:chooseVictim (victim)
    local res = self.game:chooseVictim(victim)

    self:printRobbery(victim, res)

    self:refresh()
end

function gui:discard (player, rescards)
    self.game:discard(player, rescards)

    self:refresh()
end

function gui:startBuildingRoadAction ()
    self.volatile.buildingRoad = true
    self:refresh()
end

function gui:buildRoad (edge)
    self.game:buildRoad(edge)
    self.volatile.buildingRoad = nil
    self:refresh()
end

function gui:startBuildingSettlementAction ()
    self.volatile.buildingSettlement = true
    self:refresh()
end

function gui:buildSettlement (vertex)
    self.game:buildSettlement(vertex)
    self.volatile.buildingSettlement = nil
    self:refresh()
end

function gui:startBuildingCityAction ()
    self.volatile.buildingCity = true
    self:refresh()
end

function gui:buildCity (vertex)
    self.game:buildCity(vertex)
    self.volatile.buildingCity = nil
    self:refresh()
end

function gui:canTradeWithHarbor ()
    return self.game:canTradeWithHarbor(self.myCards, self.theirCards)
end

function gui:tradeWithHarbor ()
    self.game:tradeWithHarbor(self.myCards, self.theirCards)

    self:refresh()
end

function gui:canTradeWithPlayer (player)
    return self.game:canTradeWithPlayer(player, self.myCards, self.theirCards)
end

function gui:tradeWithPlayer (player)
    self.game:tradeWithPlayer(player, self.myCards, self.theirCards)

    self:refresh()
end

function gui:canPlayYearOfPlentyCard ()
    return self.game:canPlayYearOfPlentyCard(self.theirCards)
end

function gui:playYearOfPlentyCard ()
    self.game:playYearOfPlentyCard(self.theirCards)
    self.volatile.playingYearOfPlentyCard = nil
    self:refresh()
end

function gui:getSingleResFrom (rescards)
    local n = TableUtils:sum(rescards)
    if n == 1 then
        for res, n in pairs(rescards) do
            if n == 1 then
                return res
            end
        end
    end
    return nil
end

function gui:canPlayMonopolyCard ()
    local res = self:getSingleResFrom(self.theirCards)
    return res ~= nil and self.game:canPlayMonopolyCard(res)
end

function gui:playMonopolyCard ()
    local res = self:getSingleResFrom(self.theirCards)
    self.game:playMonopolyCard(res)
    self.volatile.playingMonopolyCard = nil
    self:refresh()
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
        local RES_OX = 35 -- x-offset of resource
        local RES_OY = 23 -- y-offset of resource

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
                    local shipSprite = layer:addSprite(shipImg, {x=x3, y=y3, sx=0.8, center=true})
                    local shipX, shipY = shipSprite:getCoords()
                    local resImg = self.images.resource[harbor]
                    if resImg ~= nil then
                        local s = RES_SIZE / resImg:getHeight()
                        local x4 = shipX + RES_OX
                        local y4 = shipY + RES_OY
                        layer:addSprite(resImg, {x=x4, y=y4, sx=s, center=true})
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

function gui:renderTable (layer, x, y)
    local TABLE_XSEP = 20
    local TABLE_YSEP = 10

    local function redIff (cond)
        return cond and self.RED or self.BLACK
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

    local function getIconForPlayer (player)
        if player == self.displayedInventory.player then
            local tableArrowColor = self.displayedInventory.tableArrowColor
            local arrowImg = assert(self.images.arrow[tableArrowColor], "arrow sprite missing")
            return {arrowImg, sx=0.3}
        end

        if self.tradeStatus == "replying" then
            local reply = self.tradeReplies[player]
            if reply ~= nil then
                if reply == 'accepted' then
                    return {
                        self.images.accept,
                        sx = 0.3,
                        onleftclick = function ()
                            self:tradeWithPlayer(player)
                        end,
                    }
                else
                    assert(reply == 'rejected')
                    return {
                        self.images.reject,
                        sx = 0.3,
                    }
                end
            end
        end
    end

    for _, player in ipairs(self.game.players) do
        local numResCards = self.game:getNumberOfResourceCards(player)
        local isNumResCardsAboveLimit = self.game:isNumberOfResourceCardsAboveLimit(numResCards)
        local hasLargestArmy = self.game.largestarmy == player
        local hasLongestRoad = self.game.longestroad == player
        local playerIcon = getIconForPlayer(player)

        table.insert(t, {
            playerIcon,
            {
                self.images.settlement[player],
                sx = 0.5,
            },
            self:newText(redIff(isNumResCardsAboveLimit), numResCards),
            self:newText(self.BLACK, self.game:getNumberOfDevelopmentCards(player)),
            self:newText(redIff(hasLargestArmy), self.game:getArmySize(player)),
            self:newText(redIff(hasLongestRoad), self.game:getLongestRoadLength(player)),
            self:newText(self.BLACK, self.game:getNumberOfVictoryPoints(player)),
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

function gui:getMessage ()
    for _, action in pairs(self.actions) do
        local msg = action.message
        if msg ~= nil then
            return 'Action: ' .. msg
        end
    end
    local tradeStatus = self.tradeStatus
    if tradeStatus == 'settingUp' then
        return 'Action: trading'
    end
    if self.game.winner ~= nil then
        return 'Player ' .. self.game.winner .. ' is the winner!'
    end
end

function gui:renderMessage (layer, x, y)
    local message = self:getMessage()
    if message ~= nil then
        local text = self:newText(self.WHITE, message)
        local sprite = layer:addSprite(text, {
            x = x,
            y = y,
            xalign = 'center',
        })
        return Box:fromSprite(sprite)
    end
end

function gui.renderers:table ()
    local layer = Layer:new()

    local W, H = love.window.getMode()
    local YSEP = 20

    local TABLE_X = self.LBAR_W + self.SEA_W
    local TABLE_Y = 0
    local TABLE_W = W - self.LBAR_W - self.SEA_W

    local x = TABLE_X + TABLE_W / 2
    local y = YSEP

    -- Table (public info)
    do
        local box = self:renderTable(layer, x, y)
        y = box:getBottomY() + YSEP
    end

    -- Message
    do
        local box = self:renderMessage(layer, x, y)
        if box ~= nil then
            y = box:getBottomY() + YSEP
        end
    end

    -- Dice
    if self.game.dice ~= nil then
        local box = self:renderDice(layer, x, y)
        y = box:getBottomY() + YSEP
    end

    return layer
end

function gui:softRefresh ()
    self:updateDisplayedInventory()
    self:requestAllLayersUpdate()
    self:requestClickableSpriteCacheUpdate()
end

function gui:addToCards (cards, res, n, limit)
    local player = self.displayedInventory.player
    local selectedCount = (cards[res] or 0)
    local newSelectedCount = selectedCount + n
    if newSelectedCount >= 0 and (limit == nil or newSelectedCount <= limit) then
        cards[res] = newSelectedCount
        self:softRefresh()
    end
end

function gui:playCardOfKind (kind)
    if kind == "knight" then
        self.game:playKnightCard()
    elseif kind == "roadbuilding" then
        self.game:playRoadBuildingCard()
        self.volatile.buildingRoad = true
    elseif kind == "yearofplenty" then
        self.volatile.playingYearOfPlentyCard = true
    elseif kind == "monopoly" then
        self.volatile.playingMonopolyCard = true
    end
    self:refresh()
end

function gui:getCardDimensions ()
    return self.images.card.dev.knight:getDimensions()
end

function gui:getDevCardHistogram (player)
    local t = self.game.devcards[player]
    t = TableUtils:filter(t, function (v) return v.roundPlayed == nil end)
    t = TableUtils:map(t, function (v) return v.kind end)
    return TableUtils:histogram(t)
end

function gui:getResCardImage (res)
    return assert(self.images.card.res[res], "missing resource card sprite")
end

function gui:canProposeTrade ()
    for _, player in ipairs(self.game.players) do
        if self:canTradeWithPlayer(player) then
            return true
        end
    end
    return false
end

function gui:startTradingWithPlayer ()
    self.tradeStatus = "replying"
    self:softRefresh()
end

function gui:proposeTrade ()
    if self:canTradeWithHarbor() then
        self:tradeWithHarbor()
    else
        self:startTradingWithPlayer()
    end
end

function gui:replyToTradeProposal (reply)
    self.tradeReplies[self.displayedInventory.player] = reply
    self:softRefresh()
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
    local YSEP = 50

    -- Card dimensions
    local CARD_W, CARD_H = self:getCardDimensions()

    -- Card count img scale
    local CARD_COUNT_SX = 0.6

    -- Base x and y
    local x0 = XMARGIN
    local y0 = H - YMARGIN

    local function addCardSequence (opt)
        local x = opt.x
        local y = opt.y
        local xalign = opt.xalign
        local img = opt.img
        local count = opt.count
        local onleftclick = opt.onleftclick

        assert(count >= 0)

        if count == 0 then
            return -- don't render anything
        end

        local line = {}
        for i = 1, count do
            table.insert(line, {
                img,
                onleftclick = onleftclick,
            })
        end

        local t = {
            line,
            m = count,
            x = x,
            y = y,
            xsep = - CARD_W * 3 / 4,
            xalign = xalign,
            yalign = 'bottom',
        }

        local sequenceBox = layer:addSpriteTable(t)

        local tableRightX = sequenceBox:getRightX()
        local tableTopY = sequenceBox:getTopY()

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
            self:newText(self.BLACK, count),
            {
                x = tableRightX,
                y = tableTopY,
                center = true,
            }
        )

        sequenceBox = Box:fromUnion(
            sequenceBox,
            Box:fromSprite(cardCountCircleSprite),
            Box:fromSprite(cardCountTextSprite)
        )

        return sequenceBox
    end

    local inv = self.displayedInventory

    local player = inv.player
    local canSelectMyCards = inv.canSelectMyCards
    local canSelectTheirCards = inv.canSelectTheirCards
    local showTheirCards = inv.showTheirCards
    local canPlayCards = inv.canPlayCards
    local createSelectionText = inv.createSelectionText
    local okButton = inv.okButton
    local acceptButton = inv.acceptButton
    local rejectButton = inv.rejectButton
    local inventoryArrow = inv.inventoryArrow

    -- Inventory
    do
        local x = x0
        local y = y0

        -- Resource cards
        TableUtils:sortedIter(self.game.rescards[player], function (res, totalCount)
            local img = self:getResCardImage(res)

            local count
            if canSelectMyCards then
                local selectedCount = self.myCards[res] or 0
                count = totalCount - selectedCount
            else
                count = totalCount
            end

            local onleftclick
            if canSelectMyCards then
                onleftclick = function ()
                    self:addToCards(self.myCards, res, 1, totalCount)
                end
            end

            local sequenceBox = addCardSequence{
                x = x,
                y = y,
                img = img,
                count = count,
                onleftclick = onleftclick,
            }

            if sequenceBox then
                x = sequenceBox:getRightX() + XSEP
            end
        end)

        -- Development cards
        for kind, count in pairs(self:getDevCardHistogram(player)) do
            local img = assert(self.images.card.dev[kind], "missing kind sprite")

            local onleftclick
            if canPlayCards and self.game:getPlayableCardOfKind(kind) then
                onleftclick = function ()
                    self:playCardOfKind(kind)
                end
            end

            local sequenceBox = addCardSequence{
                x = x,
                y = y,
                img = img,
                count = count,
                onleftclick = onleftclick,
            }

            if sequenceBox then
                x = sequenceBox:getRightX() + XSEP
            end
        end
    end

    -- Selected resource cards
    do
        local x = x0
        local y = y0 - CARD_H - YSEP

        TableUtils:sortedIter(self.myCards, function (res, selectedCount)
            local img = self:getResCardImage(res)

            local onleftclick
            if canSelectMyCards then
                onleftclick = function ()
                    self:addToCards(self.myCards, res, -1)
                end
            end

            local sequenceBox = addCardSequence{
                x = x,
                y = y,
                img = img,
                count = selectedCount,
                onleftclick = onleftclick,
            }

            if sequenceBox then
                x = sequenceBox:getRightX() + XSEP
            end
        end)
    end

    -- Selection text
    do
        local x = x0
        local y = y0 - 2 * CARD_H - 2 * YSEP

        if createSelectionText then
            local t = createSelectionText()

            local color = t.color or self.WHITE
            local text = assert(t.text)
            local showbtn = (t.showbtn == nil) and true or t.showbtn
            local onleftclick = t.onleftclick

            local textSprite = self:newText(color, text)
            local line = {textSprite}

            if showbtn and onleftclick then
                local okImg = self.images.btn.ok

                table.insert(line, {
                    okImg,
                    sx = textSprite:getHeight() / okImg:getHeight(),
                    onleftclick = onleftclick
                })
            end

            layer:addSpriteTable{
                line,
                m = #line,
                x = x,
                y = y,
                yalign = "bottom",
                xsep = XSEP,
                bgimg = self.images.smoke,
                bgmargin = self.BG_MARGIN,
            }
        end
    end

    if inventoryArrow ~= nil then
        local x = W / 2
        local y = y0 - (3 / 2) * CARD_H - YSEP

        local img = self.images.rightarrow

        local r
        if inventoryArrow == "left" then
            r = self:ccwdeg2cwrad(180)
        end

        local sprite = layer:addSprite(img, {
            x = x,
            y = y,
            sx = 0.3,
            r = r,
            center = true,
        })
    end

    -- Buttons over arrow
    do
        local x = W / 2
        local y = y0 - 2 * CARD_H - YSEP

        local line = {}

        if okButton then
            table.insert(line, {
                self.images.btn.ok,
                sx = 0.5,
                onleftclick = okButton,
            })
        end

        if acceptButton then
            table.insert(line, {
                self.images.accept,
                sx = 0.5,
                onleftclick = acceptButton,
            })
        end

        if rejectButton then
            table.insert(line, {
                self.images.reject,
                sx = 0.5,
                onleftclick = rejectButton,
            })
        end

        layer:addSpriteTable{
            line,
            m = #line,
            x = x,
            y = y,
            xsep = XSEP,
            xalign = 'center',
            yalign = 'bottom'
        }
    end

    if showTheirCards then

        local x0 = W - XMARGIN

        -- Buttons to add cards on the right side
        if canSelectTheirCards then

            local line = {}

            for _, res in ipairs(TableUtils:sortedKeys(self.game.bank)) do
                local img = self:getResCardImage(res)
                table.insert(line, {
                    img,
                    onleftclick = function ()
                        self:addToCards(self.theirCards, res, 1)
                    end,
                })
            end

            layer:addSpriteTable{
                line,
                m = #line,
                x = x0,
                y = y0,
                xalign = 'right',
                yalign = 'bottom',
                xsep = XSEP,
            }
        end

        -- Selected resource cards from the right side
        do
            local x = x0
            local y = y0 - CARD_H - YSEP

            for _, res in ipairs(TableUtils:reverse(TableUtils:sortedKeys(self.theirCards))) do
                local selectedCount = assert(self.theirCards[res])
                local img = self:getResCardImage(res)

                local onleftclick
                if canSelectTheirCards then
                    onleftclick = function ()
                        self:addToCards(self.theirCards, res, -1)
                    end
                end

                local sequenceBox = addCardSequence{
                    x = x,
                    y = y,
                    xalign = 'right',
                    img = img,
                    count = selectedCount,
                    onleftclick = onleftclick,
                }

                if sequenceBox then
                    x = sequenceBox:getLeftX() - XSEP
                end
            end
        end
    end

    return layer
end

function gui:startTrading ()
    self.tradeStatus = "settingUp"
    self:softRefresh()
end

function gui:canClickButtons ()
    if next(self.actions) ~= nil then
        return false, "there is an ongoing action on the grid"
    end
    if self.tradeStatus ~= nil then
        return false, "there is an ongoing trade"
    end
    return true
end

function gui.renderers:buttons ()
    local layer = Layer:new()

    local W, H = love.window.getMode()
    local XMARGIN = 20
    local YMARGIN = XMARGIN
    local XSEP = 10
    local YSEP = XSEP

    local canClick, canClickErr = self:canClickButtons()

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
        local active = canClick and t.check()

        local cell = {
            chooseButtonImg(t.folder, active),
            sx = 0.8,
            onleftclick = function ()
                if canClick then
                    local ok, checkErr = t.check()
                    if ok then
                        t.action()
                    else
                        print('Error: ' .. checkErr)
                    end
                else
                    print('Error: ' .. canClickErr)
                end
            end,
        }

        return cell
    end

    do
        local t = {
            {
                newCell{

                    folder = self.images.btn.road,
                    check = function ()
                        return self.game:canBuildRoad()
                    end,
                    action = function ()
                        self:startBuildingRoadAction()
                    end,
                },
            },
            {
                newCell{
                    folder = self.images.btn.settlement,
                    check = function ()
                        return self.game:canBuildSettlement()
                    end,
                    action = function ()
                        self:startBuildingSettlementAction()
                    end,
                },
            },
            {
                newCell{
                    folder = self.images.btn.city,
                    check = function ()
                        return self.game:canBuildCity()
                    end,
                    action = function ()
                        self:startBuildingCityAction()
                    end,
                },
            },
            {
                newCell{
                    folder = self.images.btn.trade,
                    check = function ()
                        return self.game:canTrade()
                    end,
                    action = function ()
                        self:startTrading()
                    end,
                },
            },
            {
                newCell{
                    folder = self.images.btn.devcard,
                    check = function ()
                        return self.game:canBuyDevelopmentCard()
                    end,
                    action = function ()
                        self:buyDevelopmentCard()
                    end,
                },
            },
            {
                newCell{
                    folder = self.images.btn.roll,
                    check = function ()
                        return self.game:canRoll()
                    end,
                    action = function ()
                        self:roll()
                    end,
                },
            },
            {
                newCell{
                    folder = self.images.btn.endturn,
                    check = function ()
                        return self.game:canEndTurn()
                    end,
                    action = function ()
                        self:endTurn()
                    end,
                },
            },
            x = XMARGIN,
            y = YMARGIN,
            xsep = XSEP,
            ysep = YSEP,
        }

        t.n = #t

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
    r = 'ore',
    g = 'grain',
    w = 'wool',
}

---
-- Callback triggered when a key is pressed.
-- @tparam string key Character of the pressed key.
-- @see love2d@love.keypressed
function gui:keypressed (key)
    if key == "escape" then
        self:escape()
    elseif key == "s" then
        self:save()
    elseif key == "o" then
        self:open()
    end

    if self.debug then
        local res = self.DEAL_COMMANDS[key]
        if res ~= nil then
            if self.game.phase == "playingTurns" then
                local rescards = self.game.rescards[self.game.player]
                local supply = self.game.bank[res] or 0
                if supply == 0 then
                    print("No supply of " .. res)
                else
                    assert(supply >= 1)
                    self.game.bank[res] = supply - 1
                    rescards[res] = (rescards[res] or 0) + 1
                    print("Gave 1 " .. res .. " to player " .. self.game.player)
                    self:refresh()
                end
            else
                print("Cannot deal cards in this phase")
            end
        end
    end
end

return gui
