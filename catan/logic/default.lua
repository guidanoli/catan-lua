local FaceMap = require "catan.logic.facemap"
local VertexMap = require "catan.logic.vertexmap"

local Default = {}

-- In the same order as the number placement
Default.terrainFaces = {
    {q = +0, r = -2},
    {q = -1, r = -1},
    {q = -2, r = +0},
    {q = -2, r = +1},
    {q = -2, r = +2},
    {q = -1, r = +2},
    {q = +0, r = +2},
    {q = +1, r = +1},
    {q = +2, r = +0},
    {q = +2, r = -1},
    {q = +2, r = -2},
    {q = +1, r = -2},
    {q = +0, r = -1},
    {q = -1, r = +0},
    {q = -1, r = +1},
    {q = +0, r = +1},
    {q = +1, r = +0},
    {q = +1, r = -1},
    {q = +0, r = +0},
}

do
    -- Check for duplicate coordinates
    local map = {}
    for _, face in pairs(Default.terrainFaces) do
        assert(FaceMap:get(map, face) == nil)
        FaceMap:set(map, face, true)
    end
end

Default.terrain = {
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
    for kind, count in pairs(Default.terrain) do
        assert(count >= 0)
        sum = sum + count
    end
    assert(sum == #Default.terrainFaces)
end

Default.numbers = {
    5, 2, 6, 3, 8, 10,
    9, 12, 11, 4, 8, 10,
    9, 4, 5, 6, 3, 11,
}

do
    -- Check if #numbers = #non-desert-hexes
    local sum = 0
    for kind, count in pairs(Default.terrain) do
        if kind ~= 'desert' then
            sum = sum + count
        end
    end
    assert(sum == #Default.numbers)
end

Default.harbors = {
    {q = +0, r = -3, vk = 'S', hk = 'generic'},
    {q = +0, r = -2, vk = 'N', hk = 'generic'},
    {q = +1, r = -2, vk = 'N', hk = 'grain'},
    {q = +2, r = -3, vk = 'S', hk = 'grain'},
    {q = +2, r = -1, vk = 'N', hk = 'ore'},
    {q = +3, r = -2, vk = 'S', hk = 'ore'},
    {q = +3, r = -1, vk = 'S', hk = 'generic'},
    {q = +2, r = +1, vk = 'N', hk = 'generic'},
    {q = +1, r = +2, vk = 'N', hk = 'wool'},
    {q = +1, r = +1, vk = 'S', hk = 'wool'},
    {q = -1, r = +3, vk = 'N', hk = 'generic'},
    {q = -1, r = +2, vk = 'S', hk = 'generic'},
    {q = -2, r = +2, vk = 'S', hk = 'generic'},
    {q = -3, r = +3, vk = 'N', hk = 'generic'},
    {q = -3, r = +2, vk = 'N', hk = 'brick'},
    {q = -2, r = +0, vk = 'S', hk = 'brick'},
    {q = -2, r = +0, vk = 'N', hk = 'lumber'},
    {q = -1, r = -2, vk = 'S', hk = 'lumber'},
}

do
    -- Check for duplicate coordinates
    local map = {}
    for _, h in pairs(Default.harbors) do
        local face = {q = h.q, r = h.r}
        local vertex = {kind = h.vk, face = face}
        assert(VertexMap:get(map, vertex) == nil)
        VertexMap:set(map, vertex, true)
    end
end

Default.players = {
    'red',
    'blue',
    'yellow',
    'white',
}

do
    -- Check for duplicate players
    local set = {}
    for _, p in pairs(Default.players) do
        assert(set[p] == nil)
        set[p] = true
    end
end

Default.devcards = {
    knight = 14,
    roadbuilding = 2,
    yearofplenty = 2,
    monopoly = 2,
    victorypoint = 5,
}

Default.rescards = {
    brick = 19,
    lumber = 19,
    ore = 19,
    grain = 19,
    wool = 19,
}

return Default
