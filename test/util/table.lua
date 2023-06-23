require "util.safe"

local TableUtils = require "util.table"

local function assertEq (ta, tb)
    assert(TableUtils:deepEqual(ta, tb))
end

local function iterationCount(...)
    local n = 0
    for _ in ... do
        n = n + 1
    end
    return n
end

assert(iterationCount(ipairs{}) == 0)
assert(iterationCount(ipairs{123}) == 1)
assert(iterationCount(ipairs{123, 456}) == 2)

local function assertNoIteration (...)
    assert(iterationCount(...) == 0)
end

local MAX = 10000

-- sum

assert(TableUtils:sum{} == 0)
assert(TableUtils:sum{123} == 123)
assert(TableUtils:sum{a=123} == 123)

for N = 0, 10 do
    local t = {}
    local tcopy = {}

    local sum = 0

    for i = 1, N do
        -- We use integers because addition on
        -- floating-point numbers is not associative
        local x = math.random(MAX)
        sum = sum + x
        t[i] = x
        tcopy[i] = x
    end
    assert(TableUtils:sum(t) == sum)
    assertEq(t, tcopy)

    TableUtils:shuffleInPlace(t)
    assert(TableUtils:sum(t) == sum)

    local k = 'key' .. math.random(MAX)
    local v = math.random(MAX)
    rawset(t, k, v)
    assert(TableUtils:sum(t) == sum + v)
end

-- filter

local function iseven (v) return v % 2 == 0 end

assertEq(TableUtils:filter({}, iseven), {})
assertEq(TableUtils:filter({a=123}, iseven), {})
assertEq(TableUtils:filter({5, 2, 7, 77, 66}, iseven), {2, 66})

for N = 0, 10 do
    local t = {}
    local tcopy = {}
    local expected = {}

    for i = 1, N do
        local x = math.random(MAX)
        if iseven(x) then
            table.insert(expected, x)
        end
        t[i] = x
        tcopy[i] = x
    end

    local obtained = TableUtils:filter(t, iseven)
    assertEq(t, tcopy)

    assertEq(expected, obtained)
end

-- map

local function double (v) return 2 * v end

assertEq(TableUtils:map({}, double), {})
assertEq(TableUtils:map({123}, double), {246})
assertEq(TableUtils:map({123, a=7777}, double), {246})

for N = 0, 10 do
    local t = {}
    local tcopy = {}
    local expected = {}

    for i = 1, N do
        local x = math.random(MAX)
        t[i] = x
        tcopy[i] = x
        expected[i] = double(x)
    end

    local obtained = TableUtils:map(t, double)
    assertEq(t, tcopy)

    assertEq(expected, obtained)
end

-- sample

assert(TableUtils:sample{} == nil)
assert(TableUtils:sample{a=123} == nil)
assert(TableUtils:sample{123} == 123)

for N = 1, 10 do
    local t = {}
    local tcopy = {}

    for i = 1, N do
        local x = math.random(MAX)
        t[i] = x
        tcopy[i] = x
    end

    for M = 1, N do
        local x, i = TableUtils:sample(t)
        assertEq(t, tcopy)
        assert(x ~= nil and t[i] == x)
    end
end

-- uniqueSamples

assertEq(TableUtils:uniqueSamples({}, 0), {})
assertEq(TableUtils:uniqueSamples({a=123}, 0), {})
assertEq(TableUtils:uniqueSamples({123, a=123}, 1), {123})

