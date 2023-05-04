---
-- Defines schemas and what each accepts.
--
--    local schema = require "util.schema"
--
--    local Number = schema.Type"number"
--
--    print(Number:validate(10))   --> true
--    print(Number:validate(3.14)) --> true
--    print(Number:validate"foo")  --> false
--    print(Number:validate(nil))  --> false
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
--    print(Season:validate"frog")   --> false
--    print(Season:validate(123))    --> false
--
--    local Point = schema.Struct{
--      x = Number,
--      y = Number,
--    }
--
--    print(Point:validate{x = 10, y = -20})            --> true
--    print(Point:validate{x = 10, y = -20, z = "foo"}) --> true
--    print(Point:validate{x = 10, y = 'foo'})          --> false
--    print(Point:validate{x = 10})                     --> false
--
--    local OptionalNumber = schema.Option(Number)
--
--    print(OptionalNumber:validate(10))   --> true
--    print(OptionalNumber:validate(3.14)) --> true
--    print(OptionalNumber:validate"foo")  --> false
--    print(OptionalNumber:validate(nil))  --> true
--
--    local Points = schema.Array(Point)
--
--    local p1 = {x = 10, y = -20}
--    local p2 = {x = 30, y = 50}
--    local p3 = {x = -40, y = 70}
--
--    print(Points:validate{})                      --> true
--    print(Points:validate{p1})                    --> true
--    print(Points:validate{p1, p2, p3})            --> true
--    print(Points:validate{p1, p2, p3, foo = 123}) --> true
--    print(Points:validate{p1, nil, p3})           --> true
--    print(Points:validate{p1, 123, p3})           --> false
--
--    local MinTemp = schema.Map(Season, Number)
--
--    print(MinTemp:validate{})                             --> true
--    print(MinTemp:validate{winter = -10})                 --> true
--    print(MinTemp:validate{winter = -20, summer = 20})    --> true
--    print(MinTemp:validate{winter = -20, frog = 7})       --> false
--    print(MinTemp:validate{winter = -20, summer = "foo"}) --> false
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
function Schema:validate (t)
    local methodname = rawget(validator, self.tag)
    local method = self[methodname]
    return method(self, t)
end

function Schema:_validateType (t)
    return type(t) == self.child
end

function Schema:_validateOption (t)
    return t == nil or self.child:validate(t)
end

function Schema:_validateEnum (t)
    for i, v in ipairs(self.child) do
        if v == t then
            return true
        end
    end
    return false
end

function Schema:_validateStruct (t)
    if type(t) == 'table' then
        for k, v in pairs(self.child) do
            if not v:validate(t[k]) then
                return false
            end
        end
        return true
    else
        return false
    end
end

function Schema:_validateArray (t)
    if type(t) == 'table' then
        for i, v in ipairs(t) do
            if not self.child:validate(v) then
                return false
            end
        end
        return true
    else
        return false
    end
end

function Schema:_validateMap (t)
    if type(t) == 'table' then
        for k, v in pairs(t) do
            if not (self.key:validate(k) and
                    self.value:validate(v)) then
                return false
            end
        end
        return true
    else
        return false
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
    return Schema:__new{ tag = 'TYPE', child = T }
end

---
-- Construct an "enum" schema.
-- @tparam table T an array of values
-- @treturn Schema a schema that only accepts values in array `T`
function schema.Enum (T)
    return Schema:__new{ tag = 'ENUM', child = T }
end

---
-- Construct a "struct" schema.
-- @tparam table T a record of schemas
-- @treturn Schema a schema that only accepts tables `t`,
-- s.t. for all key-value pairs `(k,S)` in `T`, `S` accepts `t[k]`.
function schema.Struct (T)
    return Schema:__new{ tag = 'STRUCT', child = T }
end

---
-- Construct an "option" schema.
-- @tparam Schema S
-- @treturn Schema a schema that accepts `nil` and anything accepted by `S`.
function schema.Option (S)
    return Schema:__new{ tag = 'OPTION', child = S }
end

---
-- Construct an "array" schema.
-- @tparam Schema S
-- @treturn Schema a schema that only accepts tables `t`,
-- s.t. for all index-value pairs `(i,v)` in `t`, `S` accepts `v`.
function schema.Array (S)
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
    return Schema:__new{ tag = 'MAP', key = Sk, value = Sv }
end

return schema
