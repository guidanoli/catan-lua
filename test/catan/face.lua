require "util.safe"

local Face = require "catan.logic.face"

do
    local expected = {
        {x = -2, y = 2},
        {x = -1, y = 2},
        {x = 0, y = 2},
        {x = -2, y = 1},
        {x = -1, y = 1},
        {x = 0, y = 1},
        {x = 1, y = 1},
        {x = -2, y = 0},
        {x = -1, y = 0},
        {x = 0, y = 0},
        {x = 1, y = 0},
        {x = 2, y = 0},
        {x = -1, y = -1},
        {x = 0, y = -1},
        {x = 1, y = -1},
        {x = 2, y = -1},
        {x = 0, y = -2},
        {x = 1, y = -2},
        {x = 2, y = -2},
    }

    local obtained = Face:generateFaces()

    local function valid (f)
        for k, v in pairs(f) do
            if not (k == 'x' or k == 'y') then
                return false
            end
        end
        return type(f.x) == 'number' and
               type(f.y) == 'number'
    end

    for i = 1, #obtained do
        assert(valid(obtained[i]))
    end

    assert(#expected == #obtained)

    local function cmp (f1, f2)
        if f1.x == f2.x then
            return f1.y < f2.y
        else
            return f1.x < f2.x
        end
    end

    table.sort(expected, cmp)
    table.sort(obtained, cmp)

    local function eq (f1, f2)
        return f1.x == f2.x and f1.y == f2.y
    end

    for i = 1, #expected do
        assert(eq(expected[i], obtained[i]))
    end
end
