local Grid = require "catan.logic.grid"
local CatanSchema = require "catan.logic.schema"

local Edge = CatanSchema.Edge

local EdgeMap = {}

function EdgeMap:get (map, edge)
    assert(Edge:isValid(edge))
    return self:_get(map, Grid:unpack(edge))
end

function EdgeMap:_get (map, q, r, e)
    local mapq = map[q]
    if mapq then
        local mapqr = mapq[r]
        if mapqr then
            return mapqr[e]
        end
    end
end

function EdgeMap:set (map, edge, o)
    assert(Edge:isValid(edge))
    self:_set(map, o, Grid:unpack(edge))
end

function EdgeMap:_set (map, o, q, r, e)
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

function EdgeMap:iter (map, f)
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
