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

function Grid:edgeInBetween (vertex1, vertex2)
    local edges1 = self:protrudingEdges(Grid:unpack(vertex1))
    local edges2 = self:protrudingEdges(Grid:unpack(vertex2))
    for i, edge1 in ipairs(edges1) do
        for j, edge2 in ipairs(edges2) do
            if self:edgeEq(edge1, edge2) then
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
