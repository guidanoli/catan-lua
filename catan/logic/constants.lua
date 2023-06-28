---
-- Constants for the Catan back-end logic.
--
-- @module catan.logic.constants

local Grid = require "catan.logic.grid"

-- Note: We define some tables twice to avoid LDoc from rendering
-- the fields of the real table.

local constants = {}

---
-- List of terrain faces.
constants.terrainFaces = {}
constants.terrainFaces = {
    Grid:face(0, -2),
    Grid:face(-1, -1),
    Grid:face(-2, 0),
    Grid:face(-2, 1),
    Grid:face(-2, 2),
    Grid:face(-1, 2),
    Grid:face(0, 2),
    Grid:face(1, 1),
    Grid:face(2, 0),
    Grid:face(2, -1),
    Grid:face(2, -2),
    Grid:face(1, -2),
    Grid:face(0, -1),
    Grid:face(-1, 0),
    Grid:face(-1, 1),
    Grid:face(0, 1),
    Grid:face(1, 0),
    Grid:face(1, -1),
    Grid:face(0, 0),
}

---
-- Number of hexes per type.
-- @tfield number hills 3
-- @tfield number forest 4
-- @tfield number mountains 3
-- @tfield number fields 4
-- @tfield number pasture 4
-- @tfield number desert 1
constants.terrain = {
    hills = 3,
    forest = 4,
    mountains = 3,
    fields = 4,
    pasture = 4,
    desert = 1,
}

---
-- List of number tokens, in the same order as @{terrainFaces}.
constants.numbers = {}
constants.numbers = {
    5, 2, 6, 3, 8, 10,
    9, 12, 11, 4, 8, 10,
    9, 4, 5, 6, 3, 11,
}

local function Harbor(kind, q, r, v)
    return {
        kind = kind,
        vertex = Grid:vertex(q, r, v),
    }
end

---
-- List of harbors.
-- Each harbor is a table containing fields `vertex` and `kind`.
constants.harbors = {}
constants.harbors = {
    Harbor('generic', 0, -3, 'S'),
    Harbor('generic', 0, -2, 'N'),
    Harbor('grain', 1, -2, 'N'),
    Harbor('grain', 2, -3, 'S'),
    Harbor('ore', 2, -1, 'N'),
    Harbor('ore', 3, -2, 'S'),
    Harbor('generic', 3, -1, 'S'),
    Harbor('generic', 2, 1, 'N'),
    Harbor('wool', 1, 2, 'N'),
    Harbor('wool', 1, 1, 'S'),
    Harbor('generic', -1, 3, 'N'),
    Harbor('generic', -1, 2, 'S'),
    Harbor('generic', -2, 2, 'S'),
    Harbor('generic', -3, 3, 'N'),
    Harbor('brick', -3, 2, 'N'),
    Harbor('brick', -2, 0, 'S'),
    Harbor('lumber', -2, 0, 'N'),
    Harbor('lumber', -1, -2, 'S'),
}

---
-- List of valid player names.
constants.players = {}
constants.players = {
    'red',
    'blue',
    'yellow',
    'white',
}

---
-- Number of development cards per type.
-- @tfield number knight 14
-- @tfield number roadbuilding 2
-- @tfield number yearofplenty 2
-- @tfield number monopoly 2
-- @tfield number victorypoint 5
constants.devcards = {
    knight = 14,
    roadbuilding = 2,
    yearofplenty = 2,
    monopoly = 2,
    victorypoint = 5,
}

---
-- Number of resource cards per type.
-- @tfield number brick 19
-- @tfield number lumber 19
-- @tfield number ore 19
-- @tfield number grain 19
-- @tfield number wool 19
constants.rescards = {
    brick = 19,
    lumber = 19,
    ore = 19,
    grain = 19,
    wool = 19,
}

---
-- Number of roads per player.
constants.roads = 15

---
-- Number of settlements per player.
constants.settlements = 5

---
-- Number of cities per player.
constants.cities = 4

return constants
