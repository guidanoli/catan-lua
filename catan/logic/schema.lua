-- Catan game state schema v1.0

local schema = require "util.schema"

local Face = schema.Struct{
    q = "number",
    r = "number",
}

local VertexKind = schema.Enum{
    'N',
    'S',
}

local Vertex = schema.Struct{
    kind = VertexKind,
    face = Face,
}

local EdgeKind = schema.Enum{
    'NW',
    'W',
    'SW',
}

local Edge = schema.Struct{
    kind = EdgeKind,
    face = Face,
}

local Hex = schema.Enum{
    'hills',
    'forest',
    'mountains',
    'fields',
    'pasture',
    'desert',
}

local Player = schema.Enum{
    'red',
    'blue',
    'yellow',
    'white',
}

local Building = schema.Struct{
    kind = schema.Enum{
        'settlement',
        'city',
    },
    player = Player,
}

local Harbor = schema.Enum{
    'generic',
    'brick',
    'lumber',
    'ore',
    'grain',
    'wool',
}

local DevelopmentCard = schema.Enum{
    'knight',
    'roadbuilding',
    'yearofplenty',
    'monopoly',
    'victorypoint',
}

local ResourceCard = schema.Enum{
    'brick',
    'lumber',
    'ore',
    'grain',
    'wool',
}

local function FaceMapping (t)
    return schema.Mapping('number', schema.Mapping('number', t))
end

local function VertexMapping (t)
    return schema.Mapping('number', schema.Mapping('number', schema.Mapping(VertexKind, t)))
end

local function EdgeMapping (t)
    return schema.Mapping('number', schema.Mapping('number', schema.Mapping(EdgeKind, t)))
end

local function PlayerMapping (t)
    return schema.Mapping(Player, schema.Array(t))
end

return schema.Struct{
    -- map (static)
    hexmap = FaceMapping(Hex),
    numbermap = FaceMapping'number',
    harbormap = VertexMapping(Harbor),
    -- map (dynamic)
    buildmap = VertexMapping(Building),
    roadmap = EdgeMapping(Player),
    robber = Face,
    -- player cards
    devcards = PlayerMapping(schema.Array(DevelopmentCard)),
    rescards = PlayerMapping(schema.Array(ResourceCard)),
    largestroad = schema.Option(Player),
    largestarmy = schema.Option(Player),
    -- player armies
    armies = PlayerMapping'number',
    -- free cards
    drawpile = schema.Array(DevelopmentCard),
    bank = schema.Mapping(ResourceCard, 'number'),
}
