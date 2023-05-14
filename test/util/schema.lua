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
    assert(s:validate(v))
    assert(s:eq(v, v))
    print('ok...', pprint(v))
end

local function fail(v)
    assert(not s:validate(v))
    print('fail (expected)...', pprint(v))
end

local values = {
    0,
    math.mininteger,
    math.maxinteger,
    math.pi,
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

-- Types

for t in pairs(types) do
    s = schema.Type(t)
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

-- Integer

do
    s = schema.Integer()

    ok(0)
    ok(1)
    ok(-1)

    fail('123')
    for _, value in pairs(values) do
        if type(value) ~= 'number' then
            fail(value)
        end
    end
end

-- Structs

do
    s = schema.Struct{}

    ok{}
    ok{'haha'}
    ok{x = 'haha'}
    fail(nil)
    fail(123)

    s = schema.Struct{x = schema.Type'string'}

    ok{x = 'haha'}
    ok{x = 'haha', y = 123}
    ok{x = 'haha', y = 'hehe'}
    fail(nil)
    fail'haha'
    fail{}
    fail{x = 123}

    s = schema.Struct{x = schema.Type'string', y = schema.Type'number'}

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

    s = schema.Struct{c = schema.Struct{x = schema.Type'number', y = schema.Type'number'}}

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
    fail'bar'

    s = schema.Enum{foo='bar'}

    fail'foo'
    fail'bar'

    s = schema.Enum{[true] = 'bar'}

    fail(true)
    fail'bar'
end

-- Options

for t in pairs(types) do
    s = schema.Option(schema.Type(t))
    ok(nil)
    for _, value in pairs(values) do
        if type(value) == t then
            ok(value)
        else
            fail(value)
        end
    end
end

-- Arrays

do
    s = schema.Array(schema.Type('nil'))

    ok{}
    ok{[true] = 1}
    ok{[3] = 1}
    ok{nil, nil, nil}
    fail(nil)
    fail(123)
    fail'haha'
    fail{1}

    s = schema.Array(schema.Type'number')

    ok{}
    ok{[777] = {1, 2, 3}}
    ok{1, 2, 3}
    ok{1, 2, 3, abc = 888}
    fail{{1, 2, 3}, {4, 5, 6}, {7, 8, 9}}
    fail{{1, 2, 3}, nil, {7, 8, 9}}
    fail(123)
    fail'haha'

    s = schema.Array(schema.Struct{x = schema.Type'number', y = schema.Type'number'})

    ok{}
    ok{{x = 10, y = 20}}
    ok{{x = 10, y = 20}, {x = 33, y = 66}}
    ok{foo = 'blabla'}
    ok{[123] = 'blabla'}
    ok{{x = 10, y = 20}, foo = 123}
    ok{{x = 10, y = 20}, nil, {x = 33, y = 66}}
    fail{{x = 10, y = 20}, 'blabla'}
    fail{{x = 10, y = 20}, {x = 33}}
    fail{{x = 10, y = 20}, {x = 33, y = 'foo'}}
end

-- Maps

do
    s = schema.Map(schema.Type'number', schema.Type'string')

    ok{}
    ok{"a", "b", "c"}
    ok{"a", "b", [77] = "c"}
    ok{"a", [3.14] = "b", [77] = "c"}
    fail{123}
    fail{"a", "b", "c", 123}
    fail{"a", "b", [77] = 123}
    fail{"a", "b", [3.14] = 123}

    s = schema.Map(schema.Struct{x = schema.Type'number', y = schema.Type'number'}, schema.Struct{a = schema.Type'string', b = schema.Type'boolean'})

    ok{}
    ok{[{x=1,y=2}] = {a='foo', b=false}}
    fail{[{x=1, y='foo'}] = {a='foo', b=false}}
    fail{[{x=1,y=2}] = {a=123, b=false}}
end
