---
-- A data structure for resource production of hexes.
--
-- @classmod catan.logic.HexProduction

local Class = require "util.class"

local CatanSchema = require "catan.logic.schema"

local Player = CatanSchema.Player
local ResourceCard = CatanSchema.ResourceCard

local HexProduction = Class "HexProduction"

---
-- Create an empty hex production.
-- @treturn catan.logic.HexProduction
function HexProduction:new ()
    return self:__new{}
end

---
-- Get the number of resources produced by player.
-- @tparam string player the player
-- @tparam string res the kind of resource
-- @treturn number the number of resources
-- @usage
-- local hexprod = HexProduction:new()
-- local player = "red"
-- local res = "grain"
-- print(hexprod:get(player, res)) --> 0
-- hexprod:add(player, res, 3)
-- print(hexprod:get(player, res)) --> 3
function HexProduction:get (player, res)
    assert(Player:isValid(player))
    assert(ResourceCard:isValid(res))
    local playerprod = rawget(self, player)
    if playerprod then
        return rawget(playerprod, res) or 0
    else
        return 0
    end
end

---
-- Set the number of resources produced by player.
-- @tparam string player the player
-- @tparam string res the kind of resource
-- @tparam ?number n the number of resources
-- @usage
-- local hexprod = HexProduction:new()
-- local player = "red"
-- local res = "grain"
-- print(hexprod:get(player, res)) --> 0
-- hexprod:add(player, res, 3)
-- print(hexprod:get(player, res)) --> 3
-- hexprod:set(player, res, 1)
-- print(hexprod:get(player, res)) --> 1
-- hexprod:set(player, res, nil)
-- print(hexprod:get(player, res)) --> 0
function HexProduction:set (player, res, n)
    assert(Player:isValid(player))
    assert(ResourceCard:isValid(res))
    local playerprod = rawget(self, player)
    if playerprod == nil then
        playerprod = {}
        rawset(self, player, playerprod)
    end
    assert(n == nil or n >= 0, "resource count cannot be negative")
    rawset(playerprod, res, n)
end


---
-- Add `n` to the number of resources produced by player.
-- You can also decrease such number by passing a negative value for `n`.
-- @tparam string player the player
-- @tparam string res the kind of resource
-- @tparam number n the number of resources to add
-- @usage
-- local hexprod = HexProduction:new()
-- local player = "red"
-- local res = "grain"
-- print(hexprod:get(player, res)) --> 0
-- hexprod:add(player, res, 3)
-- print(hexprod:get(player, res)) --> 3
function HexProduction:add (player, res, n)
    local m = self:get(player, res)
    self:set(player, res, m + n)
end

---
-- Iterate through all the associations.
-- @tparam function f the iterator that will be called
-- for each association, receiving as parameter the
-- values `player`, `res` and `n`. Be mindful that `n`
-- can have the value zero, and that the iteration is not
-- exaustive for all player-resource combinations.
-- If this function returns a value different
-- from `nil` or `false`, iteration is interrupted and this
-- value is returned immediately.
-- @usage
-- local haystack = HexProduction:new()
-- -- ...
-- local key = haystack:iter(function (player, res, n)
--   if n == 5 then
--     return {player = player, res = res}
--   end
-- end)
-- if key ~= nil then
--   print(haystack:get(key.player, key.res)) --> 5
-- end
function HexProduction:iter (f)
    for player, playerprod in pairs(self) do
        for res, n in pairs(playerprod) do
            local ret = f(player, res, n)
            if ret then return ret end
        end
    end
end

return HexProduction
