---
-- Catan game state class.
--
-- This class implements the state of a Catan match.
--
-- @classmod catan.logic.Game

local serpent = require "serpent"

local Class = require "util.class"
local TableUtils = require "util.table"
local LogicUtils = require "util.logic"

local CatanSchema = require "catan.logic.schema"
local CatanConstants = require "catan.logic.constants"
local Grid = require "catan.logic.grid"
local FaceMap = require "catan.logic.FaceMap"
local VertexMap = require "catan.logic.VertexMap"
local EdgeMap = require "catan.logic.EdgeMap"
local HexProduction = require "catan.logic.HexProduction"

--------------------------------

local Game = Class "Game"

--------------------------------
-- Compatibility with Lua 5.1
--------------------------------

local load = loadstring or load

---------------------------------------------------------
-- Constructor
--
-- The class constructor is responsible for creating
-- new matches with random initial setups.
--
-- @section constructor
---------------------------------------------------------

---
-- Create a new game from a list of players colors.
-- The valid player colors are `"red"`, `"blue"`, `"yellow"` and `"white"`.
-- The list must not have repetitions or fewer than 3 colors.
-- The list dictates the order of turns, starting with the first.
--
-- @tparam[opt] {string,...} players an array of player colors
-- @treturn Game game
function Game:new (players)
    players = players or CatanConstants.players
    local game = self:__new{}
    game:_init(players)
    return game
end

function Game:_init (players)
    self.version = CatanSchema.VERSION
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
    self.roadcredit = {}
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
        self.harbormap:set(harbor.vertex, harbor.kind)
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

-----------------------------------------------------------------------
-- Validation
--
-- We can check that the game state is valid according to a set of
-- invariants, to increase the chance of detecting bugs.
--
-- @section validation
-----------------------------------------------------------------------

---
-- Validate game state against invariants.
-- Raises an error message if an invariant is not satisfied.
function Game:validate ()
    assert(CatanSchema.GameState:isValid(self))

    -- We only validate dynamic fields, since
    -- the static fields are checked during construction

    self:_validateRound()
    self:_validateDice()
    self:_validateBuildMap()
    self:_validateRoadMap()
    self:_validateRobber()
    self:_validateWinner()
    self:_validateDevCards()
    self:_validateResCards()
    self:_validateLongestRoad()
    self:_validateLastDiscard()
end

function Game:_validateRound ()
    assert(self.round >= 1)

    -- set of initial rounds and phases
    local initialRounds = {[1] = true, [2] = true}
    local initialPhases = {placingInitialSettlement = true, placingInitialRoad = true}

    -- round in [1,2] iff phase is placing initial settlement or road
    assert(LogicUtils:iff(initialRounds[self.round], initialPhases[self.phase]))
end

function Game:_validateDice ()
    assert(LogicUtils:implies(self.round <= 2, self.dice == nil))
    assert(LogicUtils:implies(self.dice ~= nil, self.round > 2))

    local sum = 0

    if self.dice ~= nil then
        for _, die in ipairs(self.dice) do
            sum = sum + die
        end
    end

    assert(LogicUtils:implies(self.phase == "discarding", sum == 7))
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

function Game:_validateRobber ()
    -- Check if robber is on top of a face with hex
    assert(self.hexmap:get(self.robber))
end

function Game:_validateWinner ()
    assert(LogicUtils:iff(self.phase == 'end', self.winner == self.player))
end

function Game:_validateDevCards ()
    -- Keep a histogram of dev card kinds
    local alldevcards = {}

    local function incrementCount (kind)
        alldevcards[kind] = (alldevcards[kind] or 0) + 1
    end

    -- Iterate through all dev cards in players' hands
    for player, devcards in pairs(self.devcards) do
        for _, devcard in ipairs(devcards) do
            assert(devcard.roundBought >= 3)
            assert(devcard.roundBought <= self.round)
            if devcard.roundPlayed ~= nil then
                assert(devcard.roundPlayed >= 4)
                assert(devcard.roundPlayed <= self.round)
            end
            incrementCount(devcard.kind)
        end
    end

    -- Iterate through all dev cards in the draw pile
    for _, kind in ipairs(self.drawpile) do
        incrementCount(kind)
    end

    -- Check if quantities match
    for kind, count in pairs(CatanConstants.devcards) do
        assert(alldevcards[kind] == count)
    end
end

function Game:_validateResCards ()
    -- Keep a histogram of res card kinds
    local allrescards = {}

    local function addToCount (kind, n)
        allrescards[kind] = (allrescards[kind] or 0) + n
    end

    -- Iterate through all res cards in players' hands
    for player, rescards in pairs(self.rescards) do
        for kind, n in pairs(rescards) do
            assert(n >= 0)
            addToCount(kind, n)
        end
    end

    -- Iterate through all res cards in the bank
    for kind, n in pairs(self.bank) do
        assert(n >= 0)
        addToCount(kind, n)
    end

    -- Check if quantities match
    for kind, count in pairs(CatanConstants.rescards) do
        assert(allrescards[kind] == count)
    end
