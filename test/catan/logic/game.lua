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

-- canRoll

do
    local game = games.roll
    assert(not game:canRoll"foo")
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
