local Class = require "util.class"
local TableUtils = require "util.table"

local Constants = require "catan.logic.constants"
local Grid = require "catan.logic.grid"
local FaceMap = require "catan.logic.facemap"
local VertexMap = require "catan.logic.vertexmap"
local EdgeMap = require "catan.logic.edgemap"

--------------------------------

local Game = Class "Game"

--------------------------------
-- Constructor
--------------------------------

function Game:new (players)
    players = players or Constants.players
    local game = Game:__new{}
    game:_init(players)
    return game
end

--------------------------------
-- Initialization code
--------------------------------

function Game:_init (players)
    self.phase = 'settingUp'
    self.round = 1
    self:_setPlayers(players)
    self:_createHexMap()
    self:_createNumberMap()
    self:_createHarborMap()
    self.buildmap = {}
    self.roadmap = {}
    self:_placeRobberInDesert()
    self:_createDevelopmentCards()
    self:_createResourceCards()
    self:_createDrawPile()
    self:_createBank()
end

function Game:_setPlayers (players)
    assert(TableUtils:isArray(players), "players not array")
    assert(TableUtils:isContainedIn(players, Constants.players), "invalid players")
    assert(#players >= 3, "too few players")
    self.players = players
    self.player = players[1]
end

function Game:_createHexMap ()
    local hexes = {}
    for kind, count in pairs(Constants.terrain) do
        for i = 1, count do
            table.insert(hexes, kind)
        end
    end
    TableUtils:shuffleInPlace(hexes)
    self.hexmap = {}
    for i, hex in ipairs(hexes) do
        FaceMap:set(self.hexmap, Constants.terrainFaces[i], hex)
    end
end

function Game:_createNumberMap ()
    local i = 1
    self.numbermap = {}
    for _, face in ipairs(Constants.terrainFaces) do
        local hex = FaceMap:get(self.hexmap, face)
        if hex ~= 'desert' then
            FaceMap:set(self.numbermap, face, Constants.numbers[i])
            i = i + 1
        end
    end
end

function Game:_createHarborMap ()
    self.harbormap = {}
    for _, harbor in ipairs(Constants.harbors) do
        VertexMap:set(self.harbormap, harbor, harbor.kind)
    end
end

function Game:_placeRobberInDesert ()
    FaceMap:iter(self.hexmap, function (q, r, hex)
        if hex == 'desert' then
            self.robber = Grid:face(q, r)
            return true -- stop iteration
        end
    end)
end

function Game:_createDevelopmentCards ()
    self.devcards = {}
    for _, player in ipairs(self.players) do
        self.devcards[player] = {}
    end
end

function Game:_createResourceCards ()
    self.rescards = {}
    for _, player in ipairs(self.players) do
        self.rescards[player] = {}
    end
end

function Game:_createDrawPile ()
    self.drawpile = {}
    for kind, count in pairs(Constants.devcards) do
        for i = 1, count do
            table.insert(self.drawpile, {kind = kind})
        end
    end
    TableUtils:shuffleInPlace(self.drawpile)
end

function Game:_createBank ()
    self.bank = {}
    for rescard, count in pairs(Constants.rescards) do
        self.bank[rescard] = count
    end
end

--------------------------------
-- Actions
--------------------------------

function Game:placeSettlement (vertex)
    self:_assertPhaseIs"settingUp"
    self:_assertHasntPlacedSettlementYet()
    self:_assertCanBuildInVertex(vertex)

    local building = {}
    VertexMap:set(self.buildmap, vertex, {})
end

--------------------------------
-- Checks
--------------------------------

function Game:_assertPhaseIs (expectedPhase)
    if not (self.phase == expectedPhase) then
        error{
            kind = "InvalidPhase",
            expected = expectedPhase,
            obtained = self.phase,
        }
    end
end

function Game:_assertHasntPlacedSettlementYet (n)
    if not (self:_numberOfBuildings() < self.round) then
        error{
            kind = "AlreadyPlacedSettlement",
        }
    end
end

function Game:_assertCanBuildInVertex (vertex)
    if not self:_isVertexCornerOfSomeHex(vertex) then
        error{
            kind = "VertexNotCornerOfHex",
            vertex = vertex,
        }
    end
    if VertexMap:get(self.buildmap, vertex) then
        error{
            kind = "VertexHasBuilding",
            vertex = vertex,
        }
    end
    if self:_isVertexAdjacentToSomeBuilding(vertex) then
        error{
            kind = "VertexAdjacentToBuilding",
            vertex = vertex,
        }
    end
end

--------------------------------
-- Auxiliary functions
--------------------------------

function Game:_numberOfBuildings ()
    local n = 0
    VertexMap:iter(self.buildmap, function (q, r, v, building)
        if building.player == self.player then
            n = n + 1
        end
    end)
    return n
end

function Game:_isVertexCornerOfSomeHex (vertex)
    local found = false
    FaceMap:iter(self.hexmap, function (q, r, hex)
        local face = Grid:face(q, r)
        local corners = Grid:corners(face)
        for _, corner in ipairs(corners) do
            if Grid:vertexEq(corner, vertex) then
                found = true
                return true -- stop iteration
            end
        end
    end)
    return found
end

function Game:_isVertexAdjacentToSomeBuilding (vertex)
    local adjacentVertices = Grid:adjacentVertices(vertex)
    for _, adjacentVertex in ipairs(adjacentVertices) do
        if VertexMap:get(self.buildmap, adjacentVertex) then
            return true -- stop iteration
        end
    end
    return false
end

function Game:_isVertexNearPlayersRoad (vertex)
    local protrudingEdges = Grid:protrudingEdges(vertex)
    for _, protrudingEdge in ipairs(protrudingEdges) do
        local road = EdgeMap:get(self.roadmap, protrudingEdge)
        if road == self.player then
            return true -- stop iteration
        end
    end
    return false
end

--------------------------------

return Game
