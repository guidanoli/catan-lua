local Class = require "util.class"
local TableUtils = require "util.table"

local CatanSchema = require "catan.logic.schema"
local Constants = require "catan.logic.constants"
local Grid = require "catan.logic.grid"
local FaceMap = require "catan.logic.facemap"
local VertexMap = require "catan.logic.vertexmap"
local EdgeMap = require "catan.logic.edgemap"
local Roll = require "catan.logic.roll"

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
            table.insert(self.drawpile, kind)
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
-- Validation
--------------------------------

function Game:validate ()
    assert(CatanSchema.GameState:isValid(self))

    -- We only validate dynamic fields, since
    -- the static fields are checked during construction

    self:_validateRound()
    self:_validateBuildMap()
    self:_validateRoadMap()
end

function Game:_validateRound ()
    assert(self.round >= 1)

    -- set of initial rounds and phases
    local initialRounds = {[1] = true, [2] = true}
    local initialPhases = {placingInitialSettlement = true, placingInitialRoad = true}

    -- Lua 5.1 doesn't have exclusive or...
    local function iff (a, b)
        return (a and b) or (not a and not b)
    end

    -- round in [1,2] iff phase is placing initial settlement or road
    assert(iff(initialRounds[self.round], initialPhases[self.phase]))
end

function Game:_validateBuildMap ()
    local numOfLonelySettlements = 0
    local numOfBuildings = {}

    for _, player in ipairs(self.players) do
        numOfBuildings[player] = 0
    end

    -- for every building...
    VertexMap:iter(self.buildmap, function (q, r, v, building)

        -- increment the building counter for that player
        numOfBuildings[building.player] = numOfBuildings[building.player] + 1

        -- the vertex must touch a face with hex
        local touchesFaceWithHex = false
        for _, touchingFace in ipairs(Grid:touches(q, r, v)) do
            if FaceMap:get(self.hexmap, touchingFace) then
                touchesFaceWithHex = true
                break
            end
        end
        assert(touchesFaceWithHex)

        -- the vertex must have a protruding edge with a road of same color
        -- (in other words, the vertex must be a road endpoint of same color)
        local isRoadEndpoint = false
        for _, protrudingEdge in ipairs(Grid:protrudingEdges(q, r, v)) do
            local player = EdgeMap:get(self.roadmap, protrudingEdge)
            if building.player == player then
                isRoadEndpoint = true
                break
            end
        end
        -- unless the current player is still placing the road...
        if not isRoadEndpoint then
            assert(self.phase == "placingInitialRoad")
            assert(self.player == building.player)
            assert(building.kind == "settlement")
            numOfLonelySettlements = numOfLonelySettlements + 1
        end

        -- every adjacent vertex must have no building
        for _, adjacentVertex in ipairs(Grid:adjacentVertices(q, r, v)) do
            assert(not VertexMap:get(self.buildmap, adjacentVertex))
        end
    end)

    -- there must not be more than one lonely settlement
    assert(numOfLonelySettlements <= 1)

    if self.round == 1 then
        -- in round 1, every player that has played must have 1 building
        -- and every player that hasn't played must have 0 buildings
        local j = self:_getCurrentPlayerIndex()
        for i, player in ipairs(self.players) do
            if i < j then
                assert(numOfBuildings[player] == 1)
            elseif i == j then
                if self.phase == "placingInitialRoad" then
                    assert(numOfBuildings[player] == 1)
                else
                    assert(self.phase == "placingInitialSettlement")
                    assert(numOfBuildings[player] == 0)
                end
            else
                assert(numOfBuildings[player] == 0)
            end
        end
    elseif self.round == 2 then
        -- in round 2, every player that has played must have 2 building
        -- and every player that hasn't played must have 1 building
        local j = self:_getCurrentPlayerIndex()
        for i, player in ipairs(self.players) do
            if i < j then
                assert(numOfBuildings[player] == 1)
            elseif i == j then
                if self.phase == "placingInitialRoad" then
                    assert(numOfBuildings[player] == 2)
                else
                    assert(self.phase == "placingInitialSettlement")
                    assert(numOfBuildings[player] == 1)
                end
            else
                assert(numOfBuildings[player] == 2)
            end
        end
    else
        -- after round 2, each player must have at least 2 buildings
        for _, player in ipairs(self.players) do
            assert(numOfBuildings[player] >= 2)
        end
    end
