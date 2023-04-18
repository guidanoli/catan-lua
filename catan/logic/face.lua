local Face = {}

function Face:generateFaces ()
    local t = {}
    for q = -2, 2 do
        for r = -2, 2 do
            local z = q + r
            if -2 <= z and z <= 2 then
                table.insert(t, {q = q, r = r})
            end
        end
    end
    return t
end

return Face
