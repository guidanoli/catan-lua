local TableUtils = {}

function TableUtils:shuffleInPlace (t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end

-- ∃ N s.t. ∀ (k, v) ∊ t, k ∊ [1, N]
function TableUtils:isArray (t)
    local i = 1
    for _ in pairs(t) do
        if t[i] == nil then
            return false
        end
        i = i + 1
    end
    return true
end

-- Returns a sorted array of keys in t
function TableUtils:sortedKeys (t)
    local st = {}
    for k in pairs(t) do
        table.insert(st, k)
    end
    table.sort(st)
    return st
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

local function foldrec (f, t, i)
    i = i + 1
    local v = t[i]
    if v == nil then
        return
    else
        return f(v, foldrec(f, t, i))
    end
end

function TableUtils:fold (f, t)
    return foldrec(f, t, 0)
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

return TableUtils
