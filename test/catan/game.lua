require "util.safe"
local serpent = require "serpent"

local Game = require "catan.logic.game"
local GameSchema = require "catan.logic.schema"

local g = Game:new()
local ok, err = pcall(function() GameSchema:validate(g) end)
if not ok then
    print(serpent.block(g))
    error(err)
end
