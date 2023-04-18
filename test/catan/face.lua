require "util.safe"

local Face = require "catan.logic.face"

do
    local expected = {
        {q = -2, r = 2},
        {q = -1, r = 2},
        {q = 0, r = 2},
        {q = -2, r = 1},
        {q = -1, r = 1},
        {q = 0, r = 1},
        {q = 1, r = 1},
        {q = -2, r = 0},
        {q = -1, r = 0},
        {q = 0, r = 0},
        {q = 1, r = 0},
        {q = 2, r = 0},
        {q = -1, r = -1},
        {q = 0, r = -1},
        {q = 1, r = -1},
        {q = 2, r = -1},
        {q = 0, r = -2},
        {q = 1, r = -2},
        {q = 2, r = -2},
    }

    local obtained = Face:generateFaces()

    local function valid (f)
        for k, v in pairs(f) do
            if not (k == 'q' or k == 'r') then
                return false
            end
        end
        return type(f.q) == 'number' and
               type(f.r) == 'number'
    end

    for i = 1, #obtained do
        assert(valid(obtained[i]))
    end

    assert(#expected == #obtained)

    local function cmp (f1, f2)
        if f1.q == f2.q then
            return f1.r < f2.r
        else
            return f1.q < f2.q
        end
    end

    table.sort(expected, cmp)
    table.sort(obtained, cmp)

    local function eq (f1, f2)
        return f1.q == f2.q and f1.r == f2.r
    end

    for i = 1, #expected do
        assert(eq(expected[i], obtained[i]))
    end
end
