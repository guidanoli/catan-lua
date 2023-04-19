local TableUtils = require "util.table"

local Default = require "catan.logic.default"
local Hex = require "catan.logic.hex"
local FaceMap = require "catan.logic.facemap"
local VertexMap = require "catan.logic.facemap"

local Game = {}
Game.__index = Game

function Game:new (players, t)
    if t == nil then t = Default end
    local game = setmetatable({}, self)
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
    -- TODO: create the rest of the fields
    return game
end

function Game:_setPlayers (players, t)
    assert(TableUtils:isArray(players))
    assert(TableUtils:isContainedIn(players, t.players))
    assert(#players >= 3)
    self.players = players
end

function Game:_createHexMap (t)
    local hexes = Hex:arrayFrom(t.terrain)
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

return Game