local Default = {}

-- In the same order as the number placement
Default.faces = {
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
    local coords = {}
    for _, face in pairs(Default.faces) do
        if coords[face.q] == nil then
            coords[face.q] = {[face.r] = true}
        else
            assert(coords[face.q][face.r] == nil)
        end
    end
end

assert(#Default.faces == 19)

Default.terrain = {
    hills = 3,
    forest = 4,
    mountains = 3,
    fields = 4,
    pasture = 4,
    desert = 1,
}

do
    -- Check if #hexes = #faces
    local sum = 0
    for kind, count in pairs(Default.terrain) do
        assert(type(kind) == 'string')
        assert(count >= 0)
        sum = sum + count
    end
    assert(sum == #Default.faces)
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

return Default
