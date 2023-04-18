local Face = {}

function Face:generateFaces ()
    local t = {}
    for x = -2, 2 do
        for y = -2, 2 do
            local z = x + y
            if -2 <= z and z <= 2 then
                table.insert(t, {x = x, y = y})
            end
        end
    end
    return t
end

return Face
