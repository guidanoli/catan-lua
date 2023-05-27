local Class = require "util.class"

local Grid = require "catan.logic.grid"
local CatanSchema = require "catan.logic.schema"

local Edge = CatanSchema.Edge

local EdgeMap = Class "EdgeMap"

function EdgeMap:new ()
    return EdgeMap:__new{}
end

function EdgeMap:get (edge)
    assert(Edge:isValid(edge))
    return self:_get(Grid:unpack(edge))
end

function EdgeMap:_get (q, r, e)
    local mapq = self[q]
    if mapq then
        local mapqr = mapq[r]
        if mapqr then
            return mapqr[e]
        end
    end
end

function EdgeMap:set (edge, o)
    assert(Edge:isValid(edge))
    self:_set(o, Grid:unpack(edge))
end

function EdgeMap:_set (o, q, r, e)
    local mapq = self[q]
    if mapq == nil then
        mapq = {}
        self[q] = mapq
    end
    local mapqr = mapq[r]
    if mapqr == nil then
        mapqr = {}
        mapq[r] = mapqr
    end
    mapqr[e] = o
end

function EdgeMap:iter (f)
    for q, mapq in pairs(self) do
        for r, mapqr in pairs(mapq) do
            for e, mapqre in pairs(mapqr) do
                local ret = f(q, r, e, mapqre)
                if ret then return ret end
            end
        end
    end
end

function EdgeMap:contain (other)
    local ret = true
    other:iter(function (q, r, e, o)
        if self:_get(q, r, e) ~= o then
            ret = false
            return true -- quit iteration
        end
    end)
    return ret
end

function EdgeMap:equal (other)
    return self:contain(other) and
           other:contain(self)
end

return EdgeMap
