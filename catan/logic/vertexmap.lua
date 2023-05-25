local Grid = require "catan.logic.grid"
local CatanSchema = require "catan.logic.schema"

local Vertex = CatanSchema.Vertex

local VertexMap = {}

function VertexMap:get (map, vertex)
    assert(Vertex:isValid(vertex))
    return self:_get(map, Grid:unpack(vertex))
end

function VertexMap:_get (map, q, r, v)
    local mapq = map[q]
    if mapq then
        local mapqr = mapq[r]
        if mapqr then
            return mapqr[v]
        end
    end
end

function VertexMap:set (map, vertex, o)
    assert(Vertex:isValid(vertex))
    self:_set(map, o, Grid:unpack(vertex))
end

function VertexMap:_set (map, o, q, r, v)
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

function VertexMap:iter (map, f)
    for q, mapq in pairs(map) do
        for r, mapqr in pairs(mapq) do
            for v, mapqrv in pairs(mapqr) do
                local ret = f(q, r, v, mapqrv)
                if ret then return ret end
            end
        end
    end
end

function VertexMap:contain (map1, map2)
    local ret = true
    self:iter(map2, function (q, r, v, x)
        if self:_get(map1, q, r, v) ~= x then
            ret = false
            return true -- quit iteration
        end
    end)
    return ret
end

function VertexMap:equal (map1, map2)
    return self:contain(map1, map2) and
           self:contain(map2, map1)
end

return VertexMap
