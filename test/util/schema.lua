local serpent = require "serpent"

require "util.safe"

local schema = require "util.schema"

foo = 123

local s -- current schema
local N = 10

local function pprint(v)
    return serpent.line(v, {nocode=true, comment=false})
end

local function ok(v)
    s:validate(v)
    print('ok...', pprint(v))
end

local function fail(v)
    local ok, err = pcall(s.validate, s, v)
    assert(not ok, 'test case did not fail as expected')
    print('fail (expected)...', pprint(v))
end

-- Values

do
    local values = {
        0,
        math.mininteger,
        math.maxinteger,
        0.0,
        0/0, -- nan
        1/0, -- +inf
        -1/0, -- -inf
        true,
        false,
        "", -- empty string
        "abc", -- non-empty string
        {}, -- empty table
        {x = 123}, -- non-empty table
        print, -- c function
        function() end, -- lua function
        coroutine.running(), -- thread
        io.stderr, -- userdatum
    }

    local types = {
        ['nil'] = true,
        ['boolean'] = true,
        ['number'] = true,
        ['string'] = true,
        ['function'] = true,
        ['userdata'] = true,
        ['thread'] = true,
        ['table'] = true,
    }

    for t in pairs(types) do
        s = schema.Value(t)
        if t ~= 'nil' then
            fail(nil)
        end
        for _, value in pairs(values) do
            if type(value) == t then
                ok(value)
            else
                fail(value)
            end
        end
    end
end

-- Structs

do
    s = schema.Struct{}

    ok{}
    fail(nil)
    fail(123)
    fail{x = 'haha'}

    s = schema.Struct{x = 'string'}

    ok{x = 'haha'}
    fail(nil)
    fail'haha'
    fail{}
    fail{x = 123}
    fail{x = 'haha', y = 123}
    fail{x = 'haha', y = 'haha'}
    fail{x = 'haha', y = 'hehe'}

    s = schema.Struct{x = 'string', y = 'number'}

    ok{x = 'haha', y = 123}
    fail(nil)
    fail(123)
    fail'haha'
    fail{}
    fail{x = 123}
    fail{y = 123}
    fail{x = 'haha'}
    fail{y = 'haha'}
    fail{x = 'haha', y = 'haha'}
    fail{x = 'haha', y = 'hehe'}
    fail{x = 123, y = 123}
    fail{x = 123, y = 456}
    fail{x = 123, y = 'haha'}

    s = schema.Struct{c = schema.Struct{x = 'number', y = 'number'}}

    ok{c = {x = 123, y = 456}}
    fail(nil)
    fail(123)
    fail'haha'
    fail{}
    fail{c = 123}
    fail{c = 'haha'}
    fail{c = {}}
    fail{x = 123, y = 456}
    fail{c = {x = 123}}
    fail{c = {y = 123}}
    fail{c = {x = 'haha'}}
    fail{c = {y = 'haha'}}
    fail{c = {x = 123, y = 'haha'}}
    fail{c = {x = 'haha', y = 123}}
    fail{c = {x = 'haha', y = 'haha'}}
end

-- Enums

do
    s = schema.Enum{}

    fail(nil)
    fail(1)
    fail'foo'
    fail{}

    s = schema.Enum{'foo'}

    ok'foo'
    fail'f'
    fail'FOO'
    fail'foo '
    fail' foo'
    fail'Foo'
    fail'bar'
    fail(nil)
    fail(1)
    fail{}

    s = schema.Enum{'foo', 'bar'}

    ok'foo'
    ok'bar'
    fail'foobar'
    fail'haha'

    s = schema.Enum{'foo', nil, 'bar'}

    ok'foo'
    fail(nil)
    ok'bar'

    s = schema.Enum{foo='bar'}

    fail'foo'
    ok'bar'

    s = schema.Enum{[true] = 'bar'}

    fail(true)
    ok'bar'
end
