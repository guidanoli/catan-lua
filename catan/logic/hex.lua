local TableUtils = require "util.table"

local Hex = {}

Hex.kindCount = {
    hills = 3,
    forest = 4,
    mountains = 3,
    fields = 4,
    pasture = 4,
    desert = 1,
}

function Hex:generateHexes ()
    local t = {}
    for kind, count in pairs(self.kindCount) do
        for i = 1, count do
            table.insert(t, {kind = kind})
        end
    end
    return t
end

return Hex