end

function Game:_validateRoadMap ()
    -- Check if every road is next to a hex
    EdgeMap:iter(self.roadmap, function (q, r, e)
        assert(self:_doesEdgeJoinFaceWithHex(q, r, e))
    end)

    -- Check if every road is connected to a building of same color
    for _, player in ipairs(self.players) do
        self:_validatePlayerRoads(player)
    end
end

function Game:_validatePlayerRoads (player)
    -- List all vertices that contain a building from the player
    local allVertices = {}
    VertexMap:iter(self.buildmap, function (q, r, v, building)
        if building.player == player then
            VertexMap:set(allVertices, Grid:vertex(q, r, v), true)
        end
    end)

    -- List all edges that contain a road from the player
    local allEdges = {}
    EdgeMap:iter(self.roadmap, function (q, r, e, p)
        if p == player then
            EdgeMap:set(allEdges, Grid:edge(q, r, e), true)
        end
    end)

    -- Do a depth-first search on every vertex with a building from the player
    -- and list all the visited edges
    local visitedEdges = {}
    local function visit(q, r, v)
        for _, pair in ipairs(Grid:adjacentEdgeVertexPairs(q, r, v)) do
            if EdgeMap:get(allEdges, pair.edge) and not EdgeMap:get(visitedEdges, pair.edge) then
                EdgeMap:set(visitedEdges, pair.edge, true)
                visit(Grid:unpack(pair.vertex))
            end
        end
    end
    VertexMap:iter(allVertices, visit)

    -- Check if every edge from the player was visited by the DFS
    assert(EdgeMap:equal(allEdges, visitedEdges))
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

Game.RES_FROM_HEX = {
    hills = 'brick',
    forest = 'lumber',
    mountains = 'ore',
    fields = 'grain',
    pasture = 'wool',
}

function Game:resFromHex (hex)
    local res = self.RES_FROM_HEX[hex]
    if res ~= nil then
        return CatanSchema.ResourceCard:new(res)
    end
end

function Game:numResCardsForBuilding (kind)
    if kind == "settlement" then
        return 1
    else
        assert(kind == "city")
        return 2
    end
end

function Game:getNumberOfResourceCardsOfType(player, res)
    return self.rescards[player][res] or 0
end

--------------------------------
-- Actions
--------------------------------

function Game:placeInitialSettlement (vertex)
    assert(CatanSchema.Vertex:isValid(vertex))
    assert(self:_phaseIs"placingInitialSettlement")
    assert(self:_isVertexCornerOfSomeHex(vertex), "vertex not corner of some hex")
    assert(VertexMap:get(self.buildmap, vertex) == nil, "vertex has building")
    assert(not self:_isVertexAdjacentToSomeBuilding(vertex), "vertex adjacent to building")

    VertexMap:set(self.buildmap, vertex, {
        kind = "settlement",
        player = self.player,
    })

    local roll = {}

    if self.round == 2 then
        for _, touchingFace in ipairs(Grid:touches(Grid:unpack(vertex))) do
            local touchingHex = FaceMap:get(self.hexmap, touchingFace)
            if touchingHex ~= nil then
                local res = self:resFromHex(touchingHex)
                if res ~= nil then
                    Roll:add(roll, self.player, res, 1)
                end
            end
        end
    end

    self:_applyRoll(roll)

    self.phase = "placingInitialRoad"

    return roll
end

