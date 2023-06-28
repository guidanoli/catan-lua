---
-- Useful operations on tables.
--
-- For arbitrary tables, we'll use the letter `t`.
--
-- For list-like tables, however, we'll use the letter `l`.
--
-- @module util.table

local TableUtils = {}

---
-- Sum all values of a table.
-- @tparam table t
-- @treturn number sum of all values of `t`
function TableUtils:sum (t)
    local n = 0
    for k, v in pairs(t) do
        n = n + v
    end
    return n
end

---
-- Filter values of a list.
-- @tparam table l
-- @tparam function f filter
-- @treturn table list containing only pairs `(i, v)` for which `f(v)` is true.
-- @usage
-- local TableUtils = require "util.table"
-- local l = {1, 2, 3, 4, 5, 6}
-- local function f (v) return v % 2 == 0 end
-- local fl = TableUtils:filter(l, f)
-- print(table.concat(fl, ', ')) -- 2, 4, 6
function TableUtils:filter (l, f)
    local out = {}
    local j = 1
    for i, v in ipairs(l) do
        if f(v) then
            rawset(out, j, v)
            j = j + 1
        end
    end
    return out
end

---
-- Map values of a list.
-- @tparam table l
-- @tparam function m mapping
-- @treturn table list containing only pairs `(i, m(v))` for all `(i, v)` in `l`.
-- @usage
-- local TableUtils = require "util.table"
-- local l = {1, 2, 3, 4, 5, 6}
-- local function m (v) return v * 2 end
-- local ml = TableUtils:map(l, m)
-- print(table.concat(ml, ', ')) -- 2, 4, 6, 8, 10, 12
function TableUtils:map (l, m)
    local out = {}
    for i, v in ipairs(l) do
        rawset(out, i, m(v))
    end
    return out
end

---
-- Choose a random value from a list.
-- @tparam table l
-- @return some `l[i]` such that `i` is in `[1, #l]`, or `nil` if `#l < 1`
-- @treturn ?number `i`, iff `#l >= 1`
-- @see math.random
function TableUtils:sample (l)
    local n = #l
    if n >= 1 then
        local i = math.random(n)
        return rawget(l, i), i
    end
end

---
-- Sample `m` values from a list (without replacement).
-- Asserts that `m` is less than or equal to the length of the list.
-- @tparam table l
-- @tparam number m
-- @treturn table a list containing `m` unique samples from `l`
-- @see sample
function TableUtils:uniqueSamples (l, m)
    local samples = {}
    local n = #l
    assert(m <= n)
    local indices = {}
    for i = 1, n do
        indices[i] = i
    end
    for i = 1, m do
        local j, k = self:sample(indices)
        table.remove(indices, k)
        samples[i] = rawget(l, j)
    end
    return samples
end

---
-- Create histogram of values of a list.
-- @tparam table l
-- @treturn table histogram of values of `l`
function TableUtils:histogram (l)
    local h = {}
    for _, v in ipairs(l) do
        h[v] = (h[v] or 0) + 1
    end
    return h
end

---
-- Shuffle the values of a list in-place.
-- @tparam table l
-- @see math.random
function TableUtils:shuffleInPlace (l)
    for i = #l, 2, -1 do
        local j = math.random(i)
        l[i], l[j] = l[j], l[i]
    end
end

local function comp (a, b)
    local ta = type(a)
    local tb = type(b)

    if ta == tb then
        return a < b
    else
        return ta < tb
    end
end

---
-- Create an ordered list with all the keys of a table.
-- Orders keys by `<` on the key types, and then by `<` on the keys.
-- @tparam table t
-- @treturn table an ordered list of all the keys of `t`
function TableUtils:sortedKeys (t)
    local st = {}
    for k in pairs(t) do
        table.insert(st, k)
    end
    table.sort(st, comp)
    return st
end

---
-- Iterate through the pairs of a table, ordered by the keys.
-- Calls `f` for all key-value pairs and checks if the return value is true.
-- If `f(k, v)` ever returns some `ret` different from `nil` and `false`,
-- then the iteration stops and `ret` is returned.
-- @tparam table t
-- @tparam function f
-- @return the first true return value of `f(k, v)` or `nil`
function TableUtils:sortedIter (t, f)
    for _, k in ipairs(self:sortedKeys(t)) do
        local v = rawget(t, k)
        local ret = f(k, v)
        if ret then return ret end
    end
end

---
-- Get the number of key-value pairs in a table.
-- @tparam table t
-- @treturn number number of key-value pairs in `t`
function TableUtils:numOfPairs (t)
    local n = 0
    for _ in pairs(t) do
        n = n + 1
    end
    return n
