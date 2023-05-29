local Grid = require "catan.logic.grid"

local FaceMap = require "catan.logic.FaceMap"
local VertexMap = require "catan.logic.VertexMap"
local EdgeMap = require "catan.logic.EdgeMap"

local Game = require "catan.logic.game"

local function validFaces (game, isValid)
    local facemap = FaceMap:new()
    local n = 0
    game.hexmap:iter(function (q, r)
        local face = Grid:face(q, r)
        if facemap:get(face) == nil and isValid(face) then
            facemap:set(face, true)
            n = n + 1
        end
    end)
    return facemap, n
end

local function randomValidFace (game, isValid)
    local faces, n = validFaces(game, isValid)
    if n == 0 then
        return
    end
    local i = math.random(n)
    local j = 1
    local face = faces:iter(function (q, r, v)
        if i == j then
            return Grid:face(q, r, v)
        else
            j = j + 1
        end
    end)
    return assert(face)
end

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

local function validEdges (game, isValid)
    local edgemap = EdgeMap:new()
    local n = 0
    game.hexmap:iter(function (q, r)
        for _, border in ipairs(Grid:borders(q, r)) do
            if edgemap:get(border) == nil and isValid(border) then
                edgemap:set(border, true)
                n = n + 1
            end
        end
    end)
    return edgemap, n
end

local function randomValidEdge (game, isValid)
    local edges, n = validEdges(game, isValid)
    if n == 0 then
        return
    end
    local i = math.random(n)
    local j = 1
    local edge = edges:iter(function (q, r, e)
        if i == j then
            return Grid:edge(q, r, e)
        else
            j = j + 1
        end
    end)
    return assert(edge)
end

local function randomDice ()
    local dice = {}
    for i = 1, 2 do
        dice[i] = math.random(6)
    end
    return dice
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

local function printSuccess (s)
    io.stderr:write(green'SUCCESS: ' .. s .. '\n')
end

local function printFailure (s)
    io.stderr:write(red'FAILURE: ' .. s .. '\n')
end

local actions = {}

function actions.placeInitialSettlement (game)
    local ok, err = game:canPlaceInitialSettlement()
    if not ok then
        return false, err
    end
    local vertex = randomValidVertex(game, function (vertex)
        return game:canPlaceInitialSettlement(vertex)
    end)
    local production = game:placeInitialSettlement(vertex)
    return true, ('placeInitialSettlement(%s)'):format(display(vertex))
end

function actions.placeInitialRoad (game)
    local ok, err = game:canPlaceInitialRoad()
    if not ok then
        return false, err
    end
    local edge = randomValidEdge(game, function (edge)
        return game:canPlaceInitialRoad(edge)
    end)
    local production = game:placeInitialRoad(edge)
    return true, ('placeInitialRoad(%s)'):format(display(edge))
end

function actions.roll (game)
    local ok, err = game:canRoll()
    if not ok then
        return false, err
    end
    local dice = randomDice()
    local production = game:roll(dice)
    return true, ('roll({%s})'):format(table.concat(dice, ', '))
end

function actions.moveRobber (game)
    local ok, err = game:canMoveRobber()
    if not ok then
        return false, err
    end
    local face = randomValidFace(game, function (face)
        return game:canMoveRobber(face)
    end)
    local victim, res = game:moveRobber(face)
    return true, ('moveRobber(%s)'):format(display(face))
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

    local ok, msg = actions[actionKey](game)

    if msg == nil then
        msg = ('(no message given by %q)'):format(actionKey)
    end

    if ok then
        printSuccess(msg)
        statistics.successes = (statistics.successes or 0) + 1
    else
        printFailure(msg)
        statistics.failures = (statistics.failures or 0) + 1
    end

    lastActionKey = actionKey
end

do
    local timeAfter = os.clock()
    local timeDiff = timeAfter - timeBefore
    print(('Elapsed time: %f s'):format(timeDiff))
end

do
    local successes = statistics.successes
    local failures = statistics.failures
    local total = successes + failures
    print(('Number of runs: %d'):format(total))
    print(('Success rate: %.2f %% (%d)'):format(100 * successes / total, successes))
    print(('Failure rate: %.2f %% (%d)'):format(100 * failures / total, failures))
end
