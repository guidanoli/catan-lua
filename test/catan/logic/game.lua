require "util.safe"
local serpent = require "serpent"

local platform = require "util.platform"
local TableUtils = require "util.table"
local schema = require "util.schema"

local Game = require "catan.logic.game"
local Grid = require "catan.logic.grid"

Game:new():validate()
Game:new{'red', 'blue', 'white'}:validate()
Game:new{'red', 'blue', 'white', 'yellow'}:validate()

local function expect (patt, ...)
    local ok, err = pcall(...)
    assert(not ok)
    assert(type(err) == 'string', "error not string")
    assert(err:find(patt), "pattern doesn't match")
end

expect('too few players', function() Game:new{} end)
expect('too few players', function() Game:new{'red'} end)
expect('too few players', function() Game:new{'red', 'blue'} end)
expect('invalid player', function() Game:new{'red', 'blue', 'xyz'} end)
expect('repeated player', function() Game:new{'red', 'blue', 'red'} end)

local stateFiles = {
    "choosingVictimBeforeRoll",
    "choosingVictim",
    "lastDiscard",
    "movingRobberBeforeRoll",
    "movingRobber",
    "roadCredit",
    "endPhase",
    "roll",
    "discarding",
    "roadToSea",
    "turn",
    "noRoads",
    "noSettlements",
    "noCities",
    "devcards",
    "breakLongestRoad",
    "breakLongestRoadLeadsToTie",
    "breakLongestRoadLeadsToTieBelowMin",
    "limitedHexProduction",
    "emptyDrawpile",
}

local games = {}

local function loadFrom (stateFile)
    local path = {"test", "catan", "states", stateFile}
    local pathStr = table.concat(path, platform.PATH_SEPARATOR)
    local fp = assert(io.open(pathStr))
    local str = fp:read"*a"
    assert(fp:close())

    return assert(Game:deserialize(str))
end

for _, stateFile in ipairs(stateFiles) do
    games[stateFile] = loadFrom(stateFile .. '.lua')
end

for stateFile, game1 in pairs(games) do
    game1:validate()

    local str1 = game1:serialize()
    local game2 = assert(Game:deserialize(str1))

    assert(TableUtils:deepEqual(game1, game2, true))

    game2.player = "foobar"

    local str2 = game2:serialize()
    assert(not Game:deserialize(str2))
end

assert(not Game:deserialize"return {")
assert(not Game:deserialize"error()")
assert(not Game:deserialize"return 123")
assert(not Game:deserialize"return {}")

-- placeInitialSettlement

do
    local game = Game:new()
    assert(not game:canPlaceInitialSettlement"foo")
    assert(not game:canPlaceInitialSettlement{q=777, r=777, v='N'})
end

-- placeInitialRoad

do
    local game = Game:new()
    game:placeInitialSettlement{q=0, r=0, v='N'}
    assert(not game:canPlaceInitialRoad"foo")
    assert(not game:canPlaceInitialRoad{q=777, r=777, e='W'})
end

do
    local game = games.roadToSea
    assert(not game:canPlaceInitialRoad{q=2, r=-3, e='W'})
end

-- roll

do
    local game = games.roll
    assert(not game:canRoll"foo")
end

do
    local game = games.limitedHexProduction
    local hexprod = game:roll{5, 6}

    -- one player, receives all remaining resources
    assert(hexprod:get("red", "brick") == 1)

    -- two players, receive nothing
    assert(hexprod:get("red", "grain") == 0)
    assert(hexprod:get("blue", "grain") == 0)
end

-- discard

do
    local game = games.discarding
    assert(not game:canDiscard"foo")
    for _, player in ipairs(game.players) do
        assert(not game:canDiscard(player, "foo"))
        if game:canDiscard(player) then
            assert(not game:canDiscard(player, {grain=777}))
            assert(not game:canDiscard(player, {}))
        end
    end
end

-- moveRobber

do
    local game = games.movingRobber
    assert(not game:canMoveRobber"foo")
    assert(not game:canMoveRobber{q=777, r=777})
end

-- chooseVictim

do
    local game = games.choosingVictim
    assert(not game:canChooseVictim"foo")
end

-- tradeWithPlayer

do
    local game = games.turn
    assert(not game:canTradeWithPlayer"foo")
    assert(not game:canTradeWithPlayer("blue", "foo"))
    assert(not game:canTradeWithPlayer("blue", {}, "foo"))
    assert(not game:canTradeWithPlayer("blue", {brick=777}, {grain=1}))
    assert(not game:canTradeWithPlayer("blue", {brick=1}, {grain=777}))
end

-- tradeWithHarbor

do
    local game = games.turn
    assert(not game:canTradeWithHarbor"foo")
    assert(not game:canTradeWithHarbor({}, "foo"))
    assert(not game:canTradeWithHarbor({wool=777}, {}))
    assert(not game:canTradeWithHarbor({wool=4}, {}))
    assert(not game:canTradeWithHarbor({wool=5}, {}))
    assert(not game:canTradeWithHarbor({wool=4}, {brick=1}))
end

-- buildRoad

do
    local game = games.noRoads
    assert(not game:canBuildRoad())
end

do
    local game = games.turn
    assert(not game:canBuildRoad"foo")
end

-- buildSettlement

do
    local game = games.noSettlements
    assert(not game:canBuildSettlement())
end

do
    local game = games.turn
    assert(not game:canBuildSettlement"foo")
end

-- buildCity

do
    local game = games.noCities
    assert(not game:canBuildCity())
end

do
    local game = games.turn
    assert(not game:canBuildCity"foo")
end

-- getPlayableCardOfKind

do
    local game = games.devcards
    assert(not game:getPlayableCardOfKind "victorypoint")
end

-- getNumberOfDevelopmentCards

do
    local game = games.devcards
    assert(game:getNumberOfDevelopmentCards"red" == 8)
end

-- playYearOfPlentyCard

do
    local game = games.devcards
    assert(not game:canPlayYearOfPlentyCard"foo")
    assert(not game:canPlayYearOfPlentyCard{brick=3})
    assert(not game:canPlayYearOfPlentyCard{brick=2})
end

-- playMonopolyCard

do
    local game = games.devcards
    assert(not game:canPlayMonopolyCard"foo")
end

-- getWinner

do
    local game = games.breakLongestRoad
    game:buildSettlement{q=-1, r=1, v='S'}
end

-- _getNewTitleHolder

do
    local game = games.breakLongestRoadLeadsToTie
    game:buildSettlement{q=-1, r=1, v='S'}
end

do
    local game = games.breakLongestRoadLeadsToTieBelowMin
    game:buildSettlement{q=-1, r=1, v='S'}
end

-- buyDevelopmentCard

do
    local game = games.emptyDrawpile
    assert(not game:canBuyDevelopmentCard())
end
