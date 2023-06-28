---
-- Hexagonal grid parts and relations
--
-- We use the axial coordinate system, since it is the simplest to implement.
-- We'll use letters `q` and `r` for integers, and `e` and `v` for strings.
--
-- In this system, faces are located by a tuple `<q,r>`.
--
-- Each edge is either northeast, northwest or west to some face, thus `<q,r,e>`,
-- where `e` is either `"NE"` (for northeast), `"NW"` (for northwest), or `"W"` (for west).
--
-- Each vertex is either north or south to some face, thus `<q,r,v>`,
-- where `v` is either `"N"` (for north), or `"S"` (for south).
--
-- @module catan.logic.grid

local CatanSchema = require "catan.logic.schema"

local Face = CatanSchema.Face
local Edge = CatanSchema.Edge
local Vertex = CatanSchema.Vertex

local grid = {}

---
-- Create a face from axial coordinates `<q,r>`
-- @tparam number q
-- @tparam number r
-- @treturn Face
function grid:face (q, r)
    return Face:new{q = q, r = r}
end

---
-- Create an edge from axial coordinates `<q,r,e>`
-- @tparam number q
-- @tparam number r
-- @tparam string e
-- @treturn Edge
function grid:edge (q, r, e)
    return Edge:new{q = q, r = r, e = e}
end

---
-- Create a vertex from axial coordinates `<q,r,v>`
-- @tparam number q
-- @tparam number r
-- @tparam string v
-- @treturn Vertex
function grid:vertex (q, r, v)
    return Vertex:new{q = q, r = r, v = v}
end

---
-- Get axial coordinates of grid parts
-- @tparam Face|Edge|Vertex x grid part
-- @treturn number q
-- @treturn number r
-- @treturn ?string e or v
function grid:unpack (x)
    return x.q, x.r, x.e or x.v
end

---
-- Get list of 6 edges that border face `<q,r>`
-- @tparam number q
-- @tparam number r
-- @treturn {Edge,...}
function grid:borders (q, r)
    return {
        self:edge(q, r, 'NE'),
        self:edge(q, r, 'NW'),
        self:edge(q, r, 'W'),
        self:edge(q-1, r+1, 'NE'),
        self:edge(q, r+1, 'NW'),
        self:edge(q+1, r, 'W'),
    }
end

---
-- Get list of 6 vertices that corner face `<q,r>`
-- @tparam number q
-- @tparam number r
-- @treturn {Vertex,...}
function grid:corners (q, r)
    return {
        self:vertex(q, r, 'N'),
        self:vertex(q, r-1, 'S'),
        self:vertex(q-1, r+1, 'N'),
        self:vertex(q, r, 'S'),
        self:vertex(q, r+1, 'N'),
        self:vertex(q+1, r-1, 'S'),
    }
end

---
-- Get list of 3 faces that touch vertex `<q,r,v>`
-- @tparam number q
-- @tparam number r
-- @tparam string v
-- @treturn {Face,...}
function grid:touches (q, r, v)
    if v == 'N' then
        return {
            self:face(q+1, r-1),
            self:face(q, r),
            self:face(q, r-1),
        }
    else
        assert(v == 'S')
        return {
            self:face(q, r),
            self:face(q, r+1),
            self:face(q-1, r+1),
        }
    end
end

---
-- Get list of 3 edges that protrude vertex `<q,r,v>`
-- @tparam number q
-- @tparam number r
-- @tparam string v
-- @treturn {Edge,...}
function grid:protrudingEdges (q, r, v)
    if v == 'N' then
        return {
            self:edge(q, r, 'NE'),
            self:edge(q+1, r-1, 'W'),
            self:edge(q, r, 'NW'),
        }
    else
        assert(v == 'S')
        return {
            self:edge(q, r+1, 'NW'),
            self:edge(q-1, r+1, 'NE'),
            self:edge(q, r+1, 'W'),
        }
    end
end

