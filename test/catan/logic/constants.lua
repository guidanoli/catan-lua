local constants = require "catan.logic.constants"
local FaceMap = require "catan.logic.FaceMap"
local VertexMap = require "catan.logic.VertexMap"

do
    -- Check for duplicate coordinates
    local map = FaceMap:new()
    for _, face in pairs(constants.terrainFaces) do
        assert(map:get(face) == nil)
        map:set(face, true)
    end
end

do
    -- Check if #hexes = #terrainFaces
    local sum = 0
    for kind, count in pairs(constants.terrain) do
        assert(count >= 0)
        sum = sum + count
    end
    assert(sum == #constants.terrainFaces)
end

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

do
    -- Check for duplicate coordinates
    local map = VertexMap:new()
    for _, h in pairs(constants.harbors) do
        assert(map:get(h.vertex) == nil)
        map:set(h.vertex, true)
    end
end

do
    -- Check for duplicate players
    local set = {}
    for _, p in pairs(constants.players) do
        assert(set[p] == nil)
        set[p] = true
    end
end

