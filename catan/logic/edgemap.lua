require "util.compat"

local Grid = require "catan.logic.grid"

local EdgeMap = {}

function EdgeMap:get(map, edge)
    local q, r, e = Grid:unpack(edge)
    local mapq = map[q]
    if mapq then
        local mapqr = mapq[r]
        if mapqr then
            return mapqr[e]
        end
    end
end

function EdgeMap:set(map, edge, o)
    local q, r, e = Grid:unpack(edge)
    assert(type(q) == 'number')
    assert(math.type(q) == 'integer')
    assert(type(r) == 'number')
    assert(math.type(r) == 'integer')
    assert(e == 'NE' or e == 'NW' or e == 'W')
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
    mapqr[e] = o
end

function EdgeMap:iter(map, f)
    for q, mapq in pairs(map) do
        for r, mapqr in pairs(mapq) do
            for e, mapqre in pairs(mapqr) do
                ret = f(q, r, e, mapqre)
                if ret then return ret end
            end
        end
    end
end

return EdgeMap
