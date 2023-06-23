local TableUtils = {}

function TableUtils:sum (t)
    local n = 0
    for k, v in pairs(t) do
        n = n + v
    end
    return n
end

function TableUtils:filter (t, f)
    local out = {}
    local j = 1
    for i, v in ipairs(t) do
        if f(v) then
            rawset(out, j, v)
            j = j + 1
        end
    end
    return out
end

function TableUtils:map (t, m)
    local out = {}
    for i, v in ipairs(t) do
        rawset(out, i, m(v))
    end
    return out
end

function TableUtils:sample (t)
    local n = #t
    if n ~= 0 then
        local i = math.random(n)
        return rawget(t, i), i
    end
end

function TableUtils:uniqueSamples (t, m)
    local samples = {}
    local n = #t
    assert(m <= n)
    local indices = {}
    for i = 1, n do
        indices[i] = i
    end
    for i = 1, m do
        local j, k = self:sample(indices)
        table.remove(indices, k)
        samples[i] = rawget(t, j)
    end
    return samples
end

function TableUtils:histogram (t)
    local h = {}
    for _, v in ipairs(t) do
        h[v] = (h[v] or 0) + 1
    end
    return h
end

function TableUtils:shuffleInPlace (t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
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

-- Returns a sorted array of keys in t
function TableUtils:sortedKeys (t)
    local st = {}
    for k in pairs(t) do
        table.insert(st, k)
    end
    table.sort(st, comp)
    return st
end

-- Iterate through table in order of keys
-- Function f is called with each key and value pair
-- If f returns anything different from nil or false,
-- then iteration is interupted and this value is returned
function TableUtils:sortedIter (t, f)
    for _, k in ipairs(self:sortedKeys(t)) do
        local v = rawget(t, k)
        local ret = f(k, v)
        if ret then return ret end
    end
end

-- |K| where K = { k | (k, v) ∊  t }
function TableUtils:numOfPairs (t)
    local n = 0
    for _ in pairs(t) do
        n = n + 1
    end
    return n
end

local function reversedipairsiter (t, i)
    i = i - 1
    if i ~= 0 then
        return i, t[i]
    end
end

-- reversed ipairs
function TableUtils:ipairsReversed (t)
    return reversedipairsiter, t, #t + 1
end

function TableUtils:foldl (f, z, t)
    local acc = z
    for _, v in ipairs(t) do
        acc = f(v, acc)
    end
    return acc
end

local function equalkeyset (ta, tb)
    for k in pairs(tb) do
        if rawget(ta, k) == nil then
            return false, ("[%q] == nil in table a"):format(k)
        end
    end
    for k in pairs(ta) do
        if rawget(tb, k) == nil then
            return false, ("[%q] == nil in table b"):format(k)
        end
    end
    return true
end

local function istable (o)
    return type(o) == "table"
end

local function equalrec (ta, tb)
    local ok, err = equalkeyset(ta, tb)
    if not ok then
        return false, err
    end
    for k, va in pairs(ta) do
        local vb = rawget(tb, k)
        if istable(va) and istable(vb) then
            local ok, err = equalrec(va, vb)
            if not ok then
                return false, ("[%q]%s"):format(k, err)
            end
        else
            if va ~= vb then
                return false, ("[%q] differ (%q ~= %q)"):format(k, va, vb)
            end
        end
    end
    return true
end

function TableUtils:deepEqual (ta, tb)
    return equalrec(ta, tb)
end

function TableUtils:sameKeySet (ta, tb)
    return equalkeyset(ta, tb)
end

return TableUtils
