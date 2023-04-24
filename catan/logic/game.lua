local TableUtils = require "util.table"

local Default = require "catan.logic.default"
local FaceMap = require "catan.logic.facemap"
local VertexMap = require "catan.logic.vertexmap"

--------------------------------

local Game = {}
Game.__index = Game

--------------------------------

function Game:new (players, t)
    if t == nil then t = Default end
    local game = setmetatable({}, self)
    game:_init(players, t)
    return game
end

--------------------------------
-- Initialization code
--------------------------------

function Game:_init (players, t)
    game:_setPlayers(players, t)
    game:_createHexMap(t)
    game:_createNumberMap(t)
    game:_createHarborMap(t)
    game.buildmap = {}
    game.roadmap = {}
    game:_placeRobberInDesert()
    game:_createDevelopmentCards()
    game:_createResourceCards()
    game:_createArmies()
    game:_createDrawPile(t)
    game:_createBank(t)
end

function Game:_setPlayers (players, t)
    assert(TableUtils:isArray(players))
    assert(TableUtils:isContainedIn(players, t.players))
    assert(#players >= 3)
    self.players = players
end

function Game:_createHexMap (t)
    local hexes = {}
    for kind, count in pairs(t.terrain) do
        for i = 1, count do
            table.insert(hexes, kind)
        end
    end
    TableUtils:shuffleInPlace(hexes)
    self.hexmap = {}
    for i, hex in ipairs(hexes) do
        FaceMap:set(self.hexmap, t.terrainFaces[i], hex)
    end
end

function Game:_createNumberMap (t)
    local i = 1
    self.numbermap = {}
    for _, face in ipairs(t.terrainFaces) do
        local hex = FaceMap:get(self.hexmap, face)
        if hex ~= 'desert' then
            FaceMap:set(self.numbermap, face, t.numbers[i])
            i = i + 1
        end
    end
end

function Game:_createHarborMap (t)
    self.harbormap = {}
    for _, harbor in ipairs(t.harbors) do
        local face = {q = harbor.q, r = harbor.r}
        local vector = {kind = harbor.vk, face = face}
        VertexMap:set(self.harbormap, vector, harbor.hk)
    end
end

function Game:_placeRobberInDesert ()
    FaceMap:iter(self.hexmap, function (q, r, hex)
        if hex == 'desert' then
            self.robber = {q = q, r = r}
            return true -- stop iteration
        end
    end)
end

function Game:_createDevelopmentCards ()
    self.devcards = {}
    for _, player in ipairs(self.players) do
        self.devcards[player] = {}
    end
end

function Game:_createResourceCards ()
    self.rescards = {}
    for _, player in ipairs(self.players) do
        self.rescards[player] = {}
    end
end

function Game:_createArmies ()
    self.armies = {}
    for _, player in ipairs(self.players) do
        self.armies[player] = 0
    end
end

function Game:_createDrawPile (t)
    self.drawpile = {}
    for devcard, count in pairs(t.devcards) do
        for i = 1, count do
            table.insert(drawpile, devcard)
        end
    end
    TableUtils:shuffleInPlace(self.drawpile)
end

function Game:_createBank (t)
    self.bank = {}
    for rescard, count in pairs(t.rescards) do
        self.bank[rescard] = count
    end
end

--------------------------------

return Game
