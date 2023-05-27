local Class = require "util.class"

local Grid = require "catan.logic.grid"
local CatanSchema = require "catan.logic.schema"

local Edge = CatanSchema.Edge

local EdgeMap = Class "EdgeMap"

function EdgeMap:new ()
    return self:__new{}
end

function EdgeMap:get (edge)
    assert(Edge:isValid(edge))
    return self:_get(Grid:unpack(edge))
end

-- TODO: deprecate
function EdgeMap:_get (q, r, e)
    local mapq = rawget(self, q)
    if mapq then
        local mapqr = rawget(mapq, r)
        if mapqr then
            return rawget(mapqr, e)
        end
    end
end

function EdgeMap:set (edge, o)
    assert(Edge:isValid(edge))
    self:_set(o, Grid:unpack(edge))
end

-- TODO: deprecate
function EdgeMap:_set (o, q, r, e)
    local mapq = rawget(self, q)
    if mapq == nil then
        mapq = {}
        rawset(self, q, mapq)
    end
    local mapqr = rawget(mapq, r)
    if mapqr == nil then
        mapqr = {}
        rawset(mapq, r, mapqr)
    end
    rawset(mapqr, e, o)
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

return EdgeMap
