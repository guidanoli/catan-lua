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
    "choosingVictimBeforeRoll.lua",
    "choosingVictim.lua",
    "lastDiscard.lua",
    "movingRobberBeforeRoll.lua",
    "movingRobber.lua",
    "roadCredit.lua",
    "end.lua",
}

local function loadFrom (stateFile)
    local path = {"test", "catan", "states", stateFile}
    local pathStr = table.concat(path, platform.PATH_SEPARATOR)
    local fp = io.open(pathStr)
    local str = fp:read"*a"
    fp:close()

    return assert(Game:deserialize(str))
end

local function mutate (game)
    game.player = "foobar"
end

for _, stateFile in ipairs(stateFiles) do
    local game1 = loadFrom(stateFile)

    game1:validate()

    local str1 = game1:serialize()
    local game2 = assert(Game:deserialize(str1))

    assert(TableUtils:deepEqual(game1, game2, true))

    mutate(game2)

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
