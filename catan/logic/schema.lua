-- Catan game state schema v0.1

local schema = require "util.schema"

local Face = schema.Struct{
    x = "number",
    y = "number",
}

local Vertex = schema.Struct{
    kind = schema.Enum{
        'left',
        'right',
    },
    face = Face,
}

local Edge = schema.Struct{
    kind = schema.Enum{
        'northwest',
        'north',
        'northeast',
    },
    face = Face,
}

local Hex = schema.Struct{
    kind = schema.Enum{
        'hills',
        'forest',
        'mountains',
        'fields',
        'pasture',
        'desert',
    },
    face = Face,
}

local NumberToken = schema.Struct{
    face = Face,
    number = "number",
}

local Robber = schema.Struct{
    face = Face,
}

local Player = schema.Enum{
    'red',
    'blue',
    'yellow',
    'white',
}

local Settlement = schema.Struct{
    player = Player,
    vertex = schema.Option(Vertex),
}

local City = schema.Struct{
    player = Player,
    vertex = schema.Option(Vertex),
}

local Road = schema.Struct{
    player = Player,
    edge = schema.Option(Edge),
}

local Harbor = schema.Struct{
    kind = schema.Enum{
        'generic',
        'brick',
        'lumber',
        'ore',
        'grain',
        'wool',
    },
    vertex = Vertex,
}

local DevelopmentCard = schema.Struct{
    kind = schema.Enum{
        'knight',
        'roadbuilding',
        'yearofplenty',
        'monopoly',
        'victorypoint',
    },
    player = schema.Option(Player),
    used = "boolean",
}

local ResourceCard = schema.Struct{
    kind = schema.Enum{
        'brick',
        'lumber',
        'ore',
        'grain',
        'wool',
    },
    player = schema.Option(Player),
}

local SpecialCard = schema.Struct{
    kind = schema.Enum{
        'largestroad',
        'largestarmy',
    },
    player = schema.Option(Player),
}

local CardID = "number"

return schema.Struct{
    hexes = schema.Array(Hex),
    numbertokens = schema.Array(NumberToken),
    robber = Robber,
    settlements = schema.Array(Settlement),
    cities = schema.Array(City),
    roads = schema.Array(Road),
    harbors = schema.Array(Harbor),
    developmentcards = schema.Array(DevelopmentCard),
    resourcecards = schema.Array(ResourceCard),
    specialcards = schema.Array(SpecialCard),
    drawpile = schema.Array(CardID),
}
