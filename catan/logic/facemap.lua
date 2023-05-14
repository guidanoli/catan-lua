local Grid = require "catan.logic.grid"
local CatanSchema = require "catan.logic.schema"

local Face = CatanSchema.Face

local FaceMap = {}

function FaceMap:get (map, face)
    assert(Face:isValid(face))
    return self:_get(map, Grid:unpack(face))
end

function FaceMap:_get (map, q, r)
    local mapq = map[q]
    if mapq then
        return mapq[r]
    end
end

function FaceMap:set (map, face, o)
    assert(Face:isValid(face))
    self:_set(map, o, Grid:unpack(face))
end

function FaceMap:_set (map, o, q, r)
    local mapq = map[q]
    if mapq == nil then
        mapq = {}
        map[q] = mapq
    end
    mapq[r] = o
end

function FaceMap:iter (map, f)
    for q, mapq in pairs(map) do
        for r, mapqr in pairs(mapq) do
            ret = f(q, r, mapqr)
            if ret then return ret end
        end
    end
end

return FaceMap
