local TableUtils = require "util.table"

local Grid = require "catan.logic.grid"

local MAX_RANDOM_INT = 10000
local NUM_ITERATIONS = 100

local function randomInt ()
    return math.random(2 * MAX_RANDOM_INT + 1) - (MAX_RANDOM_INT + 1)
end

-- local function randomFace ()
--     return Grid:face(randomInt(), randomInt())
-- end
-- 
-- local EDGE_KINDS = {'NW', 'W', 'NE'}
-- 
-- local function randomEdge ()
--     return Grid:edge(randomInt(), randomInt(), TableUtils:sample(EDGE_KINDS))
-- end

local VERTEX_KINDS = {'N', 'S'}

local function randomVertex ()
    return Grid:vertex(randomInt(), randomInt(), TableUtils:sample(VERTEX_KINDS))
end

-- edgeInBetween

do
    for i = 1, NUM_ITERATIONS do
        local vertex = randomVertex()
        for _, pair in ipairs(Grid:adjacentEdgeVertexPairs(Grid:unpack(vertex))) do
            local edgeInBetween = Grid:edgeInBetween(vertex, pair.vertex)
            assert(edgeInBetween ~= nil)
            assert(TableUtils:deepEqual(pair.edge, edgeInBetween))
        end
    end
end

-- edgeOrientationInFace

do
    local face = Grid:face(1, 1)

    local function check (edge, orientation)
        assert(Grid:edgeOrientationInFace(face, edge) == orientation)
    end

    check(Grid:edge(1, 1, 'NW'), 'NW')
    check(Grid:edge(1, 1, 'NE'), 'NE')
    check(Grid:edge(1, 1, 'W'), 'W')
    check(Grid:edge(2, 1, 'W'), 'E')
    check(Grid:edge(1, 2, 'NW'), 'SE')
    check(Grid:edge(0, 2, 'NE'), 'SW')
end
