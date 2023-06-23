require "util.safe"

local TableUtils = require "util.table"

local MAX = 10000

-- sum

assert(TableUtils:sum{} == 0)
assert(TableUtils:sum{123} == 123)
assert(TableUtils:sum{a=123} == 123)

for N = 0, 10 do
    local t = {}

    local sum = 0

    for i = 1, N do
        -- We use integers because addition on
        -- floating-point numbers is not associative
        local x = math.random(MAX)
        sum = sum + x
        t[i] = x
    end
    assert(TableUtils:sum(t) == sum)

    TableUtils:shuffleInPlace(t)
    assert(TableUtils:sum(t) == sum)

    local k = 'key' .. math.random(MAX)
    local v = math.random(MAX)
    rawset(t, k, v)
    assert(TableUtils:sum(t) == sum + v)
end

-- filter

local function iseven (v) return v % 2 == 0 end

assert(TableUtils:deepEqual(TableUtils:filter({}, iseven), {}))
assert(TableUtils:deepEqual(TableUtils:filter({a=123}, iseven), {}))
assert(TableUtils:deepEqual(TableUtils:filter({5, 2, 7, 77, 66}, iseven), {2, 66}))

for N = 0, 10 do
    local t = {}
    local expected = {}

    for i = 1, N do
        local x = math.random(MAX)
        if iseven(x) then
            table.insert(expected, x)
        end
        t[i] = x
    end

    local obtained = TableUtils:filter(t, iseven)

    assert(TableUtils:deepEqual(expected, obtained))
end

-- map

local function double (v) return 2 * v end

assert(TableUtils:deepEqual(TableUtils:map({}, double), {}))
assert(TableUtils:deepEqual(TableUtils:map({123}, double), {246}))
assert(TableUtils:deepEqual(TableUtils:map({123, a=7777}, double), {246}))

for N = 0, 10 do
    local t = {}
    local expected = {}

    for i = 1, N do
        local x = math.random(MAX)
        t[i] = x
        expected[i] = double(x)
    end

    local obtained = TableUtils:map(t, double)

    assert(TableUtils:deepEqual(expected, obtained))
end

-- sample

assert(TableUtils:sample{} == nil)
assert(TableUtils:sample{a=123} == nil)
assert(TableUtils:sample{123} == 123)

for N = 1, 10 do
    local t = {}

    for i = 1, N do
        t[i] = math.random(MAX)
    end

    for M = 1, N do
        local x, i = TableUtils:sample(t)
        assert(x ~= nil and t[i] == x)
    end
end

-- shuffleInPlace

local function shuffle (t)
    TableUtils:shuffleInPlace(t)
    return t
end

assert(TableUtils:deepEqual(shuffle{}, {}))
assert(TableUtils:deepEqual(shuffle{a=123}, {a=123}))
assert(TableUtils:deepEqual(shuffle{123}, {123}))

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

-- deepEqual

do
    local function ok(f)
        assert(TableUtils:deepEqual(f(), f()))
    end

    ok(function () return {} end)
    ok(function () return {a=123} end)
    ok(function () return {1, 2, 3} end)
    ok(function () return {1, 2, 3, foo=345, bar=567} end)
    ok(function () return {{}, {}, {{}, {}}} end)

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
