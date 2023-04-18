local FaceMap = {}

function FaceMap:get(map, face)
    local q, r = face.q, face.r
    return map[q][r]
end

function FaceMap:set(map, face, o)
    local q, r = face.q, face.r
    if map[q] == nil then map[q] = {} end
    map[q][r] = o
end

function FaceMap:iter(map, co)
    for q in pairs(map) do
        for r in pairs(map[q]) do
            if f(q, r, map[q][r]) then
                return
            end
        end
    end
end

return FaceMap
