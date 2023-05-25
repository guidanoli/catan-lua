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
                local ret = f(q, r, e, mapqre)
                if ret then return ret end
            end
        end
    end
end

function EdgeMap:contain (map1, map2)
    local ret = true
    self:iter(map2, function (q, r, e, o)
        if self:_get(map1, q, r, e) ~= o then
            ret = false
            return true -- quit iteration
        end
    end)
    return ret
end

function EdgeMap:equal (map1, map2)
    return self:contain(map1, map2) and
           self:contain(map2, map1)
end

return EdgeMap
