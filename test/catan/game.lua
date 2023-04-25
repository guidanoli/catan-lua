require "util.safe"
local serpent = require "serpent"

local Game = require "catan.logic.game"
local GameSchema = require "catan.logic.schema"

local function validate(g)
    local ok, err = pcall(function() GameSchema:validate(g) end)
    if not ok then
        print(serpent.block(g))
        error(err)
    end
end

validate(Game:new())
validate(Game:new{'red', 'blue', 'white'})
validate(Game:new{'red', 'blue', 'white', 'yellow'})