function Game:placeInitialRoad (edge)
    assert(CatanSchema.Edge:isValid(edge))
    assert(self:_phaseIs"placingInitialRoad")
    assert(self:_isEdgeEndpointOfPlayerLonelySettlement(edge), "edge not endpoint from player's lonely building")
    assert(self:_doesEdgeJoinFaceWithHex(Grid:unpack(edge)), "edge does not join face with hex")

    EdgeMap:set(self.roadmap, edge, self.player)

    local i = self:_getCurrentPlayerIndex()

    if self.round == 1 then
        if i == #self.players then
            self.round = 2
        else
            self.player = self:_getPlayerAfterIndex(i)
        end

        self.phase = "placingInitialSettlement"
    else
        assert(self.round == 2)

        if i == 1 then
            self.round = 3
            self.phase = "playingTurns"
        else
            self.player = self:_getPlayerBeforeIndex(i)
            self.phase = "placingInitialSettlement"
        end
    end
end

function Game:roll (dice)
    assert(CatanSchema.Dice:isValid(dice))
    assert(self:_phaseIs"playingTurns")
    assert(self.dice == nil, "dice have been rolled already")

    local diceSum = 0
    for _, die in ipairs(dice) do
        diceSum = diceSum + die
    end

    local roll = {}

    FaceMap:iter(self.numbermap, function (q, r, number)
        if number == diceSum then
            local face = Grid:face(q, r)
            if CatanSchema.Face:eq(self.robber, face) then
                return false -- skip to next iteration
            end
            local hex = assert(FaceMap:get(self.hexmap, face))
            local res = self:resFromHex(hex)
            if res ~= nil then
                for _, corner in ipairs(Grid:corners(q, r)) do
                    local building = VertexMap:get(self.buildmap, corner)
                    if building ~= nil then
                        local numCards = self:numResCardsForBuilding(building.kind)
                        Roll:add(roll, building.player, res, numCards)
                    end
                end
            end
        end
    end)

    self:_applyRoll(roll)

    self.dice = dice

    if diceSum == 7 then
        local mustDiscard = false
        for _, player in ipairs(self.players) do
            local numResCards = self:getNumberOfResourceCards(player)
            if numResCards > 7 then
                mustDiscard = true
                break
            end
        end
        if mustDiscard then
            self.phase = "discardingHalf"
        else
            self.phase = "movingRobber"
        end
    end

    return roll
end

--------------------------------
-- Checks
--------------------------------

function Game:_phaseIs (expectedPhase)
    if self.phase == expectedPhase then
        return true
    else
        return false, "not " .. expectedPhase
    end
end

--------------------------------
-- Auxiliary functions
--------------------------------

function Game:_applyRoll (roll)
    Roll:iter(roll, function (player, res, numCards)
        self.rescards[player][res] = (self.rescards[player][res] or 0) + numCards
    end)
end

function Game:_getCurrentPlayerIndex ()
    for i, player in ipairs(self.players) do
        if player == self.player then
            return i
        end
    end
    error"player not in players"
end

function Game:_getPlayerAfterIndex (i)
    local n = #self.players
    return self.players[i % n + 1]
end

function Game:_getPlayerBeforeIndex (i)
    local n = #self.players
    return self.players[(i + n - 2) % n + 1]
end

-- We say a settlement is lonely when it has no protruding roads
function Game:_isEdgeEndpointOfPlayerLonelySettlement (edge)
    for _, endpoint in ipairs(Grid:endpoints(Grid:unpack(edge))) do
        local building = VertexMap:get(self.buildmap, endpoint)
        if building and building.player == self.player then
            assert(building.kind == "settlement")
            local isSettlementLonely = true
            for _, protrudingEdge in ipairs(Grid:protrudingEdges(Grid:unpack(endpoint))) do
                if EdgeMap:get(self.roadmap, protrudingEdge) then
                    isSettlementLonely = false
                    break
                end
            end
            if isSettlementLonely then
                return true
            end
        end
    end
    return false
end

function Game:_doesEdgeJoinFaceWithHex (q, r, e)
    for i, joinedFace in ipairs(Grid:joins(q, r, e)) do
        if FaceMap:get(self.hexmap, joinedFace) then
            return true
        end
    end
    return false
end

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
            if CatanSchema.Vertex:eq(corner, vertex) then
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
