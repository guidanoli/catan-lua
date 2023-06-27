-- Catan schemas

local SemanticVersion = require "util.semver"

local s = require "util.schema"

local m = {}

local Int = s.Integer()

m.VERSION = SemanticVersion:new(2)

m.Phase = s.Enum{
    'placingInitialSettlement',
    'placingInitialRoad',
    'playingTurns',
    'discarding',
    'movingRobber',
    'choosingVictim',
}

m.D6 = s.Enum{
    1,
    2,
    3,
    4,
    5,
    6,
}

m.Dice = s.Array(m.D6, 2)

m.Face = s.Struct{
    q = Int,
    r = Int,
}

m.VertexKind = s.Enum{
    'N',
    'S',
}

m.Vertex = s.Struct{
    q = Int,
    r = Int,
    v = m.VertexKind,
}

m.EdgeKind = s.Enum{
    'NW',
    'W',
    'NE',
}

m.Edge = s.Struct{
    q = Int,
    r = Int,
    e = m.EdgeKind,
}

m.Hex = s.Enum{
    'hills',
    'forest',
    'mountains',
    'fields',
    'pasture',
    'desert',
}

m.Player = s.Enum{
    'red',
    'blue',
    'yellow',
    'white'
}

m.BuildingKind = s.Enum{
    'settlement',
    'city',
}

m.Building = s.Struct{
    kind = m.BuildingKind,
    player = m.Player,
}

m.Harbor = s.Enum{
    'generic',
    'brick',
    'lumber',
    'ore',
    'grain',
    'wool',
}

m.DevelopmentCardKind = s.Enum{
    'knight',
    'roadbuilding',
    'yearofplenty',
    'monopoly',
    'victorypoint',
}

m.DevelopmentCard = s.Struct{
    kind = m.DevelopmentCardKind,
    roundBought = Int,
    roundPlayed = s.Option(Int),
}

m.ResourceCard = s.Enum{
    'brick',
    'lumber',
    'ore',
    'grain',
    'wool',
}

m.ResourceCardHistogram = s.Map(m.ResourceCard, Int)

local function FaceMap (t)
    return s.Map(Int, s.Map(Int, t))
end

local function VertexMap (t)
    return s.Map(Int, s.Map(Int, s.Map(m.VertexKind, t)))
end

local function EdgeMap (t)
    return s.Map(Int, s.Map(Int, s.Map(m.EdgeKind, t)))
end

local function PlayerMap (t)
    return s.Map(m.Player, t)
end

m.SemanticVersion = s.Struct{
    major = Int,
    minor = Int,
    patch = Int,
}

m.GameState = s.Struct{
    version = m.SemanticVersion,
    -- common (dynamic)
    phase = m.Phase,
    round = Int,
    dice = s.Option(m.Dice),
    -- players (static)
    players = s.Array(m.Player),
    -- map (static)
    hexmap = FaceMap(m.Hex),
    numbermap = FaceMap(Int),
    harbormap = VertexMap(m.Harbor),
    -- map (dynamic)
    buildmap = VertexMap(m.Building),
    roadmap = EdgeMap(m.Player),
    robber = m.Face,
    -- players (dynamic)
    player = m.Player,
    devcards = PlayerMap(s.Array(m.DevelopmentCard)),
    rescards = PlayerMap(m.ResourceCardHistogram),
    roadcredit = PlayerMap(Int),
    longestroad = s.Option(m.Player),
    largestarmy = s.Option(m.Player),
    lastdiscard = PlayerMap(Int),
    -- free cards (dynamic)
    drawpile = s.Array(m.DevelopmentCardKind),
    bank = m.ResourceCardHistogram,
}

return m
