-- Source: https://www.redblobgames.com/grids/parts/#hexagons

local CatanSchema = require "catan.logic.schema"

local Grid = {}

function Grid:face (q, r)
    return CatanSchema.Face:new{q = q, r = r}
end

function Grid:edge (q, r, e)
    return CatanSchema.Edge:new{q = q, r = r, e = e}
end

function Grid:vertex (q, r, v)
    return CatanSchema.Vertex:new{q = q, r = r, v = v}
end

function Grid:unpack (x)
    return x.q, x.r, x.v or x.e
end

function Grid:neighbors (q, r)
    return {
        self:face(q, r+1),
        self:face(q+1, r),
        self:face(q+1, r-1),
        self:face(q, r-1),
        self:face(q-1, r),
        self:face(q-1, r+1),
    }
end

function Grid:borders (q, r)
    return {
        self:edge(q, r, 'NE'),
        self:edge(q, r, 'NW'),
        self:edge(q, r, 'W'),
        self:edge(q-1, r+1, 'NE'),
        self:edge(q, r+1, 'NW'),
        self:edge(q+1, r, 'W'),
    }
end

function Grid:corners (q, r)
    return {
        self:vertex(q, r, 'N'),
        self:vertex(q, r-1, 'S'),
        self:vertex(q-1, r+1, 'N'),
        self:vertex(q, r, 'S'),
        self:vertex(q, r+1, 'N'),
        self:vertex(q+1, r-1, 'S'),
    }
end

function Grid:touches (q, r, v)
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

function Grid:protrudingEdges (q, r, v)
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

function Grid:adjacentVertices (q, r, v)
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

function Grid:joins (q, r, e)
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

function Grid:endpoints (q, r, e)
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

function Grid:adjacentEdgeVertexPairs (q, r, v)
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

function Grid:edgeInBetween (vertex1, vertex2)
    local edges1 = self:protrudingEdges(Grid:unpack(vertex1))
    local edges2 = self:protrudingEdges(Grid:unpack(vertex2))
    for i, edge1 in ipairs(edges1) do
        for j, edge2 in ipairs(edges2) do
            if CatanSchema.Edge:eq(edge1, edge2) then
                return edge1
            end
        end
    end
    error"no edge in-between"
end

function Grid:edgeOrientationInFace (face, edge)
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

return Grid
