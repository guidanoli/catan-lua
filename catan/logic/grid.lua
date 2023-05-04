-- Source: https://www.redblobgames.com/grids/parts/#hexagons

local Grid = {}

function Grid:face (q, r)
    return {q = q, r = r}
end

function Grid:faceEq (face1, face2)
    return face1.q == face2.q and
           face1.r == face2.r
end

function Grid:edge (q, r, e)
    return {q = q, r = r, e = e}
end

function Grid:edgeEq (edge1, edge2)
    return edge1.q == edge2.q and
           edge1.r == edge2.r and
           edge1.e == edge2.e
end

function Grid:vertex (q, r, v)
    return {q = q, r = r, v = v}
end

function Grid:vertexEq (vertex1, vertex2)
    return vertex1.q == vertex2.q and
           vertex1.r == vertex2.r and
           vertex1.v == vertex2.v
end

function Grid:unpack (x)
    return x.q, x.r, x.v or x.e
end

function Grid:neighbors (face)
    local q, r = self:unpack(face)
    return {
        self:face(q, r+1),
        self:face(q+1, r),
        self:face(q+1, r-1),
        self:face(q, r-1),
        self:face(q-1, r),
        self:face(q-1, r+1),
    }
end

function Grid:borders (face)
    local q, r = self:unpack(face)
    return {
        self:edge(q, r, 'NE'),
        self:edge(q, r, 'NW'),
        self:edge(q, r, 'W'),
        self:edge(q-1, r+1, 'NE'),
        self:edge(q, r+1, 'NW'),
        self:edge(q+1, r, 'W'),
    }
end

function Grid:corners (face)
    local q, r = self:unpack(face)
    return {
        self:vertex(q, r, 'N'),
        self:vertex(q, r-1, 'S'),
        self:vertex(q-1, r+1, 'N'),
        self:vertex(q, r, 'S'),
        self:vertex(q, r+1, 'N'),
        self:vertex(q+1, r-1, 'S'),
    }
end

function Grid:protrudingEdges (vertex)
    local q, r, v = self:unpack(vertex)
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

function Grid:adjacentVertices (vertex)
    local q, r, v = self:unpack(vertex)
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

return Grid