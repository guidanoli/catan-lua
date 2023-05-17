local CatanSchema = require "catan.logic.schema"

local Roll = {}

function Roll:add (roll, player, res, numCards)
    assert(CatanSchema.Player:isValid(player))
    assert(CatanSchema.ResourceCard:isValid(res))
    self:_add(roll, player, res, numCards)
end

function Roll:_add (roll, player, res, numCards)
    local rollp = roll[player]
    if rollp == nil then
        rollp = {}
        roll[player] = rollp
    end
    local rollpr = rollp[res] or 0
    rollp[res] = rollpr + numCards
end

function Roll:get (roll, player, res)
    local rollp = roll[player]
    if rollp then
        return rollp[res]
    end
end

function Roll:iter (roll, f)
    for player, rollp in pairs(roll) do
        for res, numCards in pairs(rollp) do
            local ret = f(player, res, numCards)
            if ret then return ret end
        end
    end
end

return Roll
