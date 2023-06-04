local Class = require "util.class"
local TableUtils = require "util.table"

local CatanSchema = require "catan.logic.schema"
local CatanConstants = require "catan.logic.constants"
local Grid = require "catan.logic.grid"
local FaceMap = require "catan.logic.FaceMap"
local VertexMap = require "catan.logic.VertexMap"
local EdgeMap = require "catan.logic.EdgeMap"

--------------------------------

local Game = Class "Game"

--------------------------------
-- Constructor
--------------------------------

function Game:new (players)
    players = players or CatanConstants.players
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
    self.buildmap = VertexMap:new()
    self.roadmap = EdgeMap:new()
    self:_placeRobberInDesert()
    self:_createDevelopmentCards()
    self:_createResourceCards()
    self.lastdiscard = {}
    self:_createDrawPile()
    self:_createBank()
end

function Game:_setPlayers (players)
    do
        -- Register all valid player colors
        local taken = {}
        for i, player in ipairs(CatanConstants.players) do
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
    for kind, count in pairs(CatanConstants.terrain) do
        for i = 1, count do
            table.insert(hexes, kind)
        end
    end
    TableUtils:shuffleInPlace(hexes)
    self.hexmap = FaceMap:new()
    for i, hex in ipairs(hexes) do
        self.hexmap:set(CatanConstants.terrainFaces[i], hex)
    end
end

function Game:_createNumberMap ()
    local i = 1
    self.numbermap = FaceMap:new()
    for _, face in ipairs(CatanConstants.terrainFaces) do
        local hex = self.hexmap:get(face)
        if hex ~= 'desert' then
            self.numbermap:set(face, CatanConstants.numbers[i])
            i = i + 1
        end
    end
end

function Game:_createHarborMap ()
    self.harbormap = VertexMap:new()
    for _, harbor in ipairs(CatanConstants.harbors) do
        self.harbormap:set(harbor, harbor.kind)
    end
end

