require "util.safe"
local serpent = require "serpent"

local platform = require "util.platform"
local TableUtils = require "util.table"
local schema = require "util.schema"

local Game = require "catan.logic.game"
local Catan = require "catan.logic.schema"

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
}

for _, stateFile in ipairs(stateFiles) do
    local path = {"test", "catan", "states", stateFile}
    local pathStr = table.concat(path, platform.PATH_SEPARATOR)
    local fp = io.open(pathStr)
    local str1 = fp:read"*a"
    fp:close()

    local game1 = assert(Game:deserialize(str1))

    game1:validate()

    local str2 = game1:serialize()
    local game2 = assert(Game:deserialize(str2))

    assert(TableUtils:deepEqual(game1, game2, true))
end
