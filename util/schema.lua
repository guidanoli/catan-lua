local schema = {}

function schema.Type (t)
    return { 'type', t }
end

function schema.Option (t)
    return { 'option', t }
end

function schema.Enum (t)
    return { 'enum', t }
end

function schema.Struct (t)
    return { 'struct', t }
end

function schema.Array (t)
    return { 'array', t }
end

function schema.Map (k, v)
    return { 'map', k, v }
end

function schema:validate (s, t)
    assert(type(s) == "table", "schema must be table")
    local tag = s[1]
    if tag == 'type' then
        return self:validateType(s, t)
    elseif tag == 'option' then
        return self:validateOption(s, t)
    elseif tag == 'enum' then
        return self:validateEnum(s, t)
    elseif tag == 'struct' then
        return self:validateStruct(s, t)
    elseif tag == 'array' then
        return self:validateArray(s, t)
    elseif tag == 'map' then
        return self:validateMap(s, t)
    else
        error"invalid schema tag"
    end
end

function schema:validateType (s, t)
    local sx = s[2]
    assert(type(sx) == "string", "invalid type")
    return type(t) == sx
end

function schema:validateOption (s, t)
    local sx = s[2]
    assert(sx ~= nil, "missing option")
    return t == nil or self:validate(sx, t)
end

function schema:validateEnum (s, t)
    local sx = s[2]
    assert(type(sx) == "table", "enum must be table")
    for _, v in ipairs(sx) do
        if v == t then
            return true
        end
    end
    return false
end

function schema:validateStruct (s, t)
    if type(t) ~= 'table' then
        return false
    end
    local sx = s[2]
    assert(type(sx) == "table", "struct must be table")
    for k, v in pairs(sx) do
        if not self:validate(v, t[k]) then
            return false
        end
    end
    return true
end

function schema:validateArray (s, t)
    if type(t) ~= 'table' then
        return false
    end
    local sx = s[2]
    assert(sx ~= nil, "missing array element")
    for i, v in ipairs(t) do
        if not self:validate(sx, v) then
            return false
        end
    end
    return true
end

function schema:validateMap (s, t)
    if type(t) ~= 'table' then
        return false
    end
    local sk = s[2]
    local sv = s[3]
    assert(sk ~= nil, "missing map key")
    assert(sv ~= nil, "missing map value")
    for k, v in pairs(t) do
        if not (self:validate(sk, k) and self:validate(sv, v)) then
            return false
        end
    end
    return true
end

return schema
