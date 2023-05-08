require "util.safe"
local serpent = require "serpent"

local schema = require "util.schema"

local Game = require "catan.logic.game"
local Catan = require "catan.logic.schema"

local function validate(g)
    local ok, err = pcall(function()
        Catan.GameState:validate(g)
    end)
    if not ok then
        print(serpent.block(g))
        error(err)
    end
end

validate(Game:new())
validate(Game:new{'red', 'blue', 'white'})
validate(Game:new{'red', 'blue', 'white', 'yellow'})

local function expect (patt, ...)
    local ok, err = pcall(...)
    assert(not ok)
    if type(err) ~= 'string' then
        error(string.format('expected error object to be string, not "%s"', type(err)))
    elseif not string.find(err, patt) then
        error(string.format('error "%s" doesn\'t match pattern "%s"', err, patt))
    end
end

expect('too few players', function() Game:new{} end)
expect('too few players', function() Game:new{'red'} end)
expect('too few players', function() Game:new{'red', 'blue'} end)
expect('invalid player', function() Game:new{'red', 'blue', 'xyz'} end)
expect('repeated player', function() Game:new{'red', 'blue', 'red'} end)
