local Grid = require "catan.logic.grid"

local VertexMap = require "catan.logic.VertexMap"

local Game = require "catan.logic.game"

local function validVertices (game, isValid)
    local vertexmap = VertexMap:new()
    local n = 0
    game.hexmap:iter(function (q, r)
        for _, corner in ipairs(Grid:corners(q, r)) do
            if vertexmap:get(corner) == nil and isValid(corner) then
                vertexmap:set(corner, true)
                n = n + 1
            end
        end
    end)
    return vertexmap, n
end

local function randomValidVertex (game, isValid)
    local vertices, n = validVertices(game, isValid)
    if n == 0 then
        return
    end
    local i = math.random(n)
    local j = 1
    local vertex = vertices:iter(function (q, r, v)
        if i == j then
            return Grid:vertex(q, r, v)
        else
            j = j + 1
        end
    end)
    return assert(vertex)
end

local function display (gridpart)
    local q, r, x = Grid:unpack(gridpart)
    if x == nil then
        return ("<%d,%d>"):format(q, r)
    else
        return ("<%d,%d,%s>"):format(q, r, x)
    end
end

local function color (code, s)
    return '\27[0;' .. code .. 'm' .. s .. '\27[0;00m'
end

local function red (s)
    return color(31, s)
end

local function green (s)
    return color(32, s)
end

local function success (s, ...)
    io.stderr:write(green'SUCCESS: ', s:format(...), '\n')
end

local function failure (s, ...)
    io.stderr:write(red'FAILURE: ', s:format(...), '\n')
end

local actions = {}

function actions.placeInitialSettlement (game)
    if not game:canPlaceInitialSettlement() then
        failure('cannot place initial settlement')
        return false
    end
    local vertex = randomValidVertex(game, function (vertex)
        return game:canPlaceInitialSettlement(vertex)
    end)
    if vertex == nil then
        failure('no vertex to place initial settlement')
        return false
    end
    local production = game:placeInitialSettlement(vertex)
    success('placeInitialSettlement(%s)', display(vertex))
    return true
end

local NUM_RUNS = 100

local lastActionKey
local statistics = {}

local game = Game:new()

local timeBefore = os.clock()

for i = 1, NUM_RUNS do
    local actionKey = next(actions, lastActionKey)
    if actionKey == nil then
        actionKey = next(actions) -- loop over
    end

    local success = actions[actionKey](game)
    if success then
        statistics.successes = (statistics.successes or 0) + 1
    else
        statistics.failures = (statistics.failures or 0) + 1
    end

    lastActionKey = actionKey
end

do
    local timeAfter = os.clock()
    local timeDiff = timeAfter - timeBefore
    print(('Elapsed time: %f s'):format(timeDiff))
end
