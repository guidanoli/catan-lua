local TableUtils = require "util.table"

local Constants = require "catan.logic.constants"
local FaceMap = require "catan.logic.facemap"
local VertexMap = require "catan.logic.vertexmap"

--------------------------------

local Game = {}
Game.__index = Game

--------------------------------
-- Constructor
--------------------------------

function Game:new (players)
    players = players or Constants.players
    local game = setmetatable({}, self)
    game:_init(players)
    return game
end

--------------------------------
-- Initialization code
--------------------------------

function Game:_init (players)
    self:_setPlayers(players)
    self:_createHexMap()
    self:_createNumberMap()
    self:_createHarborMap()
    self.buildmap = {}
    self.roadmap = {}
    self:_placeRobberInDesert()
    self:_createDevelopmentCards()
    self:_createResourceCards()
    self:_createArmies()
    self:_createDrawPile()
    self:_createBank()
end

function Game:_setPlayers (players)
    assert(TableUtils:isArray(players), "players not array")
    assert(TableUtils:isContainedIn(players, Constants.players), "invalid players")
    assert(#players >= 3, "too few players")
    self.players = players
    self.turn = players[1]
end

function Game:_createHexMap ()
    local hexes = {}
    for kind, count in pairs(Constants.terrain) do
        for i = 1, count do
            table.insert(hexes, kind)
        end
    end
    TableUtils:shuffleInPlace(hexes)
    self.hexmap = {}
    for i, hex in ipairs(hexes) do
        FaceMap:set(self.hexmap, Constants.terrainFaces[i], hex)
    end
end

function Game:_createNumberMap ()
    local i = 1
    self.numbermap = {}
    for _, face in ipairs(Constants.terrainFaces) do
        local hex = FaceMap:get(self.hexmap, face)
        if hex ~= 'desert' then
            FaceMap:set(self.numbermap, face, Constants.numbers[i])
            i = i + 1
        end
    end
end

function Game:_createHarborMap ()
    self.harbormap = {}
    for _, harbor in ipairs(Constants.harbors) do
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

function Game:_createDrawPile ()
    self.drawpile = {}
    for devcard, count in pairs(Constants.devcards) do
        for i = 1, count do
            table.insert(self.drawpile, devcard)
        end
    end
    TableUtils:shuffleInPlace(self.drawpile)
end

function Game:_createBank ()
    self.bank = {}
    for rescard, count in pairs(Constants.rescards) do
        self.bank[rescard] = count
    end
end

--------------------------------

return Game