end

function Game:_validateLongestRoad ()
    local lengths = {}

    for _, player in ipairs(self.players) do
        lengths[player] = self:getLongestRoadLength(player)
    end

    local maxLength, tiedCount, tiedPlayers = TableUtils:podium(lengths)

    assert(maxLength >= 0)

    if self.longestroad == nil then
        if tiedCount == 1 then
            assert(maxLength < 5)
        end
    else
        assert(maxLength >= 5)
        assert(tiedPlayers[self.longestroad])
    end
end

function Game:_validateLastDiscard ()
    for player, lastdiscard in pairs(self.lastdiscard) do
        assert(lastdiscard >= 2)
        assert(lastdiscard <= self.round)
    end
end

----------------------------------------------------------------------
-- Serialization
--
-- We can store a game state in a file, and load it back up
-- through serialization and deserialization, respectively.
--
-- @section serialization
----------------------------------------------------------------------

---
-- Clone game state.
-- @treturn Game identical game state
function Game:clone ()
    return TableUtils:deepCopy(self)
end

---
-- Serialize game state.
-- @treturn string game state serialization
function Game:serialize ()
    return 'return ' .. serpent.block(self, {
        comment = false,
    })
end

---
-- Deserialize game state.
-- @tparam string str game state serialization
-- @treturn ?Game deserialized game state (or `nil` in case of failure)
-- @treturn ?string error message (in case of failure)
function Game:deserialize (str)
    -- Load table from string
    local f, err = load(str)
    if f == nil then
        return nil, err
    end
    local ok, ret = pcall(f)
    if not ok then
        return nil, ret or 'chunk execution failed'
    end

    -- Check return type
    if type(ret) ~= 'table' then
        return nil, 'chunk does not return a table'
    end

    -- Check version
    if ret.version ~= CatanSchema.VERSION then
        return nil, 'incompatible schema version'
    end

    -- Check schema
    local ok, err = CatanSchema.GameState:isValid(ret)
    if not ok then
        return nil, err
    end

    -- Set metatables
    FaceMap:__new(ret.hexmap)
    FaceMap:__new(ret.numbermap)
    VertexMap:__new(ret.harbormap)
    VertexMap:__new(ret.buildmap)
    EdgeMap:__new(ret.roadmap)
    local game = self:__new(ret)

    -- Validate game state
    local ok, err = pcall(self.validate, game)
    if not ok then
        return nil, err
    end

    return game
end

----------------------------------------------------------------
-- Getters
--
-- Getters are read-only methods that provide information
-- about the current state of the game.
--
-- @section getters
----------------------------------------------------------------

---
-- Get the number of victory points of a player.
--
-- @tparam string player
-- @treturn number number of victory points
function Game:getNumberOfVictoryPoints (player)
    local n = 0

    -- 1 VP for every VP card bought by the player
    for i, devcard in ipairs(self.devcards[player]) do
        if devcard.kind == "victorypoint" then
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

---
-- Get the number of development cards of a player.
--
-- @tparam string player
-- @treturn number number of development cards
function Game:getNumberOfDevelopmentCards (player)
    local n = 0
    for i, devcard in ipairs(self.devcards[player]) do
        if devcard.roundPlayed == nil then
            n = n + 1
        end
    end
    return n
end

---
-- Get the number of resource cards of a player.
--
-- @tparam string player
-- @treturn number number of resource cards
function Game:getNumberOfResourceCards (player)
    local n = 0
    for res, count in pairs(self.rescards[player]) do
        n = n + count
    end
    return n
end

---
-- Get the size of a player's army.
-- A player's army is composed of the knights they have used so far.
--
-- @tparam string player
-- @treturn number army size
function Game:getArmySize (player)
    local n = 0
    for i, devcard in ipairs(self.devcards[player]) do
        if devcard.kind == 'knight' and devcard.roundPlayed ~= nil then
            n = n + 1
        end
    end
    return n
end

---
-- Get number of resource cards a player must discard.
-- If the number of resource cards is above the limit, the player must
-- discard half of their cards (rounding down).
--
-- @tparam string player
-- @treturn number number of resource cards to discard
-- @see catan.logic.Game:isNumberOfResourceCardsAboveLimit
function Game:getNumberOfResourceCardsToDiscard (player)
    local count = self:getNumberOfResourceCards(player)
    if self:isNumberOfResourceCardsAboveLimit(count) then
        return math.floor(count / 2)
    else
        return 0
    end
end

---
-- Get the length of the longest road of a player.
--
-- @tparam string player
-- @treturn number length of the longest road of player
function Game:getLongestRoadLength (player)
    local maxLength = 0
    self.roadmap:iter(function (q, r, e, p)
        if p == player then
            local edge = Grid:edge(q, r, e)
            local length = self:_getLongestRoadWithEdge(p, edge)
            if length > maxLength then
                maxLength = length
            end
        end
    end)
    return maxLength
end

