---
-- An associative array with hexagonal grid edges as keys.
--
-- @classmod catan.logic.EdgeMap

local Class = require "util.class"

local Grid = require "catan.logic.grid"
local CatanSchema = require "catan.logic.schema"

local Edge = CatanSchema.Edge

local EdgeMap = Class "EdgeMap"

---
-- Create an empty edge map.
-- @treturn catan.logic.EdgeMap an empty edge map
function EdgeMap:new ()
    return self:__new{}
end

---
-- Get the object associated with `edge`.
-- @tparam {q=number,r=number,e='NW'|'W'|'NE'} edge
-- @return the object associated with `edge`
-- @usage
-- local edgemap = EdgeMap:new()
-- local edge = {q=1, r=0, e='W'}
-- print(edgemap:get(edge)) --> nil
-- edgemap:set(edge, 'hah')
-- print(edgemap:get(edge)) --> hah
function EdgeMap:get (edge)
    assert(Edge:isValid(edge))
    local q, r, e = Grid:unpack(edge)
    local mapq = rawget(self, q)
    if mapq then
        local mapqr = rawget(mapq, r)
        if mapqr then
            return rawget(mapqr, e)
        end
    end
end

---
-- Associate `edge` with some object.
-- You can also remove any association with `edge`
-- by passing the value `nil` as parameter `o`.
-- @tparam {q=number,r=number,e='NW'|'W'|'NE'} edge
-- @param o the object to associate `edge` with
-- @usage
-- local edgemap = EdgeMap:new()
-- local edge = {q=1, r=0, e='W'}
-- print(edgemap:get(edge)) --> nil
-- edgemap:set(edge, 'hah')
-- print(edgemap:get(edge)) --> hah
function EdgeMap:set (edge, o)
    assert(Edge:isValid(edge))
    local q, r, e = Grid:unpack(edge)
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

---
-- Iterate through all the associations.
-- @tparam function f the iterator that will be called
-- for each association, receiving as parameter the
-- values `q`, `r`, `e` and `o`, where `q`, `r` and `e` uniquely
-- identify the edge and `o` is the value associated with
-- such edge. If this function returns a value different
-- from `nil` or `false`, iteration is interrupted and this
-- value is returned immediately.
-- @usage
-- local haystack = EdgeMap:new()
-- -- ...
-- local edge = haystack:iter(function (q, r, e, o)
--   if o == 'needle' then
--     return {q = q, r = r, e = e}
--   end
-- end)
-- if edge ~= nil then
--   print(haystack:get(edge)) --> needle
-- end
function EdgeMap:iter (f)
    for q, mapq in pairs(self) do
        for r, mapqr in pairs(mapq) do
            for e, o in pairs(mapqr) do
                local ret = f(q, r, e, o)
                if ret then return ret end
            end
        end
    end
end

return EdgeMap
