-- Catan game state schema v1.6

local schema = require "util.schema"

local Phase = schema.Enum{
    'settingUp',
    'idle',
    'discardingHalf',
    'placingRobber',
    'choosingVictim',
}

local Face = schema.Struct{
    q = 'number',
    r = 'number',
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

local Player = schema.Value'string'

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

local DevelopmentCards = schema.Mapping(DevelopmentCard, 'number')

local ResourceCard = schema.Enum{
    'brick',
    'lumber',
    'ore',
    'grain',
    'wool',
}

local ResourceCards = schema.Mapping(ResourceCard, 'number')

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
    return schema.Mapping(Player, t)
end

return schema.Struct{
    -- meta
    phase = Phase,
    round = 'number',
    -- players (static)
    players = schema.Array(Player),
    -- map (static)
    hexmap = FaceMapping(Hex),
    numbermap = FaceMapping'number',
    harbormap = VertexMapping(Harbor),
    -- map (dynamic)
    buildmap = VertexMapping(Building),
    roadmap = EdgeMapping(Player),
    robber = Face,
    -- players (dynamic)
    player = Player,
    armies = PlayerMapping'number',
    devcards = PlayerMapping(schema.Array(DevelopmentCards)),
    rescards = PlayerMapping(schema.Array(ResourceCards)),
    largestroad = schema.Option(Player),
    largestarmy = schema.Option(Player),
    -- free cards
    drawpile = schema.Array(DevelopmentCard),
    bank = ResourceCards,
}