---
-- Get the winner of the game.
--
-- @treturn ?string the winner (or `nil` if no one has won yet)
function Game:getWinner ()
    local scores = {}

    for _, player in ipairs(self.players) do
        scores[player] = self:getNumberOfVictoryPoints(player)
    end

    local maxScore, tiedCount, tiedPlayers = TableUtils:podium(scores)

    if maxScore >= 10 then
        if tiedPlayers[self.player] then
            return self.player
        else
            return nil
        end
    else
        return nil
    end
end

---
-- Get the ratios with which a player can trade in harbors.
-- We represent a ratio of `x:1` simply by the number `x`.
--
-- @tparam string player
-- @treturn table ratios trading ratios for each resource
-- @treturn number baseRatio base trading ratio (if not in `ratios`)
--
-- @usage
-- local ratios, baseRatio = game:getTradeRatios(player)
-- local ratio = ratios[res] or baseRatio
function Game:getTradeRatios (player)
    local ratios = {}
    local baseRatio = 4
    self.harbormap:iter(function (q, r, v, kind)
        local vertex = Grid:vertex(q, r, v)
        local building = self.buildmap:get(vertex)
        if building and building.player == player then
            if kind == "generic" then
                baseRatio = 3
            else
                ratios[kind] = 2
            end
        end
    end)
    return ratios, baseRatio
end

---
-- Get the number of cards a player can receive from a maritime trade.
-- If some resource card has a bad ratio (for example, 5:1),
-- returns `nil` and an error message.
--
-- @tparam string player
-- @tparam table mycards histogram of resource cards from the player
-- @treturn ?number the maritime trade return
-- @treturn ?string error message (in case of failure)
function Game:getMaritimeTradeReturn (player, mycards)
    local m = 0
    local ratios, defaultRatio = self:getTradeRatios(player)
    for res, n in pairs(mycards) do
        local ratio = ratios[res] or defaultRatio
        if n % ratio == 0 then
            m = m + n / ratio
        else
            return nil, "bad ratio for " .. res
        end
    end
    return m
end

----
-- Get the first playable card of a given kind from the current player's hand.
--
-- @tparam string kind
-- @treturn boolean
-- @treturn ?string error message (in case of failure)
function Game:getPlayableCardOfKind (kind)
    local ok, err = self:_isPhase"playingTurns"
    if not ok then
        return nil, err
    end
    if kind == "victorypoint" then
        return false, "cannot play this kind of card"
    end
    for _, devcard in ipairs(self.devcards[self.player]) do
        if devcard.roundPlayed == self.round then
            return nil, "a development card was already played in this turn"
        end
    end
    for _, devcard in ipairs(self.devcards[self.player]) do
        if devcard.kind == kind and self:isCardPlayable(devcard) then
            return devcard
        end
    end
    return nil, "player doesn't have such development card"
end

---------------------------------------------------------------
-- Predicates
--
-- Predicates are read-only methods that allow the developer
-- to know if they can call a given action method.
--
-- @section predicates
---------------------------------------------------------------

---
-- Check whether the current player can place one of its initial settlement in a given vertex.
--
-- @tparam[opt] {q=number,r=number,v='N'|'S'} vertex
-- @treturn boolean
-- @treturn ?string error message (in case of failure)
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

---
-- Check whether the current player can place one of its initial road in a given edge.
--
-- @tparam[opt] {q=number,r=number,e='NE'|'NW'|'W'} edge
-- @treturn boolean
-- @treturn ?string error message (in case of failure)
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

---
-- Check whether the current player can roll the given dice.
-- The possible values for each die are: 1, 2, 3, 4, 5, and 6.
--
-- @tparam[opt] {number,number} dice
-- @treturn boolean
-- @treturn ?string error message (in case of failure)
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

---
-- Check whether a number of resource cards is above limit for discard.
-- If a player has more resource cards than the limit, and a 7 is rolled,
-- they will have to discard half of their cards (rounding down).
--
-- @tparam number n number of resource cards
-- @treturn boolean whether number is above limit
-- @see catan.logic.Game:getNumberOfResourceCardsToDiscard
function Game:isNumberOfResourceCardsAboveLimit (n)
    return n > 7
end

---
-- Check whether a player would have to discard half of their cards if someone rolled a 7.
-- Does not check whether someone has rolled a 7.
--
-- @tparam string player
-- @treturn boolean
-- @treturn ?string error message (in case of failure)
function Game:mustPlayerDiscard (player)
    if self.lastdiscard[player] == self.round then
        return false, "player has discarded in this round already"
    end
    local expectedTotalDiscardCount = self:getNumberOfResourceCardsToDiscard(player)
    if expectedTotalDiscardCount == 0 then
        return false, "player does not need to discard anything"
    end
    return true
end

---
-- Check whether a player can discard the given resource cards.
--
-- @tparam[opt] string player
-- @tparam[optchain] table rescards histogram of resource cards from player
-- @treturn boolean
-- @treturn ?string error message (in case of failure)
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
                local currentCount = self.rescards[player][res] or 0
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

