require "util.compat"

local Grid = require "catan.logic.grid"

local VertexMap = {}

function VertexMap:get(map, vertex)
    local q, r, v = Grid:unpack(vertex)
    local mapq = map[q]
    if mapq then
        local mapqr = mapq[r]
        if mapqr then
            return mapqr[v]
        end
    end
end

function VertexMap:set(map, vertex, o)
    local q, r, v = Grid:unpack(vertex)
    assert(type(q) == 'number')
    assert(math.type(q) == 'integer')
    assert(type(r) == 'number')
    assert(math.type(r) == 'integer')
    assert(v == 'N' or v == 'S')
    local mapq = map[q]
    if mapq == nil then
        mapq = {}
        map[q] = mapq
    end
    local mapqr = mapq[r]
    if mapqr == nil then
        mapqr = {}
        mapq[r] = mapqr
    end
    mapqr[v] = o
end

function VertexMap:iter(map, f)
    for q, mapq in pairs(map) do
        for r, mapqr in pairs(mapq) do
            for v, mapqrv in pairs(mapqr) do
                if f(q, r, v, mapqrv) then
                    return
                end
            end
        end
    end
end

return VertexMap
