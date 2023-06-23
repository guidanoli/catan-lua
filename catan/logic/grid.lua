-- Source: https://www.redblobgames.com/grids/parts/#hexagons

local CatanSchema = require "catan.logic.schema"

local Face = CatanSchema.Face
local Edge = CatanSchema.Edge
local Vertex = CatanSchema.Vertex

local grid = {}

function grid:face (q, r)
    return Face:new{q = q, r = r}
end

function grid:edge (q, r, e)
    return Edge:new{q = q, r = r, e = e}
end

function grid:vertex (q, r, v)
    return Vertex:new{q = q, r = r, v = v}
end

function grid:unpack (x)
    return x.q, x.r, x.v or x.e
end

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
    error"no edge in-between"
end

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