---
-- Get list of 3 vertices that are adjacent to vertex `<q,r,v>`
-- @tparam number q
-- @tparam number r
-- @tparam string v
-- @treturn {Vertex,...}
function grid:adjacentVertices (q, r, v)
    if v == 'N' then
        return {
            self:vertex(q+1, r-2, 'S'),
            self:vertex(q, r-1, 'S'),
            self:vertex(q+1, r-1, 'S'),
        }
    else
        assert(v == 'S')
        return {
            self:vertex(q-1, r+1, 'N'),
            self:vertex(q-1, r+2, 'N'),
            self:vertex(q, r+1, 'N'),
        }
    end
end

---
-- Get list of 2 faces joined by edge `<q,r,e>`
-- @tparam number q
-- @tparam number r
-- @tparam string e
-- @treturn {Face,...}
function grid:joins (q, r, e)
    if e == 'NE' then
        return {
            self:face(q+1, r-1),
            self:face(q, r),
        }
    elseif e == 'NW' then
        return {
            self:face(q, r),
            self:face(q, r-1),
        }
    else
        assert(e == 'W')
        return {
            self:face(q, r),
            self:face(q-1, r),
        }
    end
end

---
-- Get list of 2 vertices that are endpoints of edge `<q,r,e>`
-- @tparam number q
-- @tparam number r
-- @tparam string e
-- @treturn {Vertex,...}
function grid:endpoints (q, r, e)
    if e == 'NE' then
        return {
            self:vertex(q+1, r-1, 'S'),
            self:vertex(q, r, 'N'),
        }
    elseif e == 'NW' then
        return {
            self:vertex(q, r, 'N'),
            self:vertex(q, r-1, 'S'),
        }
    else
        assert(e == 'W')
        return {
            self:vertex(q, r-1, 'S'),
            self:vertex(q-1, r+1, 'N'),
        }
    end
end

---
-- Get list of 3 edge-vertex pairs that stem from vertex `<q,r,v>`
-- @tparam number q
-- @tparam number r
-- @tparam string v
-- @treturn {{edge=Edge,vertex=Vertex},...}
function grid:adjacentEdgeVertexPairs (q, r, v)
    if v == 'N' then
        return {
            { edge = self:edge(q, r, 'NE'), vertex = self:vertex(q+1, r-1, 'S') },
            { edge = self:edge(q+1, r-1, 'W'), vertex = self:vertex(q+1, r-2, 'S') },
            { edge = self:edge(q, r, 'NW'), vertex = self:vertex(q, r-1, 'S') },
        }
    else
        assert(v == 'S')
        return {
            { edge = self:edge(q, r+1, 'NW'), vertex = self:vertex(q, r+1, 'N') },
            { edge = self:edge(q-1, r+1, 'NE'), vertex = self:vertex(q-1, r+1, 'N') },
            { edge = self:edge(q, r+1, 'W'), vertex = self:vertex(q-1, r+2, 'N') },
        }
    end
end

---
-- Get edge in between two vertices, if there is any
-- @tparam Vertex vertex1
-- @tparam Vertex vertex2
-- @treturn ?Edge
function grid:edgeInBetween (vertex1, vertex2)
    local edges1 = self:protrudingEdges(self:unpack(vertex1))
    local edges2 = self:protrudingEdges(self:unpack(vertex2))
    for i, edge1 in ipairs(edges1) do
        for j, edge2 in ipairs(edges2) do
            if Edge:eq(edge1, edge2) then
                return edge1
            end
        end
    end
end

---
-- Get orientation of edge in relation to a face it borders
-- @tparam Face face
-- @tparam Edge edge
-- @treturn 'E'|'NE'|'NW'|'W'|'SW'|'SE' orientation
function grid:edgeOrientationInFace (face, edge)
    local q, r, e = self:unpack(edge)
    if q == face.q and r == face.r then
        assert(e == 'NE' or e == 'NW' or e == 'W')
        return e
    else
        if e == 'NE' then
            assert(q == face.q - 1)
            assert(r == face.r + 1)
            return 'SW'
        elseif e == 'NW' then
            assert(q == face.q)
            assert(r == face.r + 1)
            return 'SE'
        else
            assert(q == face.q + 1)
            assert(r == face.r)
            assert(e == 'W')
            return 'E'
        end
    end
end

return grid
