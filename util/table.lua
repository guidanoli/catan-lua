local TableUtils = {}

function TableUtils:shuffleInPlace (t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end

-- ∃ k s.t. (k, v) ∊ t
function TableUtils:contains (t, v1)
    for k, v2 in pairs(t) do
        if v1 == v2 then
            return true
        end
    end
    return false
end

-- ∀ (k, v) ∊ ta, ∃ k' s.t. (k', v) ∊ tb
function TableUtils:isContainedIn (ta, tb)
    for k, v in pairs(ta) do
        if not self:contains(tb, v) then
            return false
        end
    end
    return true
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

-- Iterate over 2d array
function TableUtils:iter2d (t, f)
    for i, line in pairs(t) do
        for j, elem in pairs(line) do
            local ret = f(i, j, elem)
            if ret then return ret end
        end
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

return TableUtils
