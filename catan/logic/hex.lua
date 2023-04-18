local Hex = {}

function Hex:arrayFrom (terrain)
    local t = {}
    for kind, count in pairs(terrain) do
        for i = 1, count do
            table.insert(t, kind)
        end
    end
    return t
end

return Hex
