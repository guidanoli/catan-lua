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
    local coords = {}
    for _, face in pairs(Default.terrainFaces) do
        if coords[face.q] == nil then
            coords[face.q] = {[face.r] = true}
        else
            assert(coords[face.q][face.r] == nil)
        end
    end
end

assert(#Default.terrainFaces == 19)

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
        assert(type(kind) == 'string')
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

Default.players = {
    'red',
    'blue',
    'yellow',
    'white',
}

return Default
