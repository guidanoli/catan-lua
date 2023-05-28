local Class = require "util.class"

local Grid = require "catan.logic.grid"
local CatanSchema = require "catan.logic.schema"

local Vertex = CatanSchema.Vertex

local VertexMap = Class "VertexMap"

function VertexMap:new ()
    return self:__new{}
end

function VertexMap:get (vertex)
    assert(Vertex:isValid(vertex))
    local q, r, v = Grid:unpack(vertex)
    local mapq = rawget(self, q)
    if mapq then
        local mapqr = rawget(mapq, r)
        if mapqr then
            return rawget(mapqr, v)
        end
    end
end

function VertexMap:set (vertex, o)
    assert(Vertex:isValid(vertex))
    local q, r, v = Grid:unpack(vertex)
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
    rawset(mapqr, v, o)
end

function VertexMap:iter (f)
    for q, mapq in pairs(self) do
        for r, mapqr in pairs(mapq) do
            for v, o in pairs(mapqr) do
                local ret = f(q, r, v, o)
                if ret then return ret end
            end
        end
    end
end

return VertexMap
