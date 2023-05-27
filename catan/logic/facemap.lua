local Class = require "util.class"

local Grid = require "catan.logic.grid"
local CatanSchema = require "catan.logic.schema"

local Face = CatanSchema.Face

local FaceMap = Class "FaceMap"

function FaceMap:new ()
    return self:__new{}
end

function FaceMap:get (face)
    assert(Face:isValid(face))
    local q, r = Grid:unpack(face)
    local mapq = rawget(self, q)
    if mapq then
        return rawget(mapq, r)
    end
end

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

function FaceMap:iter (f)
    for q, mapq in pairs(self) do
        for r, mapqr in pairs(mapq) do
            local ret = f(q, r, mapqr)
            if ret then return ret end
        end
    end
end

return FaceMap