----
-- Check whether the current player can move the robber to a given face.
--
-- @tparam[opt] {q=number,r=number} face
-- @treturn boolean
-- @treturn ?string error message (in case of failure)
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

----
-- Check whether the current player can choose a given player as victim of the robber.
--
-- @tparam[opt] string player
-- @treturn boolean
-- @treturn ?string error message (in case of failure)
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

----
-- Check whether the current player can trade.
--
-- @treturn boolean
-- @treturn ?string error message (in case of failure)
function Game:canTrade ()
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

----
-- Check whether the current player can trade resource cards with a given player.
--
-- @tparam[opt] string otherplayer player to trade with (cannot be current player)
-- @tparam[optchain] table mycards histogram of resource cards from the current player
-- @tparam[optchain] table theircards histogram of resource cards from the other player
-- @treturn boolean
-- @treturn ?string error message (in case of failure)
function Game:canTradeWithPlayer (otherplayer, mycards, theircards)
    local ok, err = self:canTrade()
    if not ok then
        return false, err
    end
    if otherplayer ~= nil then
        local ok, err = CatanSchema.Player:isValid(otherplayer)
        if not ok then
            return false, err
        end
        if otherplayer == self.player then
            return false, "cannot trade with itself"
        end
        if mycards ~= nil then
            local ok, err = CatanSchema.ResourceCardHistogram:isValid(mycards)
            if not ok then
                return false, err
            end
            local m = TableUtils:sum(mycards)
            if m < 1 then
                return false, "player cannot give away cards"
            end
            local ok, err = self:_canGiveResources(self.player, mycards)
            if not ok then
                return false, err
            end
            if theircards ~= nil then
                local ok, err = CatanSchema.ResourceCardHistogram:isValid(theircards)
                if not ok then
                    return false, err
                end
                local n = TableUtils:sum(theircards)
                if n < 1 then
                    return false, "player cannot give away cards"
                end
                for res in pairs(mycards) do
                    local n = theircards[res] or 0
                    if n > 0 then
                        return false, "cannot trade cards of same type"
                    end
                end
                local ok, err = self:_canGiveResources(otherplayer, theircards)
                if not ok then
                    return false, err
                end
            end
        end
    end
    return true
end

----
-- Check whether the current player can trade resource cards with harbor.
--
-- @tparam[opt] table mycards histogram of resource cards from the current player
-- @tparam[optchain] table theircards histogram of resource cards to receive
-- @treturn boolean
-- @treturn ?string error message (in case of failure)
function Game:canTradeWithHarbor (mycards, theircards)
    local ok, err = self:canTrade()
    if not ok then
        return false, err
    end
    if mycards ~= nil then
        local ok, err = CatanSchema.ResourceCardHistogram:isValid(mycards)
        if not ok then
            return false, err
        end
        local ok, err = self:_canGiveResources(self.player, mycards)
        if not ok then
            return false, err
        end
        local m, err = self:getMaritimeTradeReturn(self.player, mycards)
        if not m then
            return false, err
        end
        if theircards ~= nil then
            local ok, err = CatanSchema.ResourceCardHistogram:isValid(theircards)
            if not ok then
                return false, err
            end
            if TableUtils:sum(theircards) ~= m then
                return false, "bad sum of theircards"
            end
            local ok, err = self:_doesBankHaveResources(theircards)
            if not ok then
                return false, err
            end
        end
    end
    return true
end

Game.ROAD_COST = {lumber=1, brick=1}

----
-- Check whether the current player can build a road on a given edge.
--
-- @tparam[opt] {q=number,r=number,e='NE'|'NW'|'W'} edge
-- @treturn boolean
-- @treturn string|boolean error message (in case of failure) or
-- whether player would use credit gained from playing an
-- Year of Plenty card (in case of success)
function Game:canBuildRoad (edge)
    local ok, err = self:_isPhase"playingTurns"
    if not ok then
        return false, err
    end
    local usingCredit = self:_hasEnoughRoadCredit()
    if not usingCredit then
        local ok, err = self:_wereDiceRolled(true)
        if not ok then
            return false, err
        end
        local ok, err = self:_canGiveResources(self.player, self.ROAD_COST)
        if not ok then
            return false, err
        end
    end
    local ok, err = self:_hasEnoughRoads()
    if not ok then
        return false, err
    end
    if edge ~= nil then
        local ok, err = CatanSchema.Edge:isValid(edge)
        if not ok then
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
    return true, usingCredit
end

Game.SETTLEMENT_COST = {lumber=1, brick=1, wool=1, grain=1}

----
-- Check whether the current player can build a settlement on a given vertex.
--
-- @tparam[opt] {q=number,r=number,v='N'|'S'} vertex
-- @treturn boolean
-- @treturn ?string error message (in case of failure)
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
    local ok, err = self:_canGiveResources(self.player, self.SETTLEMENT_COST)
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

Game.CITY_COST = {grain=2, ore=3}

