-- Catan game state schema

local face = {
    x = "number",
    y = "number",
}

local vertextype = {
    left = true,
    right = true,
}

local vertex = {
    face = face,
    vertextype = vertextype,
}

local edgetype = {
    northwest = true,
    north = true,
    northeast = true,
}

local edge = {
    face = face,
    edgetype = edgetype,
}

local hextype = {
    hills = true,
    forest = true,
    mountains = true,
    fields = true,
    pasture = true,
    desert = true,
}

local hex = {
    face = face,
    hextype = hextype,
}

local numbertoken = {
    face = face,
    number = "number",
}

local robber = {
    face = face,
}

local player = {
    red = true,
    blue = true,
    yellow = true,
    white = true,
}

local placed_settlement = {
    player = player,
    vertex = vertex,
}

local unplaced_settlement = {
    player = player,
}

local settlement = {
    [placed_settlement] = true,
    [unplaced_settlement] = true,
}

local placed_city = {
    player = player,
    vertex = vertex,
}

local unplaced_city = {
    player = player,
}

local city = {
    [placed_city] = true,
    [unplaced_city] = true,
}

local placed_road = {
    player = player,
    edge = edge,
}

local unplaced_road = {
    player = player,
}

local road = {
    [placed_road] = true,
    [unplaced_road] = true,
}

local harbortype = {
    generic = true,
    brick = true,
    lumber = true,
    ore = true,
    grain = true,
    wool = true,
}

local harbor = {
    harbortype = harbortype,
    vertex = vertex,
}

local developmentcardtype = {
    knight = true,
    roadbuilding = true,
    yearofplenty = true,
    monopoly = true,
    victorypoint = true,
}

local drawn_developmentcard = {
    developmentcardtype = developmentcardtype,
    player = player,
    used = "boolean",
}

local undrawn_developmentcard = {
    developmentcardtype = developmentcardtype,
}

local developmentcard = {
    [drawn_developmentcard] = true,
    [undrawn_developmentcard] = true,
}

local resourcetype = {
    brick = true,
    lumber = true,
    ore = true,
    grain = true,
    wool = true,
}

local drawn_resourcecard = {
    resourcetype = resourcetype,
    player = player,
}

local undrawn_resourcecard = {
    resourcetype = resourcetype,
}

local resourcecard = {
    [drawn_resourcecard] = true,
    [undrawn_resourcecard] = true,
}

local specialcardtype = {
    largestroad = true,
    largestarmy = true,
}

local acquired_specialcard = {
    specialcardtype = specialcardtype,
    player = player,
}

local unacquired_specialcard = {
    specialcardtype = specialcardtype,
}

local specialcard = {
    [acquired_specialcard] = true,
    [unacquired_specialcard] = true,
}

local drawpile = { "number" }

return {
    hexes = { hex },
    numbertokens = { numbertoken },
    robber = robber,
    settlements = { settlements },
    cities = { city },
    roads = { road },
    harbors = { harbor },
    developmentcards = { developmentcard },
    resourcecards = { resourcecard },
    specialcards = { specialcard },
    drawpile = drawpile,
}
