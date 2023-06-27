require "util.safe"

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

local function randomPlayerResCards (game, player, n)
    local allCards = listPlayerResCards(game, player)
    if #allCards == 0 then
        return {}
    end
    n = n or math.random(#allCards)
    local sampledCards = TableUtils:uniqueSamples(allCards, n)
    return TableUtils:histogram(sampledCards)
end

local function randomPlayerResCardsForMaritimeTrade (game, player)
    local mycards = {}
    local tradeReturn = 0
    local ratios, defaultRatio = game:getTradeRatios(player)
    for kind, count in pairs(game.rescards[player]) do
        local ratio = ratios[kind] or defaultRatio
        local maxGroupCount = math.floor(count / ratio)
        local groupCount = math.random(maxGroupCount + 1) - 1
        mycards[kind] = groupCount * ratio
        tradeReturn = tradeReturn + groupCount
    end
    return mycards, tradeReturn
end

local function randomPlayerResCardsToDiscard (game, player)
    local n = game:getNumberOfResourceCardsToDiscard(player)
    return randomPlayerResCards(game, player, n)
end

local function randomResource (game)
    local resources = TableUtils:sortedKeys(game.bank)
    return TableUtils:sample(resources)
end

local function randomResCardsFromBank (game, n)
    local rescards = {}
    local resources = TableUtils:sortedKeys(game.bank)
    for i = 1, n do
        while true do
            local added = false
            TableUtils:shuffleInPlace(resources)
            for _, res in ipairs(resources) do
                local supply = game.bank[res] or 0
                local count = rescards[res] or 0
                local newCount = count + 1
                if supply >= newCount then
                    rescards[res] = newCount
                    added = true
                    break
                end
            end
            if added then
                break -- go to next card
            else
                return -- Bank would be empty
            end
        end
    end
    return rescards
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
    TableUtils:sortedIter(rescards, function (rescard, count)
        local count = rescards[rescard]
        table.insert(t, rescard .. ':' .. count)
    end)
    return '[' .. table.concat(t, ', ') .. ']'
end

local function fmtproduction (production)
    local t = {}
    production:iter(function (player, res, n)
        table.insert(t, ('<%s,%s,%d>'):format(player, res, n))
    end)
    return '[' .. table.concat(t, ', ') .. ']'
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

local function printSuccess (i, j, s)
    io.stderr:write(green(('SUCCESS (%d/%d): '):format(i, j)),  s, '\n')
end

local function printFailure (i, j, s)
    io.stderr:write(red(('FAILURE (%d/%d): '):format(i, j)), s, '\n')
end

local actions = {}

function actions.placeInitialSettlement (game)
    local ok, msg = game:canPlaceInitialSettlement()
    if ok then
        local vertex = randomValidVertex(game, function (vertex)
            return game:canPlaceInitialSettlement(vertex)
        end)
        local production = game:placeInitialSettlement(vertex)
        msg = ('placeInitialSettlement(%s) -> %s'):format(display(vertex), fmtproduction(production))
    end
    return ok, msg
end

function actions.placeInitialRoad (game)
    local ok, msg = game:canPlaceInitialRoad()
    if ok then
        local edge = randomValidEdge(game, function (edge)
            return game:canPlaceInitialRoad(edge)
        end)
        game:placeInitialRoad(edge)
        msg = ('placeInitialRoad(%s)'):format(display(edge))
    end
    return ok, msg
end

function actions.roll (game)
    local ok, msg = game:canRoll()
    if ok then
        local dice = randomDice()
        local production = game:roll(dice)
        msg = ('roll({%s}) -> %s'):format(table.concat(dice, ', '), fmtproduction(production))
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
        local rescards = randomPlayerResCardsToDiscard(game, player)
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
        msg = ('moveRobber(%s) -> (%s, %s)'):format(display(face), victim, res)
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
        msg = ('chooseVictim(%s) -> %s'):format(player, res)
    end
    return ok, msg
end

function actions.tradeWithPlayer (game)
    local ok, msg = game:canTradeWithPlayer()
    if ok then
        local otherplayer = randomValidPlayer(game, function (player)
            return game:canTradeWithPlayer(player)
        end)
        local mycards = randomPlayerResCards(game, game.player)
        local theircards = randomPlayerResCards(game, otherplayer)
        game:tradeWithPlayer(otherplayer, mycards, theircards)
        msg = ('tradeWithPlayer(%s, %s, %s)'):format(otherplayer,
                                                     fmtrescards(mycards),
                                                     fmtrescards(theircards))
    end
    return ok, msg
end

function actions.tradeWithHarbor (game)
    local ok, msg = game:canTradeWithHarbor()
    if ok then
        local mycards, n = randomPlayerResCardsForMaritimeTrade(game, game.player)
        if n == 0 then
            return false, "could not create mycards"
        end
        local theircards = randomResCardsFromBank(game, n)
        if theircards == nil then
            return false, "could not create theircards"
        end
        ok, msg = game:canTradeWithHarbor(mycards, theircards)
        if ok then
            game:tradeWithHarbor(mycards, theircards)
            msg = ('tradeWithHarbor(%s, %s)'):format(fmtrescards(mycards),
                                                     fmtrescards(theircards))
        end
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

function actions.buildSettlement (game)
    local ok, msg = game:canBuildSettlement()
    if ok then
        local vertex = randomValidVertex(game, function (vertex)
            return game:canBuildSettlement(vertex)
        end)
        if vertex == nil then
            ok = false
            msg = "no potential vertices found"
        else
            game:buildSettlement(vertex)
            msg = ('buildSettlement(%s)'):format(display(vertex))
        end
    end
    return ok, msg
end

function actions.buildCity (game)
    local ok, msg = game:canBuildCity()
    if ok then
        local vertex = randomValidVertex(game, function (vertex)
            return game:canBuildCity(vertex)
        end)
        if vertex == nil then
            ok = false
            msg = "no potential vertices found"
        else
            game:buildCity(vertex)
            msg = ('buildCity(%s)'):format(display(vertex))
        end
    end
    return ok, msg
end

function actions.buyDevelopmentCard (game)
    local ok, msg = game:canBuyDevelopmentCard()
    if ok then
        local kind = game:buyDevelopmentCard()
        msg = ('buyDevelopmentCard() -> %s'):format(kind)
    end
    return ok, msg
end

function actions.playKnightCard (game)
    local ok, msg = game:canPlayKnightCard()
    if ok then
        game:playKnightCard()
        msg = 'playKnightCard()'
    end
    return ok, msg
end

function actions.playRoadBuildingCard (game)
    local ok, msg = game:canPlayRoadBuildingCard()
    if ok then
        game:playRoadBuildingCard()
        msg = 'playRoadBuildingCard()'
    end
    return ok, msg
end

function actions.playYearOfPlentyCard (game)
    local ok, msg = game:canPlayYearOfPlentyCard()
    if ok then
        local rescards = randomResCardsFromBank(game, 2)
        if rescards == nil then
            return false, "could not create rescards"
        end
        game:playYearOfPlentyCard(rescards)
        msg = ('playYearOfPlentyCard(%s)'):format(fmtrescards(rescards))
    end
    return ok, msg
end

function actions.playMonopolyCard (game)
    local ok, msg = game:canPlayMonopolyCard()
    if ok then
        local res = randomResource(game)
        game:playMonopolyCard(res)
        msg = ('playMonopolyCard(%s)'):format(res)
    end
    return ok, msg
end

local function run (i, args, report)
    local game = Game:new()

    local actionKeys = TableUtils:sortedKeys(actions)

    for j = 1, args.ncalls do
        local actionKey = TableUtils:sample(actionKeys)

        local ok, msg = actions[actionKey](game)

        if msg == nil then
            msg = ('(no message given by %q)'):format(actionKey)
        end

        if ok then
            game:validate()
            if args.v >= 1 then
                if game.winner ~= nil then
                    msg = msg .. ' / Winner is ' .. game.winner
                end
                printSuccess(i, j, msg)
            end
            report.successes = (report.successes or 0) + 1
            if game.winner ~= nil then
                break
            end
        else
            msg = actionKey .. '(...) - ' .. msg
            if args.v >= 2 then
                printFailure(i, j, msg)
            end
            report.failures = (report.failures or 0) + 1
        end
    end
end

local parser = argparse("fuzzy", "Catan fuzzy tester")
parser:option("--seed", "Pseudo-random number generator seed.", os.time())
parser:option("--ncalls", "Number of call attempts per game.", 50000)
parser:option("--ngames", "Number of games.", 1)
parser:flag("-v", "Verbosity level."):count"*"

local args = parser:parse()

print('Seed: ' .. args.seed)
math.randomseed(args.seed)

local timeBefore = os.clock()

local report = {}

for i = 1, args.ngames do
    run(i, args, report)
end

do
    local timeAfter = os.clock()
    local timeDiff = timeAfter - timeBefore
    print(('Elapsed time: %f s'):format(timeDiff))
end

do
    local successes = report.successes or 0
    local failures = report.failures or 0
    local total = successes + failures
    print(('Number of calls: %d'):format(total))
    if args.v >= 1 and total ~= 0 then
        print(('Success rate: %.2f %% (%d)'):format(100 * successes / total, successes))
        print(('Failure rate: %.2f %% (%d)'):format(100 * failures / total, failures))
    end
end
