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
    self.phase = 'placingInitialSettlement'
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
    do
        -- Register all valid player colors
        local taken = {}
        for i, player in ipairs(Constants.players) do
            taken[player] = false
        end

        -- Count the number of players and check
        -- if there are invalid or repeated ones
        local n = 0
        for i, player in ipairs(players) do
            local v = taken[player]
            assert(v ~= nil, "invalid player")
            assert(v ~= true, "repeated player")
            taken[player] = true
            n = n + 1
        end
        assert(n >= 3, "too few players")
    end

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
            return true -- quit iteration
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
-- Getters
--------------------------------

function Game:getNumberOfVictoryPoints (player)
    local n = 0

    -- 1 VP for every VP card bought by the player
    for i, devcard in ipairs(self.devcards[player]) do
        if devcard.kind == "victorypoint" and devcard.round < self.round then
            n = n + 1
       end
    end

    -- 1 VP for every settlement built by the player
    -- 2 VPs for every city built by the player
    VertexMap:iter(self.buildmap, function (q, r, v, building)
        if building.player == player then
            if building.kind == "settlement" then
                n = n + 1
            else
                assert(building.kind == "city")
                n = n + 2
            end
        end
    end)

    -- 2 VP if player has the longest road
    if self.longestroad == player then
        n = n + 2
    end

    -- 2 VP if player has the largest army
    if self.largestarmy == player then
        n = n + 2
    end

    return n
end

function Game:getNumberOfDevelopmentCards (player)
    local n = 0
    for i, devcard in ipairs(self.devcards[player]) do
        if not devcard.used then
            n = n + 1
        end
    end
    return n
end

function Game:getNumberOfResourceCards (player)
    local n = 0
    for res, count in pairs(self.rescards[player]) do
        n = n + count
    end
    return n
end

function Game:getArmySize (player)
    local n = 0
    for i, devcard in ipairs(self.devcards[player]) do
        if devcard.kind == 'knight' and devcard.used then
            n = n + 1
        end
    end
    return n
end

--------------------------------
-- Actions
--------------------------------

function Game:placeInitialSettlement (vertex)
    self:_assertPhaseIs"placingInitialSettlement"
    self:_assertCanBuildInVertex(vertex)

    VertexMap:set(self.buildmap, vertex, {
        kind = "settlement",
        player = self.player,
    })

    self.phase = "placingInitialRoad"
end

--------------------------------
-- Checks
--------------------------------

function Game:_assertPhaseIs (expectedPhase)
    if self.phase ~= expectedPhase then
        error(('expected phase "%s", not "%s"'):format(expectedPhase, self.phase))
    end
end

function Game:_assertCanBuildInVertex (vertex)
    assert(self:_isVertexCornerOfSomeHex(vertex), "vertex not corner of some hex")
    assert(VertexMap:get(self.buildmap, vertex) == nil, "vertex has building")
    assert(not self:_isVertexAdjacentToSomeBuilding(vertex), "vertex adjacent to building")
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
        for _, corner in ipairs(Grid:corners(q, r)) do
            if Grid:vertexEq(corner, vertex) then
                found = true
                return true -- quit iteration
            end
        end
    end)
    return found
end

function Game:_isVertexAdjacentToSomeBuilding (vertex)
    local adjacentVertices = Grid:adjacentVertices(Grid:unpack(vertex))
    for _, adjacentVertex in ipairs(adjacentVertices) do
        if VertexMap:get(self.buildmap, adjacentVertex) then
            return true
        end
    end
    return false
end

function Game:_isVertexNearPlayersRoad (vertex)
    local protrudingEdges = Grid:protrudingEdges(Grid:unpack(vertex))
    for _, protrudingEdge in ipairs(protrudingEdges) do
        local road = EdgeMap:get(self.roadmap, protrudingEdge)
        if road == self.player then
            return true
        end
    end
    return false
end

--------------------------------

return Game
