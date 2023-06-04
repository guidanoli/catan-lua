local FaceMap = require "catan.logic.FaceMap"
local VertexMap = require "catan.logic.VertexMap"

local constants = {}

-- In the same order as the number placement
constants.terrainFaces = {
    {q = 0, r = -2},
    {q = -1, r = -1},
    {q = -2, r = 0},
    {q = -2, r = 1},
    {q = -2, r = 2},
    {q = -1, r = 2},
    {q = 0, r = 2},
    {q = 1, r = 1},
    {q = 2, r = 0},
    {q = 2, r = -1},
    {q = 2, r = -2},
    {q = 1, r = -2},
    {q = 0, r = -1},
    {q = -1, r = 0},
    {q = -1, r = 1},
    {q = 0, r = 1},
    {q = 1, r = 0},
    {q = 1, r = -1},
    {q = 0, r = 0},
}

do
    -- Check for duplicate coordinates
    local map = FaceMap:new()
    for _, face in pairs(constants.terrainFaces) do
        assert(map:get(face) == nil)
        map:set(face, true)
    end
end

constants.terrain = {
    hills = 3,
    forest = 4,
    mountains = 3,
    fields = 4,
    pasture = 4,
    desert = 1,
}

do
    -- Check if #hexes = #terrainFaces
    local sum = 0
    for kind, count in pairs(constants.terrain) do
        assert(count >= 0)
        sum = sum + count
    end
    assert(sum == #constants.terrainFaces)
end

constants.numbers = {
    5, 2, 6, 3, 8, 10,
    9, 12, 11, 4, 8, 10,
    9, 4, 5, 6, 3, 11,
}

do
    -- Check if #numbers = #non-desert-hexes
    local sum = 0
    for kind, count in pairs(constants.terrain) do
        if kind ~= 'desert' then
            sum = sum + count
        end
    end
    assert(sum == #constants.numbers)
end

constants.harbors = {
    {q = 0, r = -3, v = 'S', kind = 'generic'},
    {q = 0, r = -2, v = 'N', kind = 'generic'},
    {q = 1, r = -2, v = 'N', kind = 'grain'},
    {q = 2, r = -3, v = 'S', kind = 'grain'},
    {q = 2, r = -1, v = 'N', kind = 'ore'},
    {q = 3, r = -2, v = 'S', kind = 'ore'},
    {q = 3, r = -1, v = 'S', kind = 'generic'},
    {q = 2, r = 1, v = 'N', kind = 'generic'},
    {q = 1, r = 2, v = 'N', kind = 'wool'},
    {q = 1, r = 1, v = 'S', kind = 'wool'},
    {q = -1, r = 3, v = 'N', kind = 'generic'},
    {q = -1, r = 2, v = 'S', kind = 'generic'},
    {q = -2, r = 2, v = 'S', kind = 'generic'},
    {q = -3, r = 3, v = 'N', kind = 'generic'},
    {q = -3, r = 2, v = 'N', kind = 'brick'},
    {q = -2, r = 0, v = 'S', kind = 'brick'},
    {q = -2, r = 0, v = 'N', kind = 'lumber'},
    {q = -1, r = -2, v = 'S', kind = 'lumber'},
}

do
    -- Check for duplicate coordinates
    local map = VertexMap:new()
    for _, h in pairs(constants.harbors) do
        local vertex = {q = h.q, r = h.r, v = h.v}
        assert(map:get(vertex) == nil)
        map:set(vertex, true)
    end
end

constants.players = {
    'red',
    'blue',
    'yellow',
    'white',
}

do
    -- Check for duplicate players
    local set = {}
    for _, p in pairs(constants.players) do
        assert(set[p] == nil)
        set[p] = true
    end
end

constants.devcards = {
    knight = 14,
    roadbuilding = 2,
    yearofplenty = 2,
    monopoly = 2,
    victorypoint = 5,
}

constants.rescards = {
    brick = 19,
    lumber = 19,
    ore = 19,
    grain = 19,
    wool = 19,
}

constants.roads = 15

constants.settlements = 5

return constants
