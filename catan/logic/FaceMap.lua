---
-- An associative array with hexagonal grid faces as keys.
--
-- @classmod catan.logic.FaceMap

local Class = require "util.class"

local Grid = require "catan.logic.grid"
local CatanSchema = require "catan.logic.schema"

local Face = CatanSchema.Face

local FaceMap = Class "FaceMap"

---
-- Create an empty face map.
-- @treturn catan.logic.FaceMap an empty face map
function FaceMap:new ()
    return self:__new{}
end

---
-- Get the object associated with `face`.
-- @tparam {q=number,r=number} face
-- @return the object associated with `face`
-- @usage
-- local facemap = FaceMap:new()
-- local face = {q=1, r=0}
-- print(facemap:get(face)) --> nil
-- print(facemap:set(face, 'hah'))
-- print(facemap:get(face)) --> hah
function FaceMap:get (face)
    assert(Face:isValid(face))
    local q, r = Grid:unpack(face)
    local mapq = rawget(self, q)
    if mapq then
        return rawget(mapq, r)
    end
end

---
-- Associate `face` with some object.
-- You can also remove any association with `face`
-- by passing the value `nil` as parameter `o`.
-- @tparam {q=number,r=number} face
-- @param o the object to associate `face` with
-- @usage
-- local facemap = FaceMap:new()
-- local face = {q=1, r=0}
-- print(facemap:get(face)) --> nil
-- facemap:set(face, 'hah')
-- print(facemap:get(face)) --> hah
function FaceMap:set (face, o)
    assert(Face:isValid(face))
    local q, r = Grid:unpack(face)
    local mapq = rawget(self, q)
    if mapq == nil then
        mapq = {}
        rawset(self, q, mapq)
    end
    rawset(mapq, r, o)
end

---
-- Iterate through all the associations.
-- @tparam function f the iterator that will be called
-- for each association, receiving as parameter the
-- values `q`, `r` and `o`, where `q` and `r` uniquely
-- identify the face and `o` is the value associated with
-- such face. If this function returns a value different
-- from `nil` or `false`, iteration is interrupted and this
-- value is returned immediately.
-- @usage
-- local haystack = FaceMap:new()
-- -- ...
-- local face = haystack:iter(function (q, r, o)
--   if o == 'needle' then
--     return {q = q, r = r}
--   end
-- end)
-- if face ~= nil then
--   print(haystack:get(face)) --> needle
-- end
function FaceMap:iter (f)
    for q, mapq in pairs(self) do
        for r, o in pairs(mapq) do
            local ret = f(q, r, o)
            if ret then return ret end
        end
    end
end

return FaceMap
