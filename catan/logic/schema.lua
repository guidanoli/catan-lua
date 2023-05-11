-- Catan schemas v2.0

local s = require "util.schema"

local m = {}

m.Phase = s.Enum{
    'placingInitialSettlement',
    'placingInitialRoad',
}

m.Face = s.Struct{
    q = s.Type'number',
    r = s.Type'number',
}

m.VertexKind = s.Enum{
    'N',
    'S',
}

m.Vertex = s.Struct{
    q = s.Type'number',
    r = s.Type'number',
    v = m.VertexKind,
}

m.EdgeKind = s.Enum{
    'NW',
    'W',
    'NE',
}

m.Edge = s.Struct{
    q = s.Type'number',
    r = s.Type'number',
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
    used = s.Type'boolean',
    round = s.Type'number',
}

m.ResourceCard = s.Enum{
    'brick',
    'lumber',
    'ore',
    'grain',
    'wool',
}

local ResourceCardHistogram = s.Map(m.ResourceCard, s.Type'number')

local function FaceMap (t)
    return s.Map(s.Type'number', s.Map(s.Type'number', t))
end

local function VertexMap (t)
    return s.Map(s.Type'number', s.Map(s.Type'number', s.Map(m.VertexKind, t)))
end

local function EdgeMap (t)
    return s.Map(s.Type'number', s.Map(s.Type'number', s.Map(m.EdgeKind, t)))
end

local function PlayerMap (t)
    return s.Map(m.Player, t)
end

m.GameState = s.Struct{
    -- meta
    phase = m.Phase,
    round = s.Type'number',
    -- players (static)
    players = s.Array(m.Player),
    -- map (static)
    hexmap = FaceMap(m.Hex),
    numbermap = FaceMap(s.Type'number'),
    harbormap = VertexMap(m.Harbor),
    -- map (dynamic)
    buildmap = VertexMap(m.Building),
    roadmap = EdgeMap(m.Player),
    robber = m.Face,
    -- players (dynamic)
    player = m.Player,
    devcards = PlayerMap(s.Array(m.DevelopmentCard)),
    rescards = PlayerMap(ResourceCardHistogram),
    longestroad = s.Option(m.Player),
    largestarmy = s.Option(m.Player),
    -- free cards
    drawpile = s.Array(m.DevelopmentCardKind),
    bank = ResourceCardHistogram,
}

return m