----
-- Check whether the current player can build a city on a given vertex.
--
-- @tparam[opt] {q=number,r=number,v='N'|'S'} vertex
-- @treturn boolean
-- @treturn ?string error message (in case of failure)
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
    local ok, err = self:_canGiveResources(self.player, self.CITY_COST)
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

Game.DEVCARD_COST = {wool=1, ore=1, grain=1}

----
-- Check whether the current player can buy a development card.
--
-- @treturn boolean
-- @treturn ?string error message (in case of failure)
function Game:canBuyDevelopmentCard ()
    local ok, err = self:_isPhase"playingTurns"
    if not ok then
        return false, err
    end
    local ok, err = self:_wereDiceRolled(true)
    if not ok then
        return false, err
    end
    local ok, err = self:_hasEnoughDevelopmentCards()
    if not ok then
        return false, err
    end
    local ok, err = self:_canGiveResources(self.player, self.DEVCARD_COST)
    if not ok then
        return false, err
    end
    return true
end

----
-- Check whether a development card can be played.
--
-- @tparam table devcard
-- @treturn boolean
-- @treturn ?string error message (in case of failure)
function Game:isCardPlayable (devcard)
    if devcard.roundBought == self.round then
        return false, "cannot buy and play a development card in the same round"
    end
    if devcard.roundPlayed ~= nil then
        return false, "cannot play a development card twice"
    end
    return true
end

----
-- Check whether the current player can play a Knight card.
--
-- @treturn boolean
-- @treturn ?string error message (in case of failure)
function Game:canPlayKnightCard ()
    return self:getPlayableCardOfKind "knight"
end

----
-- Check whether the current player can play a Road Building card.
--
-- @treturn boolean
-- @treturn ?string error message (in case of failure)
function Game:canPlayRoadBuildingCard ()
    return self:getPlayableCardOfKind "roadbuilding"
end

----
-- Check whether the current player can play an Year of Plenty card.
-- The current player can receive up to 2 resource cards from the bank,
-- depending on its availability.
--
-- @tparam[opt] table rescards histogram of resource cards to be received
-- @treturn boolean
-- @treturn ?string error message (in case of failure)
function Game:canPlayYearOfPlentyCard (rescards)
    local devcard, err = self:getPlayableCardOfKind "yearofplenty"
    if not devcard then
        return false, err
    end
    if rescards ~= nil then
        local valid, err = CatanSchema.ResourceCardHistogram:isValid(rescards)
        if not valid then
            return false, err
        end
        local numCards = TableUtils:sum(rescards)
        if numCards > 2 then
            return false, "cannot claim more than 2 resource cards"
        end
        local ok, err = self:_doesBankHaveResources(rescards)
        if not ok then
            return false, err
        end
    end
    return devcard
end

----
-- Check whether the current player can play a Monopoly card.
--
-- @tparam[opt] string res the resource to be monopolized
-- @treturn boolean
-- @treturn ?string error message (in case of failure)
function Game:canPlayMonopolyCard (res)
    local devcard, err = self:getPlayableCardOfKind "monopoly"
    if not devcard then
        return false, err
    end
    if res ~= nil then
        local valid, err = CatanSchema.ResourceCard:isValid(res)
        if not valid then
            return false, err
        end
    end
    return devcard
end

----
-- Check whether the current player can end their turn.
--
-- @treturn boolean
-- @treturn ?string error message (in case of failure)
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

-------------------------------------------------------------------------
-- Actions
--
-- Actions are methods that necessarily change the state of the game.
--
-- @section actions
-------------------------------------------------------------------------

---
-- Place a settlement in a given vertex.
-- This is exclusive to the set-up phase.
--
-- @tparam {q=number,r=number,v='N'|'S'} vertex
-- @treturn catan.logic.HexProduction any resources gained from settlement placement
function Game:placeInitialSettlement (vertex)
    assert(vertex, "missing vertex")
    assert(self:canPlaceInitialSettlement(vertex))

    self.buildmap:set(vertex, {
        kind = "settlement",
        player = self.player,
    })

    local hexprod = HexProduction:new()

    if self.round == 2 then
        for _, touchingFace in ipairs(Grid:touches(Grid:unpack(vertex))) do
            local touchingHex = self.hexmap:get(touchingFace)
            if touchingHex ~= nil then
                local res = self:_resourceProducedByHex(touchingHex)
                if res ~= nil then
                    hexprod:add(self.player, res, 1)
                end
            end
        end
    end

    self:_produce(hexprod)

    self.phase = "placingInitialRoad"

    return hexprod
end

---
-- Place a road in a given edge.
-- This is exclusive to the set-up phase.
--
-- @tparam {q=number,r=number,e='NE'|'NW'|'W'} edge
function Game:placeInitialRoad (edge)
    assert(edge, "missing edge")
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

