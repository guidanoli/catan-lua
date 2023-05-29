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

local actions = {}

function actions.placeInitialSettlement (game)
    if not game:canPlaceInitialSettlement() then
        return false
    end
    local vertex = randomValidVertex(game, function (vertex)
        return game:canPlaceInitialSettlement(vertex)
    end)
    if vertex == nil then
        return false
    end
    local production = game:placeInitialSettlement(vertex)
    print(("placeInitialSettlement(%s)"):format(display(vertex)))
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