for N = 0, 10 do
    local t = {}
    local tcopy = {}

    for i = 1, N do
        local x = math.random(20)
        t[i] = x
        tcopy[i] = x
    end

    for M = 0, N do
        local samples = TableUtils:uniqueSamples(t, M)
        assertEq(t, tcopy)
        assert(#samples == M)
        local used = {}
        for i = 1, M do
            local found = false
            for j = 1, N do
                if samples[i] == t[j] and not used[j] then
                    found = true
                    used[j] = true
                    break
                end
            end
            assert(found)
        end
    end
end

-- histogram

assertEq(TableUtils:histogram{}, {})
assertEq(TableUtils:histogram{a=123}, {})
assertEq(TableUtils:histogram{123}, {[123]=1})
assertEq(TableUtils:histogram{123, 123}, {[123]=2})
assertEq(TableUtils:histogram{123, 123, 456}, {[123]=2, [456]=1})

for N = 1, 20 do
    local t = {}

    for i = 1, N do
        t[i] = math.random(10)
    end

    local h = TableUtils:histogram(t)

    for v, n in pairs(h) do
        local m = 0
        for i, w in ipairs(t) do
            if v == w then
                m = m + 1
            end
        end
        assert(m == n)
    end
end

-- sortedKeys

assertEq(TableUtils:sortedKeys{}, {})
assertEq(TableUtils:sortedKeys{44, 1, -24}, {1, 2, 3})
assertEq(TableUtils:sortedKeys{b=34, c=10, a=42}, {'a', 'b', 'c'})
assertEq(TableUtils:sortedKeys{77, 44, b=34, a=42}, {1, 2, 'a', 'b'})

for N = 1, 10 do
    local t = {}

    -- add number-indexed entries
    for i = 1, N do
        t[i] = math.random(10)
    end

    -- add string-indexed entries
    for i = 1, N do
        local k = 'key' .. math.random(10)
        t[k] = math.random(10)
    end

    local keys = TableUtils:sortedKeys(t)

    -- check that every key in keys exists in t
    for i, k in ipairs(keys) do
        assert(t[k] ~= nil)
    end

    -- check that every key in t exists in keys
    for k1 in pairs(t) do
        local found = false
        for i, k2 in ipairs(keys) do
            if k1 == k2 then
                assert(not found)
                found = true
            end
        end
        assert(found)
    end

    -- check that keys is ordered
    for i = 1, #keys - 1 do
        local a, b = keys[i], keys[i+1]
        if type(a) == type(b) then
            assert(a < b)
        else
            assert(type(a) < type(b))
        end
    end
end

-- sortedIter

TableUtils:sortedIter({}, function() error() end)

do
    local called = false
    TableUtils:sortedIter({a=123}, function(k, v)
        assert(not called)
        assert(k == 'a')
        assert(v == 123)
        called = true
    end)
end

do
    local calledCount = 0
    TableUtils:sortedIter({777, a=123}, function(k, v)
        if calledCount == 0 then
            assert(k == 1)
            assert(v == 777)
        else
            assert(calledCount == 1)
            assert(k == 'a')
            assert(v == 123)
        end
        calledCount = calledCount + 1
    end)
end

for N = 1, 10 do
    local t = {}

    for i = 1, N do
        t[i] = math.random(MAX)
    end

    for i = 1, N do
        local k = 'key' .. i
        t[k] = math.random(MAX)
    end

    local calledCount = 0

    local visited = {}

    local lastKey

    TableUtils:sortedIter(t, function (k, v)
        assert(k ~= nil)
        assert(v ~= nil)
        assert(not visited[k])
        assert(t[k] == v)

        if lastKey ~= nil then
            if type(lastKey) == type(k) then
                assert(lastKey < k)
            else
                assert(type(lastKey) < type(k))
            end
        end

        visited[k] = true
        calledCount = calledCount + 1

        lastKey = k
    end)

    assert(TableUtils:numOfPairs(t) == calledCount)
end

-- numOfPairs

assert(TableUtils:numOfPairs{} == 0)
assert(TableUtils:numOfPairs{123} == 1)
assert(TableUtils:numOfPairs{123, a=123} == 2)
assert(TableUtils:numOfPairs{123, a=456} == 2)
assert(TableUtils:numOfPairs{123, a=456, b=789} == 3)
assert(TableUtils:numOfPairs{123, [3]=777, a=456, b=789} == 4)

for N = 1, 10 do
    local t = {}

    for i = 1, N do
        local k = 'key' .. i
        t[k] = math.random(MAX)
    end

    assert(TableUtils:numOfPairs(t) == N)
end

-- ipairsReversed

assertNoIteration(TableUtils:ipairsReversed{})
assertNoIteration(TableUtils:ipairsReversed{a=123})

do
    local iterationCount = 0

    for i, v in TableUtils:ipairsReversed{777, a=123} do
        assert(i == 1)
        assert(v == 777)

        iterationCount = iterationCount + 1
    end

    assert(iterationCount == 1)
end

for N = 1, 10 do
    local t = {}

    for i = 1, N do
        t[i] = math.random(MAX)
    end

    local iterationCount = 0
    local lastIndex

    for i, v in TableUtils:ipairsReversed(t) do
        assert(i ~= nil)
        assert(v ~= nil)
        assert(t[i] == v)

        if lastIndex ~= nil then
            assert(lastIndex == i + 1)
        end

        iterationCount = iterationCount + 1

        lastIndex = i
    end

    assert(iterationCount == N)
end

-- foldl

local function cons (v, acc)
    return {v = v, acc = acc}
end

local z = {}

assertEq(TableUtils:foldl(cons, z, {}), z)
assertEq(TableUtils:foldl(cons, z, {123}), {v = 123, acc = z})
assertEq(TableUtils:foldl(cons, z, {123, 456}), {v = 456, acc = {v = 123, acc = z}})

for N = 1, 10 do
    local t = {}

    for i = 1, N do
        t[i] = math.random(MAX)
    end

    local acc = TableUtils:foldl(cons, z, t)

    while acc ~= z do
        assert(type(acc) == 'table')
        assert(acc.v == table.remove(t))
        acc = acc.acc
    end

    assert(#t == 0)
end

-- shuffleInPlace

local function shuffle (t)
    TableUtils:shuffleInPlace(t)
    return t
end

assertEq(shuffle{}, {})
assertEq(shuffle{a=123}, {a=123})
assertEq(shuffle{123}, {123})

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
        local ta = f()
        local tb = f()
        assertEq(ta, tb)
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
