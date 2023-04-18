require "util.safe"

local TableUtils = require "util.table"

for N = 0, 10 do
    local t1 = {}
    local t2 = {}
    for i = 1, N do
        local x = math.random()
        t1[i] = x
        t2[i] = x
    end
    table.sort(t1)
    TableUtils:shuffleInPlace(t2)
    table.sort(t2)
    assert(#t1 == #t2)
    for i = 1, N do
        assert(t1[i] == t2[i])
    end
end
