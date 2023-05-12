require "util.compat"

local Grid = require "catan.logic.grid"

local FaceMap = {}

function FaceMap:get(map, face)
    local q, r = Grid:unpack(face)
    local mapq = map[q]
    if mapq then
        return mapq[r]
    end
end

function FaceMap:set(map, face, o)
    local q, r = Grid:unpack(face)
    assert(type(q) == 'number')
    assert(math.type(q) == 'integer')
    assert(type(r) == 'number')
    assert(math.type(r) == 'integer')
    local mapq = map[q]
    if mapq == nil then
        mapq = {}
        map[q] = mapq
    end
    mapq[r] = o
end

function FaceMap:iter(map, f)
    for q, mapq in pairs(map) do
        for r, mapqr in pairs(mapq) do
            if f(q, r, mapqr) then
                return
            end
        end
    end
end

return FaceMap
