---
-- Defines schemas and what each accepts.
--
--    local schema = require "util.schema"
--
--    local Number = schema.Type"number"
--
--    print(Number:validate(10))   --> true
--    print(Number:validate(3.14)) --> true
--    print(Number:validate"foo")  --> false "" "not number"
--    print(Number:validate(nil))  --> false "" "not number"
--
--    local Season = schema.Enum{
--      "winter",
--      "spring",
--      "summer",
--      "autumn",
--    }
--
--    print(Season:validate"winter") --> true
--    print(Season:validate"summer") --> true
--    print(Season:validate"frog")   --> false "" "not in enum"
--    print(Season:validate(123))    --> false "" "not in enum"
--
--    local Point = schema.Struct{
--      x = Number,
--      y = Number,
--    }
--
--    print(Point:validate{x = 10, y = -20})         --> true
--    print(Point:validate{x = 10, y = -20, z = 0})  --> true
--    print(Point:validate{x = 10, y = 'foo'})       --> false ".y" "not number"
--    print(Point:validate{x = 10})                  --> false ".y" "not number"
--
--    local OptionalNumber = schema.Option(Number)
--
--    print(OptionalNumber:validate(10))   --> true
--    print(OptionalNumber:validate(3.14)) --> true
--    print(OptionalNumber:validate"foo")  --> false "!" "not number"
--    print(OptionalNumber:validate(nil))  --> true
--
--    local Points = schema.Array(Point)
--
--    local p1 = {x = 10, y = -20}
--    local p2 = {x = 30, y = 50}
--    local p3 = {x = -40, y = 70}
--
--    print(Points:validate{})                  --> true
--    print(Points:validate{p1})                --> true
--    print(Points:validate{p1, p2, p3})        --> true
--    print(Points:validate{p1, p2, p3, a = 1}) --> true
--    print(Points:validate{p1, nil, p3})       --> true
--    print(Points:validate{p1, 123, p3})       --> false "[2]" "not table"
--
--    local MinTemp = schema.Map(Season, Number)
--
--    print(MinTemp:validate{})               --> true
--    print(MinTemp:validate{winter = -10})   --> true
--    print(MinTemp:validate{frog = 7})       --> false "[k]" "not in enum"
--    print(MinTemp:validate{summer = "foo"}) --> false "[v]" "not number"
--
-- @module util.schema

---------------------------
-- "Schema" class
---------------------------

local Class = require "util.class"

---
-- A schema is an inductively-defined type descriptor.
-- It shares some similaries with JSON schemas.
local Schema = Class "Schema"

local validator = {
    TYPE = '_validateType',
    ENUM = '_validateEnum',
    STRUCT = '_validateStruct',
    OPTION = '_validateOption',
    ARRAY = '_validateArray',
    MAP = '_validateMap',
}

---
-- Validate an input against a schema
-- @param t input
-- @treturn boolean whether the schema accepted or rejected the input
-- @treturn ?string the schema path where the error occurred (if first return is `false`)
-- @treturn ?string the error message (if first return is `false`)
function Schema:validate (t)
    local methodname = rawget(validator, self.tag)
    local method = self[methodname]
    return method(self, t)
end

function Schema:_validateType (t)
    if type(t) == self.child then
        return true
    else
        return false, "", "not " .. self.child
    end
end

function Schema:_validateOption (t)
    if t == nil then
        return true
    else
        local ok, path, err = self.child:validate(t)
        if ok then
            return true
        else
            return false, "!" .. path, err
        end
    end
end

function Schema:_validateEnum (t)
    for i, v in ipairs(self.child) do
        if v == t then
            return true
        end
    end
    return false, "", "not in enum"
end

function Schema:_validateStruct (t)
    if type(t) == 'table' then
        for k, v in pairs(self.child) do
            local ok, path, err = v:validate(t[k])
            if not ok then
                return false, "." .. k .. path, err
            end
        end
        return true
    else
        return false, "", "not table"
    end
end

function Schema:_validateArray (t)
    if type(t) == 'table' then
        for i, v in ipairs(t) do
            local ok, path, err = self.child:validate(v)
            if not ok then
                return false, "[" .. i .. "]" .. path, err
            end
        end
        return true
    else
        return false, "", "not table"
    end
end

function Schema:_validateMap (t)
    if type(t) == 'table' then
        for k, v in pairs(t) do
            local ok1, path1, err1 = self.key:validate(k)
            if not ok1 then
                return false, "[k]" .. path1, err1
            end
            local ok2, path2, err2 = self.value:validate(v)
            if not ok2 then
                return false, "[v]" .. path2, err2
            end
        end
        return true
    else
        return false, "", "not table"
    end
end

---------------------------
-- "schema" module
---------------------------

local schema = {}

---
-- Construct a "type" schema.
-- @function schema.Type
-- @tparam string T the type string
-- @treturn Schema a schema that only accepts objects of type `T`
function schema.Type (T)
    assert(type(T) == "string", "not string")
    return Schema:__new{ tag = 'TYPE', child = T }
end

---
-- Construct an "enum" schema.
-- @tparam table T an array of values
-- @treturn Schema a schema that only accepts values in array `T`
function schema.Enum (T)
    assert(type(T) == "table", "not table")
    return Schema:__new{ tag = 'ENUM', child = T }
end

---
-- Construct a "struct" schema.
-- @tparam table T a record of schemas with string keys
-- @treturn Schema a schema that only accepts tables `t`,
-- s.t. for all key-value pairs `(k,S)` in `T`, `S` accepts `t[k]`.
function schema.Struct (T)
    assert(type(T) == "table", "not table")
    for k in pairs(T) do assert(type(k) == "string", "non-string key") end
    return Schema:__new{ tag = 'STRUCT', child = T }
end

---
-- Construct an "option" schema.
-- @tparam Schema S
-- @treturn Schema a schema that accepts `nil` and anything accepted by `S`.
function schema.Option (S)
    assert(Schema:__isinstance(S), "invalid schema")
    return Schema:__new{ tag = 'OPTION', child = S }
end

---
-- Construct an "array" schema.
-- @tparam Schema S
-- @treturn Schema a schema that only accepts tables `t`,
-- s.t. for all index-value pairs `(i,v)` in `t`, `S` accepts `v`.
function schema.Array (S)
    assert(Schema:__isinstance(S), "invalid schema")
    return Schema:__new{ tag = 'ARRAY', child = S }
end

---
-- Construct a "map" schema.
-- @tparam Schema Sk
-- @tparam Schema Sv
-- @treturn Schema a schema that only accepts tables `t`,
-- s.t. for all key-value pairs `(k,v)` in `t`,
-- `Sk` accepts `k` and `Sv` accepts `v`.
function schema.Map (Sk, Sv)
    assert(Schema:__isinstance(Sk), "invalid key schema")
    assert(Schema:__isinstance(Sv), "invalid value schema")
    return Schema:__new{ tag = 'MAP', key = Sk, value = Sv }
end

return schema