---
-- Roll dice for resource production.
-- The possible values for each die are: 1, 2, 3, 4, 5, and 6.
--
-- @tparam {number,number} dice
-- @treturn catan.logic.HexProduction any resources gained from dice roll
function Game:roll (dice)
    assert(dice, "missing dice")
    assert(self:canRoll(dice))

    local diceSum = 0
    for _, die in ipairs(dice) do
        diceSum = diceSum + die
    end

    local hexprod = HexProduction:new()

    self.numbermap:iter(function (q, r, number)
        if number == diceSum then
            local face = Grid:face(q, r)
            if CatanSchema.Face:eq(self.robber, face) then
                return false -- skip to next iteration
            end
            local hex = assert(self.hexmap:get(face))
            local res = self:_resourceProducedByHex(hex)
            if res ~= nil then
                for _, corner in ipairs(Grid:corners(q, r)) do
                    local building = self.buildmap:get(corner)
                    if building ~= nil then
                        local numCards = self:_numResourcesProducedByBuilding(building.kind)
                        hexprod:add(building.player, res, numCards)
                    end
                end
            end
        end
    end)

    self:_produce(hexprod)

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

    return hexprod
end

---
-- Discard half of a player's resource cards.
--
-- @tparam string player
-- @tparam table rescards histogram of resource cards from player
function Game:discard (player, rescards)
    assert(player, "missing player")
    assert(rescards, "missing rescards")
    assert(self:canDiscard(player, rescards))

    for res, discardCount in pairs(rescards) do
        self:_giveResourceToBank(player, res, discardCount)
    end

    self.lastdiscard[player] = self.round

    if self:_nobodyCanDiscard() then
        self.phase = "movingRobber"
    end
end

