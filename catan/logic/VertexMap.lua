---
-- An associative array with hexagonal grid vertices as keys.
--
-- @classmod catan.logic.VertexMap

local Class = require "util.class"

local Grid = require "catan.logic.grid"
local CatanSchema = require "catan.logic.schema"

local Vertex = CatanSchema.Vertex

local VertexMap = Class "VertexMap"

---
-- Create an empty vertex map.
-- @treturn catan.logic.VertexMap an empty vertex map
function VertexMap:new ()
    return self:__new{}
end

---
-- Get the object associated with `vertex`.
-- @tparam {q=number,r=number,v='N'|'S'} vertex
-- @return the object associated with `vertex`
-- @usage
-- local vertexmap = VertexMap:new()
-- local vertex = {q=1, r=0, v='N'}
-- print(vertexmap:get(vertex)) --> nil
-- print(vertexmap:set(vertex, 'hah'))
-- print(vertexmap:get(vertex)) --> hah
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

---
-- Associate `vertex` with some object.
-- You can also remove any association with `vertex`
-- by passing the value `nil` as parameter `o`.
-- @tparam {q=number,r=number,v='N'|'S'} vertex
-- @param o the object to associate `vertex` with
-- @usage
-- local vertexmap = VertexMap:new()
-- local vertex = {q=1, r=0, v='N'}
-- print(vertexmap:get(vertex)) --> nil
-- vertexmap:set(vertex, 'hah')
-- print(vertexmap:get(vertex)) --> hah
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

---
-- Iterate through all the associations.
-- @tparam function f the iterator that will be called
-- for each association, receiving as parameter the
-- values `q`, `r`, `v` and `o`, where `q`, `r` and `v` uniquely
-- identify the vertex and `o` is the value associated with
-- such vertex. If this function returns a value different
-- from `nil` or `false`, iteration is interrupted and this
-- value is returned immediately.
-- @usage
-- local haystack = VertexMap:new()
-- -- ...
-- local vertex = haystack:iter(function (q, r, v, o)
--   if o == 'needle' then
--     return {q = q, r = r, v = v}
--   end
-- end)
-- if vertex ~= nil then
--   print(haystack:get(vertex)) --> needle
-- end
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