end

local function reversedipairsiter (l, i)
    i = i - 1
    if i ~= 0 then
        return i, l[i]
    end
end

---
-- Iterate through all index-value pairs of a list, in reverse order.
-- @tparam table l
-- @treturn function iterator
-- @treturn table list
-- @treturn number index
-- @usage
-- local TableUtils = require "util.table"
-- local l = {'a', 'b', 'c'}
-- for i, v in TableUtils:ipairsReversed(l) do
--   print(i, v) -- 3 c; 2 b; 1 a
-- end
function TableUtils:ipairsReversed (l)
    return reversedipairsiter, l, #l + 1
end

---
-- Perform a left fold of a list with a combining function and an initial value.
-- @tparam function f combining function
-- @param z initial value
-- @tparam table l list
-- @return final state of the accumulator
-- @usage
-- local TableUtils = require "util.table"
-- local l = {'a', 'b', 'c'}
-- print(TableUtils:foldl(string.concat, '', l)) -- abc
function TableUtils:foldl (f, z, l)
    local acc = z
    for _, v in ipairs(l) do
        acc = f(v, acc)
    end
    return acc
end

local function equalkeyset (ta, tb)
    for k in pairs(tb) do
        if rawget(ta, k) == nil then
            return false, (".%s == nil in table a"):format(k)
        end
    end
    for k in pairs(ta) do
        if rawget(tb, k) == nil then
            return false, (".%s == nil in table b"):format(k)
        end
    end
    return true
end

local function istable (o)
    return type(o) == "table"
end

local function equalrec (ta, tb, checkmetatable)
    if checkmetatable then
        if getmetatable(ta) ~= getmetatable(tb) then
            return false, ". differ (metatables)"
        end
    end
    local ok, err = equalkeyset(ta, tb)
    if not ok then
        return false, err
    end
    for k, va in pairs(ta) do
        local vb = rawget(tb, k)
        if istable(va) and istable(vb) then
            local ok, err = equalrec(va, vb, checkmetatable)
            if not ok then
                return false, (".%s%s"):format(k, err)
            end
        else
            if va ~= vb then
                return false, (".%s differ (%s ~= %s)"):format(k, va, vb)
            end
        end
    end
    return true
end

---
-- Recursively check if two tables are equal.
-- You can also check for metatable equality with `checkmetatable`.
-- @tparam table ta
-- @tparam table tb
-- @tparam[opt=false] boolean checkmetatable
-- @treturn boolean whether `ta` and `tb` are equal
-- @treturn ?string an error message (if `ta` and `tb` are not equal)
function TableUtils:deepEqual (...)
    return equalrec(...)
end

---
-- Reverse a list.
-- @tparam table l
-- @treturn table a list with all values of `l` in reverse order
function TableUtils:reverse (l)
    local reversed = {}
    local n = #l
    for i, v in ipairs(l) do
        local j = n - i + 1
        reversed[j] = v
    end
    return reversed
end

---
-- Create a podium for a table of comparable values.
-- @tparam table t
-- @return the maximum value in `t`, or `nil` if `t` is empty
-- @treturn number the number of keys paired with the maximum value
-- @treturn table the set of keys paired with the maximum value
-- @usage
-- local TableUtils = require "util.table"
-- local t = {a=5, b=7, c=3, d=7, e=1}
-- local maxValue, tiedCount, tiedKeys = TableUtils:podium(t)
-- print(maxValue) -- 7
-- print(tiedCount) -- 2
-- print(table.concat(TableUtils:sortedKeys(tiedCount), ', ')) -- b, d
function TableUtils:podium (t)
    local maxValue
    local tiedCount = 0
    local tiedKeys = {}

    for _, value in pairs(t) do
        if maxValue == nil or value > maxValue then
            maxValue = value
        end
    end

    for key, value in pairs(t) do
        if value == maxValue then
            tiedCount = tiedCount + 1
            tiedKeys[key] = true
        end
    end

    assert(tiedCount >= 0)

    return maxValue, tiedCount, tiedKeys
end

local function clonerec (t)
    if type(t) == 'table' then
        local mt = getmetatable(t)
        local tc = setmetatable({}, mt)
        for k, v in pairs(t) do
            rawset(tc, k, clonerec(v))
        end
        return tc
    else
        return t
    end
end

---
-- Recursively clone a table. Also sets metatables.
-- @tparam table t
-- @treturn table a clone of `t`
function TableUtils:deepClone (...)
    return clonerec(...)
end

return TableUtils