---
-- Move the robber to another face.
--
-- @tparam {q=number,r=number} face
-- @treturn ?string robber victim (or `nil` if there isn't a single victim)
-- @treturn ?string resource stolen from victim (or `nil` if there is no victim, or victim has no resources)
function Game:moveRobber (face)
    assert(face, "missing face")
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

---
-- Choose victim of the robber.
--
-- @tparam string player the victim
-- @treturn ?string resource stolen from victim (or `nil` if victim has no resources)
function Game:chooseVictim (player)
    assert(player, "missing player")
    assert(self:canChooseVictim(player))

    local res = self:_stealRandomResCardFrom(player)

    self.phase = "playingTurns"

    return res
end

---
-- Trade resource cards with a given player.
--
-- @tparam string otherplayer the player to trade with
-- @tparam table mycards the resource cards offered by the current player
-- @tparam table theircards the resource cards from the other player
function Game:tradeWithPlayer (otherplayer, mycards, theircards)
    assert(otherplayer, "missing otherplayer")
    assert(mycards, "missing mycards")
    assert(theircards, "missing theircards")
    assert(self:canTradeWithPlayer(otherplayer, mycards, theircards))

    self:_giveResourcesToPlayer(self.player, otherplayer, mycards)
    self:_giveResourcesToPlayer(otherplayer, self.player, theircards)
end

---
-- Trade resource cards in the harbor.
--
-- @tparam table mycards the resource cards offered by the current player
-- @tparam table theircards the resource cards from the harbor
function Game:tradeWithHarbor (mycards, theircards)
    assert(mycards, "missing mycards")
    assert(theircards, "missing theircards")
    assert(self:canTradeWithHarbor(mycards, theircards))

    self:_giveResourcesToBank(self.player, mycards)
    self:_giveResourcesFromBank(self.player, theircards)
end

---
-- Build a road on a given edge.
--
-- @tparam {q=number,r=number,e='NE'|'NW'|'W'} edge
function Game:buildRoad (edge)
    assert(edge, "missing edge")
    local _, usingCredit = assert(self:canBuildRoad(edge))

    if usingCredit then
        self:_addToRoadCredit(self.player, -1)
    else
        self:_giveResourcesToBank(self.player, self.ROAD_COST)
    end

    self.roadmap:set(edge, self.player)

    self:_updateLongestRoadHolder()
    self:_checkForWinner()
end

---
-- Build a settlement on a given vertex.
--
-- @tparam {q=number,r=number,v='N'|'S'} vertex
function Game:buildSettlement (vertex)
    assert(vertex, "missing vertex")
    assert(self:canBuildSettlement(vertex))

    self:_giveResourcesToBank(self.player, self.SETTLEMENT_COST)

    self.buildmap:set(vertex, {
        kind = "settlement",
        player = self.player,
    })

    self:_updateLongestRoadHolder()
    self:_checkForWinner()
end

---
-- Build a city on a given vertex.
--
-- @tparam {q=number,r=number,v='N'|'S'} vertex
function Game:buildCity (vertex)
    assert(vertex, "missing vertex")
    assert(self:canBuildCity(vertex))

    self:_giveResourcesToBank(self.player, self.CITY_COST)

    self.buildmap:set(vertex, {
        kind = "city",
        player = self.player,
    })

    self:_updateLongestRoadHolder()
    self:_checkForWinner()
end

---
-- Buy a development card.
--
-- @treturn string the kind of the newly-bought development card
function Game:buyDevelopmentCard ()
    assert(self:canBuyDevelopmentCard())

    self:_giveResourcesToBank(self.player, self.DEVCARD_COST)

    local kind = table.remove(self.drawpile)

    table.insert(self.devcards[self.player], {
        kind = kind,
        roundBought = self.round,
    })

    self:_checkForWinner()

    return kind
end

---
-- Play a Knight card.
function Game:playKnightCard ()
    local devcard = assert(self:canPlayKnightCard())

    self:_markCardAsPlayed(devcard)

    self.phase = "movingRobber"

    self:_updateLargestArmyHolder()
    self:_checkForWinner()
end

---
-- Play a Road Building card.
function Game:playRoadBuildingCard ()
    local devcard = assert(self:canPlayRoadBuildingCard())

    self:_markCardAsPlayed(devcard)

    self:_addToRoadCredit(self.player, 2)
end

---
-- Play an Year of Plenty card.
-- The current player can receive up to 2 resource cards from the bank,
-- depending on its availability.
--
-- @tparam table rescards histogram of resource cards to be received
function Game:playYearOfPlentyCard (rescards)
    assert(rescards, "missing rescards")
    local devcard = assert(self:canPlayYearOfPlentyCard(rescards))

    self:_markCardAsPlayed(devcard)

    self:_giveResourcesFromBank(self.player, rescards)
end

---
-- Play a Monopoly card.
--
-- @tparam string res the resource to be monopolized
function Game:playMonopolyCard (res)
    assert(res, "missing res")
    local devcard = assert(self:canPlayMonopolyCard(res))

    self:_markCardAsPlayed(devcard)

    for _, player in ipairs(self.players) do
        if player ~= self.player then
            local n = self.rescards[player][res] or 0
            self:_giveResourceToPlayer(player, self.player, res, n)
        end
    end
end

----
-- End the current player's turn.
function Game:endTurn ()
    assert(self:canEndTurn())

    local i = self:_getCurrentPlayerIndex()

    if i == #self.players then
        self.round = self.round + 1
    end

    self.roadcredit[self.player] = nil
    self.player = self:_getPlayerAfterIndex(i)
    self.dice = nil

    self:_checkForWinner()
end

--------------------------------
-- Internals
-- @section internals
--------------------------------

function Game:_nobodyCanDiscard ()
    for _, player in ipairs(self.players) do
        if self:canDiscard(player) then
            return false
        end
    end
    return true
end

Game.NUM_RESOURCES_FROM_BUILDING_KIND = {
    settlement = 1,
    city = 2,
}

function Game:_numResourcesProducedByBuilding (kind)
    return self.NUM_RESOURCES_FROM_BUILDING_KIND[kind]
end

Game.RESOURCE_FROM_HEX = {
    hills = 'brick',
    forest = 'lumber',
    mountains = 'ore',
    fields = 'grain',
    pasture = 'wool',
}

function Game:_resourceProducedByHex (hex)
    return self.RESOURCE_FROM_HEX[hex]
end

function Game:_checkForWinner ()
    local winner = self:getWinner()
    if winner ~= nil then
        self.phase = 'end'
        self.winner = winner
    end
end

function Game:_markCardAsPlayed (devcard)
    assert(devcard.roundPlayed == nil)
    devcard.roundPlayed = self.round
end

function Game:_getLongestRoadWithEdge (player, edge)
    local visitedEdges = EdgeMap:new()

    local function canVisit (pair)
        if visitedEdges:get(pair.edge) then
            return false
        end
        if self.roadmap:get(pair.edge) ~= player then
            return false
        end
        local building = self.buildmap:get(pair.vertex)
        if building and building.player ~= player then
            return false
        end
        return true
    end

    local function visit (vertex)
        local maxLength = 0
        for _, pair in ipairs(Grid:adjacentEdgeVertexPairs(Grid:unpack(vertex))) do
            if canVisit(pair) then
                visitedEdges:set(pair.edge, true)
                local length = 1 + visit(pair.vertex)
                if length > maxLength then
                    maxLength = length
                end
                visitedEdges:set(pair.edge, false)
            end
        end
        return maxLength
    end

    local maxLength = 0
    for _, endpoint in ipairs(Grid:endpoints(Grid:unpack(edge))) do
        local building = self.buildmap:get(endpoint)
        if building == nil or building.player == player then
            local length = visit(endpoint)
            if length > maxLength then
                maxLength = length
            end
        end
    end
    return maxLength
end

function Game:_getNewTitleHolder (values, currentHolder, minValueForTitle)
    local maxValue, tiedCount, tiedPlayers = TableUtils:podium(values)

    assert(maxValue ~= nil)

    if currentHolder == nil then
        if tiedCount == 1 and maxValue >= minValueForTitle then
            return next(tiedPlayers)
        end
    else
        if maxValue >= minValueForTitle then
            if tiedPlayers[currentHolder] == nil then
                if tiedCount == 1 then
                    return next(tiedPlayers)
                else
                    return nil
                end
            end
        else
            return nil
        end
    end

    return currentHolder
end

function Game:_updateLongestRoadHolder ()
    local lengths = {}

    for _, player in ipairs(self.players) do
        lengths[player] = self:getLongestRoadLength(player)
    end

    self.longestroad = self:_getNewTitleHolder(lengths, self.longestroad, 5)
end

function Game:_updateLargestArmyHolder ()
    local armies = {}

    for _, player in ipairs(self.players) do
        armies[player] = self:getArmySize(player)
    end

    self.largestarmy = self:_getNewTitleHolder(armies, self.largestarmy, 3)
end

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
        return false, "player doesn't have enough roads"
    end
    return true
end

function Game:_addToRoadCredit (player, n)
    local credit = self.roadcredit[player] or 0
    local newCredit = credit + n
    assert(newCredit >= 0)
    self.roadcredit[player] = newCredit
end

function Game:_hasEnoughRoadCredit ()
    local credit = self.roadcredit[self.player] or 0
    return credit >= 1
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

function Game:_hasEnoughDevelopmentCards ()
    if #self.drawpile == 0 then
        return false, "drawpile is empty"
    end
    return true
end

function Game:_stealRandomResCardFrom (victim)
    local res = self:_choosePlayerResCardAtRandom(victim)
    assert(res ~= nil, "victim must have at least one card")
    self:_giveResourceToPlayer(victim, self.player, res, 1)
    return res
end

function Game:_doesBankHaveResources (rescards)
    for res, n in pairs(rescards) do
        local ok, err = self:_doesBankHaveResource(res, n)
        if not ok then
            return false, err
        end
    end
    return true
end

function Game:_doesBankHaveResource (res, n)
    local supply = self.bank[res] or 0
    if supply < n then
        return false, "not enough supply of " .. res
    end
    return true
end

function Game:_canGiveResources (player, rescards)
    for res, n in pairs(rescards) do
        local ok, err = self:_canGiveResource(player, res, n)
        if not ok then
            return false, err
        end
    end
    return true
end

function Game:_canGiveResource (player, res, n)
    local count = self.rescards[player][res] or 0
    if not (n >= 0 and n <= count) then
        return false, "not enough " .. res
    end
    return true
end

function Game:_addToResourceCount (player, rescard, count)
    local countBefore = self.rescards[player][rescard] or 0
    local countAfter = countBefore + count
    assert(countAfter >= 0, "num of rescards cannot be negative")
    self.rescards[player][rescard] = countAfter
end

function Game:_produce (hexprod)
   self:_limitHexProductionByResCardSupply(hexprod)
   self:_applyHexProduction(hexprod)
end

function Game:_limitHexProductionByResCardSupply (hexprod)
    local totalResProduction = {}
    local resProducers = {}

    -- Count total number of resource produced per type
    -- and populate the resProducers with the producers of each type
    hexprod:iter(function (player, res, n)
        totalResProduction[res] = (totalResProduction[res] or 0) + n
        if n >= 1 then
            if resProducers[res] == nil then
                resProducers[res] = {}
            end
            resProducers[res][player] = true
        end
    end)

    -- For each resource, check if the total amount produced surpasses
    -- the total supply in the bank. If so, check if only one player
    -- produced it. If only one player produced it, cap the produced
    -- amount by the supply. Otherwise, don't produce such resource.
    for res, totalAmount in pairs(totalResProduction) do
        local supply = self.bank[res]
        local players = resProducers[res]
        if totalAmount > supply then
            local nplayers = TableUtils:numOfPairs(players)
            assert(nplayers >= 1)
            if nplayers == 1 then
                local player = assert(next(players))
                hexprod:set(player, res, supply)
            else
                for player in pairs(players) do
                    hexprod:set(player, res, nil)
                end
            end
        end
    end
end

function Game:_applyHexProduction (hexprod)
    hexprod:iter(function (player, res, n)
        self:_giveResourceFromBank(player, res, n)
    end)
end

function Game:_giveResourceFromBank (player, res, n)
    local supply = self.bank[res]
    assert(supply >= n)
    self:_addToResourceCount(player, res, n)
    self.bank[res] = supply - n
end

function Game:_giveResourcesFromBank (player, rescards)
    for res, n in pairs(rescards) do
        self:_giveResourceFromBank(player, res, n)
    end
end

function Game:_giveResourceToBank (player, res, n)
    assert(n >= 0)
    self:_addToResourceCount(player, res, -n)
    self.bank[res] = self.bank[res] + n
end

function Game:_giveResourcesToBank (player, rescards)
    for res, n in pairs(rescards) do
        self:_giveResourceToBank(player, res, n)
    end
end

function Game:_giveResourceToPlayer (from, to, res, n)
    assert(n >= 0)
    self:_addToResourceCount(from, res, -n)
    self:_addToResourceCount(to, res, n)
end

function Game:_giveResourcesToPlayer (from, to, rescards)
    for res, n in pairs(rescards) do
        self:_giveResourceToPlayer(from, to, res, n)
    end
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
