local argparse = require "argparse"

local TableUtils = require "util.table"

local Grid = require "catan.logic.grid"

local FaceMap = require "catan.logic.FaceMap"
local VertexMap = require "catan.logic.VertexMap"
local EdgeMap = require "catan.logic.EdgeMap"

local Game = require "catan.logic.game"

local function validFaces (game, isValid)
    local facemap = FaceMap:new()
    local faces = {}
    game.hexmap:iter(function (q, r)
        local face = Grid:face(q, r)
        if facemap:get(face) == nil and isValid(face) then
            facemap:set(face, true)
            table.insert(faces, face)
        end
    end)
    return faces
end

local function randomValidFace (game, isValid)
    return TableUtils:sample(validFaces(game, isValid))
end

local function validVertices (game, isValid)
    local vertexmap = VertexMap:new()
    local vertices = {}
    game.hexmap:iter(function (q, r)
        for _, corner in ipairs(Grid:corners(q, r)) do
            if vertexmap:get(corner) == nil and isValid(corner) then
                vertexmap:set(corner, true)
                table.insert(vertices, corner)
            end
        end
    end)
    return vertices
end

local function randomValidVertex (game, isValid)
    return TableUtils:sample(validVertices(game, isValid))
end

local function validEdges (game, isValid)
    local edgemap = EdgeMap:new()
    local edges = {}
    game.hexmap:iter(function (q, r)
        for _, border in ipairs(Grid:borders(q, r)) do
            if edgemap:get(border) == nil and isValid(border) then
                edgemap:set(border, true)
                table.insert(edges, border)
            end
        end
    end)
    return edges
end

local function randomValidEdge (game, isValid)
    return TableUtils:sample(validEdges(game, isValid))
end

local function randomDice ()
    local dice = {}
    for i = 1, 2 do
        dice[i] = math.random(6)
    end
    return dice
end

local function validPlayers (game, isValid)
    local players = {}
    for _, player in ipairs(game.players) do
        if isValid(player) then
            table.insert(players, player)
        end
    end
    return players
end

local function randomValidPlayer (game, isValid)
    return TableUtils:sample(validPlayers(game, isValid))
end

local function listPlayerResCards (game, player)
    local list = {}
    for rescard, count in pairs(game.rescards[player]) do
        for i = 1, count do
            table.insert(list, rescard)
        end
    end
    return list
end

local function randomValidPlayerResCardsToDiscard (game, player)
    local list = listPlayerResCards(game, player)
    local n = game:getNumberOfResourceCardsToDiscard(player)
    local list = TableUtils:uniqueSamples(list, n)
    return TableUtils:histogram(list)
end

local function display (gridpart)
    local q, r, x = Grid:unpack(gridpart)
    if x == nil then
        return ("<%d,%d>"):format(q, r)
    else
        return ("<%d,%d,%s>"):format(q, r, x)
    end
end

local function fmtrescards (rescards)
    local t = {}
    for _, rescard in ipairs(TableUtils:sortedKeys(rescards)) do
        local count = rescards[rescard]
        table.insert(t, rescard .. ':' .. count)
    end
    return '<' .. table.concat(t, ',') .. '>'
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
    io.stderr:write(green'SUCCESS: ', s, '\n')
end

local function printFailure (s)
    io.stderr:write(red'FAILURE: ', s, '\n')
end

local actions = {}

function actions.placeInitialSettlement (game)
    local ok, msg = game:canPlaceInitialSettlement()
    if ok then
        local vertex = randomValidVertex(game, function (vertex)
            return game:canPlaceInitialSettlement(vertex)
        end)
        local production = game:placeInitialSettlement(vertex)
        msg = ('placeInitialSettlement(%s)'):format(display(vertex))
    end
    return ok, msg
end

function actions.placeInitialRoad (game)
    local ok, msg = game:canPlaceInitialRoad()
    if ok then
        local edge = randomValidEdge(game, function (edge)
            return game:canPlaceInitialRoad(edge)
        end)
        local production = game:placeInitialRoad(edge)
        msg = ('placeInitialRoad(%s)'):format(display(edge))
    end
    return ok, msg
end

function actions.roll (game)
    local ok, msg = game:canRoll()
    if ok then
        local dice = randomDice()
        local production = game:roll(dice)
        msg = ('roll({%s})'):format(table.concat(dice, ', '))
    end
    return ok, msg
end

function actions.endTurn (game)
    local ok, msg = game:canEndTurn()
    if ok then
        game:endTurn()
        msg = 'endTurn()'
    end
    return ok, msg
end

function actions.discard (game)
    local ok, msg = game:canDiscard()
    if ok then
        local player = randomValidPlayer(game, function (player)
            return game:canDiscard(player)
        end)
        local rescards = randomValidPlayerResCardsToDiscard(game, player)
        game:discard(player, rescards)
        msg = ('discard(%s, %s)'):format(player, fmtrescards(rescards))
    end
    return ok, msg
end

function actions.moveRobber (game)
    local ok, msg = game:canMoveRobber()
    if ok then
        local face = randomValidFace(game, function (face)
            return game:canMoveRobber(face)
        end)
        local victim, res = game:moveRobber(face)
        msg = ('moveRobber(%s)'):format(display(face))
    end
    return ok, msg
end

function actions.chooseVictim (game)
    local ok, msg = game:canChooseVictim()
    if ok then
        local player = randomValidPlayer(game, function (player)
            return game:canChooseVictim(player)
        end)
        local res = game:chooseVictim(player)
        msg = ('chooseVictim(%s)'):format(player)
    end
    return ok, msg
end

function actions.buildRoad (game)
    local ok, msg = game:canBuildRoad()
    if ok then
        local edge = randomValidEdge(game, function (edge)
            return game:canBuildRoad(edge)
        end)
        if edge == nil then
            ok = false
            msg = "no potential edges found"
        else
            game:buildRoad(edge)
            msg = ('buildRoad(%s)'):format(display(edge))
        end
    end
    return ok, msg
end

local function run (args)
    local lastActionKey
    local report = {}

    local game = Game:new()

    for i = 1, args.ncalls do
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
            report.successes = (report.successes or 0) + 1
        else
            if args.v >= 1 then
                printFailure(msg)
            end
            report.failures = (report.failures or 0) + 1
        end

        lastActionKey = actionKey
    end

    return report
end

local parser = argparse("fuzzy", "Catan fuzzy tester")
parser:option("--ncalls", "Number of call attempts per game.", 1000)
parser:flag("-v", "Verbosity level."):count"*"

local args = parser:parse()

local timeBefore = os.clock()

local report = run(args)

do
    local timeAfter = os.clock()
    local timeDiff = timeAfter - timeBefore
    print(('Elapsed time: %f s'):format(timeDiff))
end

do
    local successes = report.successes or 0
    local failures = report.failures or 0
    local total = successes + failures
    print(('Number of runs: %d'):format(total))
    if args.v >= 1 and total ~= 0 then
        print(('Success rate: %.2f %% (%d)'):format(100 * successes / total, successes))
        print(('Failure rate: %.2f %% (%d)'):format(100 * failures / total, failures))
    end
end
