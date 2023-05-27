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

do
    local function ok(t)
        assert(TableUtils:deepEqual(t, t))
    end

    ok({})
    ok({a=123})
    ok({1, 2, 3})
    ok({1, 2, 3, foo=345, bar=567})
    ok({{}, {}, {{}, {}}})

    local function fail(ta, tb)
        assert(not TableUtils:deepEqual(ta, tb))
        assert(not TableUtils:deepEqual(tb, ta))
    end

    fail({}, {123})
    fail({}, {a=123})
    fail({}, {1, 2, 3, b=123, c=456})
    fail({}, {{}})
    fail({foo={}}, {bar={}})
    fail({{'foo'}}, {{'bar'}})
end
