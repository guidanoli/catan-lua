local EdgeMap = {}

function EdgeMap:get(map, edge)
    local q, r, e = edge.q, edge.r, edge.e
    local mapq = map[q]
    if mapq then
        local mapqr = mapq[r]
        if mapqr then
            return mapqr[e]
        end
    end
end

function EdgeMap:set(map, edge, o)
    local q, r, e = edge.q, edge.r, edge.e
    local mapq = map[q]
    if mapq == nil then
        mapq = {}
        map[q] = mapq
    end
    local mapqr = mapq[r]
    if mapqr == nil then
        mapqr = {}
        mapq[r] = mapqr
    end
    mapqr[e] = o
end

function EdgeMap:iter(map, f)
    for q, mapq in pairs(map) do
        for r, mapqr in pairs(mapq) do
            for e, mapqre in pairs(mapqr) do
                if f(q, r, e, mapqre) then
                    return
                end
            end
        end
    end
end

return EdgeMap
