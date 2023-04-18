local VertexMap = {}

function VertexMap:get(map, vertex)
    local face = vertex.face
    local kind = vertex.kind
    local q, r = face.q, face.r
    return map[q][r][kind]
end

function VertexMap:set(map, vertex, o)
    local face = vertex.face
    local kind = vertex.kind
    local q, r = face.q, face.r
    if map[q] == nil then map[q] = {} end
    if map[q][r] == nil then map[q][r] = {} end
    map[q][r][kind] = o
end

return VertexMap