function Game:_placeRobberInDesert ()
    self.hexmap:iter(function (q, r, hex)
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
    for kind, count in pairs(CatanConstants.devcards) do
        for i = 1, count do
            table.insert(self.drawpile, kind)
        end
    end
    TableUtils:shuffleInPlace(self.drawpile)
end

function Game:_createBank ()
    self.bank = {}
    for rescard, count in pairs(CatanConstants.rescards) do
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
    self.buildmap:iter(function (q, r, v, building)

        -- increment the building counter for that player
        numOfBuildings[building.player] = numOfBuildings[building.player] + 1

        -- the vertex must touch a face with hex
        local touchesFaceWithHex = false
        for _, touchingFace in ipairs(Grid:touches(q, r, v)) do
            if self.hexmap:get(touchingFace) then
                touchesFaceWithHex = true
                break
            end
        end
        assert(touchesFaceWithHex)

        -- the vertex must have a protruding edge with a road of same color
        -- (in other words, the vertex must be a road endpoint of same color)
        local isRoadEndpoint = false
        for _, protrudingEdge in ipairs(Grid:protrudingEdges(q, r, v)) do
            local player = self.roadmap:get(protrudingEdge)
            if building.player == player then
                isRoadEndpoint = true
                break
            end
        end
        -- unless the current player is still placing the road...
        if not isRoadEndpoint then
            assert(self:_isPhase"placingInitialRoad")
            assert(self.player == building.player)
            assert(building.kind == "settlement")
            numOfLonelySettlements = numOfLonelySettlements + 1
        end

        -- every adjacent vertex must have no building
        for _, adjacentVertex in ipairs(Grid:adjacentVertices(q, r, v)) do
            assert(not self.buildmap:get(adjacentVertex))
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
                    assert(self:_isPhase"placingInitialSettlement")
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
                    assert(self:_isPhase"placingInitialSettlement")
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
    self.roadmap:iter(function (q, r, e)
        assert(self:_doesEdgeJoinFaceWithHex(q, r, e))
    end)

    -- Check if every road is connected to a building of same color
    for _, player in ipairs(self.players) do
        self:_validatePlayerRoads(player)
    end
end

function Game:_validatePlayerRoads (player)
    -- List all vertices that contain a building from the player
    local allVertices = VertexMap:new()
    self.buildmap:iter(function (q, r, v, building)
        if building.player == player then
            allVertices:set(Grid:vertex(q, r, v), true)
        end
    end)

    -- List all edges that contain a road from the player
    local allEdges = EdgeMap:new()
    self.roadmap:iter(function (q, r, e, p)
        if p == player then
            allEdges:set(Grid:edge(q, r, e), true)
        end
    end)

    -- Do a depth-first search on every vertex with a building from the player
    -- and list all the visited edges
    local visitedEdges = EdgeMap:new()
    local function visit (q, r, v)
        for _, pair in ipairs(Grid:adjacentEdgeVertexPairs(q, r, v)) do
            if allEdges:get(pair.edge) and not visitedEdges:get(pair.edge) then
                visitedEdges:set(pair.edge, true)
                visit(Grid:unpack(pair.vertex))
            end
        end
    end
    allVertices:iter(visit)

    -- Check if every edge from the player was visited by the DFS
    assert(TableUtils:deepEqual(allEdges, visitedEdges))
end

--------------------------------
-- Getters
--------------------------------

function Game:getNumberOfVictoryPoints (player)
    local n = 0

    -- 1 VP for every VP card bought by the player
    for i, devcard in ipairs(self.devcards[player]) do
        if devcard.kind == "victorypoint" and devcard.roundBought < self.round then
            n = n + 1
       end
    end

    -- 1 VP for every settlement built by the player
    -- 2 VPs for every city built by the player
    self.buildmap:iter(function (q, r, v, building)
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
        if devcard.roundPlayed == nil then
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
        if devcard.kind == 'knight' and devcard.roundPlayed ~= nil then
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

function Game:getNumberOfResourceCardsOfType (player, res)
    return self.rescards[player][res] or 0
end

function Game:hasDiscardedInThisRound (player)
    return self.lastdiscard[player] == self.round
end

function Game:isNumberOfResourceCardsAboveLimit (n)
    return n > 7
end

function Game:getNumberOfResourceCardsToDiscard (player)
    local count = self:getNumberOfResourceCards(player)
    if self:isNumberOfResourceCardsAboveLimit(count) then
        return math.floor(count / 2)
    else
        return 0
    end
end

function Game:canPlaceInitialSettlement (vertex)
    local ok, err = self:_isPhase"placingInitialSettlement"
    if not ok then
        return false, err
    end
    if vertex ~= nil then
        local valid, err = CatanSchema.Vertex:isValid(vertex)
        if not valid then
            return false, err
        end
        if not self:_isVertexCornerOfSomeHex(vertex) then
            return false, "vertex not corner of some hex"
        end
        if self.buildmap:get(vertex) ~= nil then
            return false, "vertex has building"
        end
        if self:_isVertexAdjacentToSomeBuilding(vertex) then
            return false, "vertex adjacent to building"
        end
    end
    return true
end

function Game:canPlaceInitialRoad (edge)
    local ok, err = self:_isPhase"placingInitialRoad"
    if not ok then
        return false, err
    end
    if edge ~= nil then
        local valid, err = CatanSchema.Edge:isValid(edge)
        if not valid then
            return false, err
        end
        if not self:_isEdgeEndpointOfPlayerLonelySettlement(edge) then
            return false, "edge not endpoint from player's lonely building"
        end
        if not self:_doesEdgeJoinFaceWithHex(Grid:unpack(edge)) then
            return false, "edge does not join face with hex"
        end
    end
    return true
end

function Game:canRoll (dice)
    local ok, err = self:_isPhase"playingTurns"
    if not ok then
        return false, err
    end
    local ok, err = self:_wereDiceRolled(false)
    if not ok then
        return false, err
    end
    if dice ~= nil then
        local valid, err = CatanSchema.Dice:isValid(dice)
        if not valid then
            return false, err
        end
    end
    return true
end

-- Does not check if phase is right to discard
function Game:mustPlayerDiscard (player)
    if self:hasDiscardedInThisRound(player) then
        return false, "player has discarded in this round already"
    end
    local expectedTotalDiscardCount = self:getNumberOfResourceCardsToDiscard(player)
    if expectedTotalDiscardCount == 0 then
        return false, "player does not need to discard anything"
    end
    return true
end

function Game:canDiscard (player, rescards)
    local ok, err = self:_isPhase"discarding"
    if not ok then
        return false, err
    end
    if player ~= nil then
        local valid, err = CatanSchema.Player:isValid(player)
        if not valid then
            return false, err
        end
        local needsToDiscard, err = self:mustPlayerDiscard(player)
        if not needsToDiscard then
            return false, err
        end
        if rescards ~= nil then
            local valid, err = CatanSchema.ResourceCardHistogram:isValid(rescards)
            if not valid then
                return false, err
            end
            local totalDiscardCount = 0
            for res, discardCount in pairs(rescards) do
                local currentCount = self:getNumberOfResourceCardsOfType(player, res)
                if discardCount > currentCount then
                    return false, "player cannot discard more than they currently have"
                end
                totalDiscardCount = totalDiscardCount + discardCount
            end
            local expectedTotalDiscardCount = self:getNumberOfResourceCardsToDiscard(player)
            if totalDiscardCount ~= expectedTotalDiscardCount then
                return false, "player is not discarding half of their cards"
            end
        end
    end
    return true
end

function Game:nobodyCanDiscard ()
    for _, player in ipairs(self.players) do
        if self:canDiscard(player) then
            return false
        end
    end
    return true
end

function Game:canMoveRobber (face)
    local ok, err = self:_isPhase"movingRobber"
    if not ok then
        return false, err
    end
    if face ~= nil then
        local valid, err = CatanSchema.Face:isValid(face)
        if not valid then
            return false, err
        end
        if self.hexmap:get(face) == nil then
            return false, "face must have a hex on it"
        end
        if CatanSchema.Face:eq(face, self.robber) then
            return false, "must move robber somewhere else"
        end
    end
    return true
end

function Game:canChooseVictim (player)
    local ok, err = self:_isPhase"choosingVictim"
    if not ok then
        return false, err
    end
    if player ~= nil then
        local valid, err = CatanSchema.Player:isValid(player)
        if not valid then
            return false, err
        end
        local isVictim = self:_getVictimsAroundFace(self.robber)
        if not isVictim[player] then
            return false, "player is not a victim"
        end
    end
    return true
end

Game.BUILD_ROAD_COST = {lumber=-1, brick=-1}

function Game:canBuildRoad (edge)
    local ok, err = self:_isPhase"playingTurns"
    if not ok then
        return false, err
    end
    local ok, err = self:_wereDiceRolled(true)
    if not ok then
        return false, err
    end
    local ok, err = self:_hasEnoughRoads()
    if not ok then
        return false, err
    end
    local ok, err = self:_canAddToResourceCounts(self.player, self.BUILD_ROAD_COST)
    if not ok then
        return false, err
    end
    if edge ~= nil then
        local valid, err = CatanSchema.Edge:isValid(edge)
        if not valid then
            return false, err
        end
        if self.roadmap:get(edge) ~= nil then
            return false, "edge already occupied by road"
        end
        local isNextToPlayerBuilding = false
        local isNextToUnblockedPlayerRoad = false
        for _, endpoint in ipairs(Grid:endpoints(Grid:unpack(edge))) do
            local building = self.buildmap:get(endpoint)
            if building == nil then
                -- If vertex is free, check if there is road ahead
                for _, protrudingEdge in ipairs(Grid:protrudingEdges(Grid:unpack(endpoint))) do
                    if self.roadmap:get(protrudingEdge) == self.player then
                        isNextToUnblockedPlayerRoad = true
                    end
                end
            else
                -- If vertex is occupied, check the builder
                if building.player == self.player then
                    isNextToPlayerBuilding = true
                end
            end
        end
        if not (isNextToPlayerBuilding or isNextToUnblockedPlayerRoad) then
            return false, "edge not next to player building or unblocked road"
        end
    end
    return true
end

Game.BUILD_SETTLEMENT_COST = {lumber=-1, brick=-1, wool=-1, grain=-1}

function Game:canBuildSettlement (vertex)
    local ok, err = self:_isPhase"playingTurns"
    if not ok then
        return false, err
    end
    local ok, err = self:_wereDiceRolled(true)
    if not ok then
        return false, err
    end
    local ok, err = self:_hasEnoughSettlements()
    if not ok then
        return false, err
    end
    local ok, err = self:_canAddToResourceCounts(self.player, self.BUILD_SETTLEMENT_COST)
    if not ok then
        return false, err
    end
    if vertex ~= nil then
        local valid, err = CatanSchema.Vertex:isValid(vertex)
        if not valid then
            return false, err
        end
        if self.buildmap:get(vertex) ~= nil then
            return false, "vertex already occupied by building"
        end
        local isNextToPlayerRoad = false
        for _, pair in ipairs(Grid:adjacentEdgeVertexPairs(Grid:unpack(vertex))) do
            if self.buildmap:get(pair.vertex) ~= nil then
                return false, "vertex is next to building"
            end
            if self.roadmap:get(pair.edge) == self.player then
                isNextToPlayerRoad = true
            end
        end
        if not isNextToPlayerRoad then
            return false, "vertex is not next to player road"
        end
    end
    return true
end

Game.BUILD_CITY_COST = {grain=-2, ore=-3}

function Game:canBuildCity (vertex)
    local ok, err = self:_isPhase"playingTurns"
    if not ok then
        return false, err
    end
    local ok, err = self:_wereDiceRolled(true)
    if not ok then
        return false, err
    end
    local ok, err = self:_hasEnoughCities()
    if not ok then
        return false, err
    end
    local ok, err = self:_canAddToResourceCounts(self.player, self.BUILD_CITY_COST)
    if not ok then
        return false, err
    end
    if vertex ~= nil then
        local valid, err = CatanSchema.Vertex:isValid(vertex)
        if not valid then
            return false, err
        end
        local building = self.buildmap:get(vertex)
        if building == nil then
            return false, "no building in vertex"
        end
        if building.player ~= self.player then
            return false, "building is not owned by current player"
        end
        if building.kind ~= "settlement" then
            return false, "building is not a settlement"
        end
    end
    return true
end

function Game:canEndTurn ()
    local ok, err = self:_isPhase"playingTurns"
    if not ok then
        return false, err
    end
    local ok, err = self:_wereDiceRolled(true)
    if not ok then
        return false, err
    end
    return true
end

function Game:iterProduction (production, f)
    return production:iter(function (q, r, hexProduction)
        local face = Grid:face(q, r)
        return hexProduction:iter(function (q, r, v, buildingProduction)
            local vertex = Grid:vertex(q, r, v)
            return f(face, vertex, buildingProduction)
        end)
    end)
end

--------------------------------
-- Actions
--------------------------------

function Game:placeInitialSettlement (vertex)
    assert(self:canPlaceInitialSettlement(vertex))

    self.buildmap:set(vertex, {
        kind = "settlement",
        player = self.player,
    })

    local production = FaceMap:new()

    if self.round == 2 then
        for _, touchingFace in ipairs(Grid:touches(Grid:unpack(vertex))) do
            local hexProduction = VertexMap:new()
            local touchingHex = self.hexmap:get(touchingFace)
            if touchingHex ~= nil then
                local res = self:resFromHex(touchingHex)
                if res ~= nil then
                    hexProduction:set(vertex, {
                        player = self.player,
                        numCards = 1,
                        res = res,
                    })
                end
            end
            production:set(touchingFace, hexProduction)
        end
    end

    self:_applyProduction(production)

    self.phase = "placingInitialRoad"

    return production
end

function Game:placeInitialRoad (edge)
    assert(self:canPlaceInitialRoad(edge))

    self.roadmap:set(edge, self.player)

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
    assert(self:canRoll(dice))

    local diceSum = 0
    for _, die in ipairs(dice) do
        diceSum = diceSum + die
    end

    local production = FaceMap:new()

    self.numbermap:iter(function (q, r, number)
        if number == diceSum then
            local face = Grid:face(q, r)
            if CatanSchema.Face:eq(self.robber, face) then
                return false -- skip to next iteration
            end
            local hex = assert(self.hexmap:get(face))
            local res = self:resFromHex(hex)
            if res ~= nil then
                local hexProduction = VertexMap:new()
                for _, corner in ipairs(Grid:corners(q, r)) do
                    local building = self.buildmap:get(corner)
                    if building ~= nil then
                        local numCards = self:numResCardsForBuilding(building.kind)
                        hexProduction:set(corner, {
                            player = building.player,
                            numCards = numCards,
                            res = res,
                        })
                    end
                end
                production:set(face, hexProduction)
            end
        end
    end)

    self:_applyProduction(production)

    self.dice = dice

    if diceSum == 7 then
        local mustSomePlayerDiscard = false
        for _, player in ipairs(self.players) do
            if self:mustPlayerDiscard(player) then
                mustSomePlayerDiscard = true
            end
        end
        if mustSomePlayerDiscard then
            self.phase = "discarding"
        else
            self.phase = "movingRobber"
        end
    end

    return production
end

function Game:discard (player, rescards)
    assert(self:canDiscard(player, rescards))

    for res, discardCount in pairs(rescards) do
        self:_addToResourceCount(player, res, -discardCount)
    end

    self.lastdiscard[player] = self.round

    if self:nobodyCanDiscard() then
        self.phase = "movingRobber"
    end
end

function Game:moveRobber (face)
    assert(self:canMoveRobber(face))

    self.robber = face

    local victims = self:_getVictimsAroundFace(face)

    local numOfVictims = TableUtils:numOfPairs(victims)

    local victim
    local res

    if numOfVictims == 1 then
        victim = next(victims)
        res = self:_stealRandomResCardFrom(victim)
    end

    if numOfVictims >= 2 then
        self.phase = "choosingVictim"
    else
        self.phase = "playingTurns"
    end

    return victim, res
end

function Game:chooseVictim (player)
    assert(self:canChooseVictim(player))

    local res = self:_stealRandomResCardFrom(player)

    self.phase = "playingTurns"

    return res
end

function Game:buildRoad (edge)
    assert(self:canBuildRoad(edge))

    self:_addToResourceCounts(self.player, self.BUILD_ROAD_COST)

    self.roadmap:set(edge, self.player)
end

function Game:buildSettlement (vertex)
    assert(self:canBuildSettlement(vertex))

    self:_addToResourceCounts(self.player, self.BUILD_SETTLEMENT_COST)

    self.buildmap:set(vertex, {
        kind = "settlement",
        player = self.player,
    })
end

function Game:buildCity (vertex)
    assert(self:canBuildCity(vertex))

    self:_addToResourceCounts(self.player, self.BUILD_CITY_COST)

    self.buildmap:set(vertex, {
        kind = "city",
        player = self.player,
    })
end

function Game:endTurn ()
    assert(self:canEndTurn())

    local i = self:_getCurrentPlayerIndex()

    if i == #self.players then
        self.round = self.round + 1
    end

    self.player = self:_getPlayerAfterIndex(i)
    self.dice = nil
end

--------------------------------
-- Auxiliary functions
--------------------------------

function Game:_choosePlayerResCardAtRandom (player)
    local n = self:getNumberOfResourceCards(player)
    if n >= 1 then
        local i = math.random(n)
        local j = 0
        for res, count in pairs(self.rescards[player]) do
            j = j + count
            if j >= i then
                return res
            end
        end
    end
end

function Game:_getVictimsAroundFace (face)
    local victims = {}
    for _, corner in ipairs(Grid:corners(Grid:unpack(face))) do
        local building = self.buildmap:get(corner)
        if building then
            local player = building.player
            if player ~= self.player then
                local numCards = self:getNumberOfResourceCards(player)
                if numCards >= 1 then
                    victims[player] = true
                end
            end
        end
    end
    return victims
end

function Game:_isPhase (phase)
    if self.phase ~= phase then
        return false, "phase is not " .. phase
    end
    return true
end

function Game:_wereDiceRolled (expectedRolled)
    if expectedRolled then
        if self.dice == nil then
            return false, "dice weren't rolled yet"
        end
        return true
    else
        if self.dice ~= nil then
            return false, "dice were rolled already"
        end
        return true
    end
end

function Game:_hasEnoughRoads ()
    local n = 0
    self.roadmap:iter(function (q, r, e, player)
        if player == self.player then
            n = n + 1
        end
    end)
    assert(n <= CatanConstants.roads)
    if n == CatanConstants.roads then
        return false, "player has used all roads"
    end
    return true
end

function Game:_hasEnoughSettlements ()
    local n = 0
    self.buildmap:iter(function (q, r, v, building)
        if building.player == self.player and building.kind == "settlement" then
            n = n + 1
        end
    end)
    assert(n <= CatanConstants.settlements)
    if n == CatanConstants.settlements then
        return false, "player has used all settlements"
    end
    return true
end

function Game:_hasEnoughCities ()
    local n = 0
    self.buildmap:iter(function (q, r, v, building)
        if building.player == self.player and building.kind == "city" then
            n = n + 1
        end
    end)
    assert(n <= CatanConstants.cities)
    if n == CatanConstants.cities then
        return false, "player has used all cities"
    end
    return true
end

function Game:_stealRandomResCardFrom (victim)
    local res = self:_choosePlayerResCardAtRandom(victim)
    assert(res ~= nil, "victim must have at least one card")
    self:_addToResourceCount(victim, res, -1)
    self:_addToResourceCount(self.player, res, 1)
    return res
end

function Game:_canAddToResourceCounts (player, rescards)
    for rescard, count in pairs(rescards) do
        local ok, err = self:_canAddToResourceCount(player, rescard, count)
        if not ok then
            return false, err
        end
    end
    return true
end

function Game:_addToResourceCounts (player, rescards)
    for rescard, count in pairs(rescards) do
        self:_addToResourceCount(player, rescard, count)
    end
end

function Game:_canAddToResourceCount (player, rescard, count)
    local countBefore = self.rescards[player][rescard] or 0
    local countAfter = countBefore + count
    if countAfter < 0 then
        return false, "not enough " .. rescard
    end
    return true
end

function Game:_addToResourceCount (player, rescard, count)
    local countBefore = self.rescards[player][rescard] or 0
    local countAfter = countBefore + count
    assert(countAfter >= 0, "num of rescards cannot be negative")
    self.rescards[player][rescard] = countAfter
end

function Game:_applyProduction (production)
    self:iterProduction(production, function (face, vertex, buildingProduction)
        local player = assert(buildingProduction.player)
        local res = assert(buildingProduction.res)
        local numCards = assert(buildingProduction.numCards)
        self:_addToResourceCount(player, res, numCards)
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
        local building = self.buildmap:get(endpoint)
        if building and building.player == self.player then
            assert(building.kind == "settlement")
            local isSettlementLonely = true
            for _, protrudingEdge in ipairs(Grid:protrudingEdges(Grid:unpack(endpoint))) do
                if self.roadmap:get(protrudingEdge) then
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
        if self.hexmap:get(joinedFace) then
            return true
        end
    end
    return false
end

function Game:_isVertexCornerOfSomeHex (vertex)
    local found = false
    self.hexmap:iter(function (q, r, hex)
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
        if self.buildmap:get(adjacentVertex) then
            return true
        end
    end
    return false
end

--------------------------------

return Game
