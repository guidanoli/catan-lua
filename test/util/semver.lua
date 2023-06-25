local semver = require "util.semver"

local v

local function ok (...)
    local v2 = semver:new(...)
    assert(v:compatibleWith(v2))
    assert(v2:compatibleWith(v))
end

local function fail (...)
    local v2 = semver:new(...)
    assert(not v:compatibleWith(v2))
    assert(not v2:compatibleWith(v))
end

do
    v = semver:new(1)

    ok(1)
    ok(1, 0)
    ok(1, nil)
    ok(1, 0, 0)
    ok(1, nil, 0)
    ok(1, 0, nil)
    ok(1, 1)
    ok(1, 0, 1)
    ok(1, nil, 1)
    ok(1, 1, 1)

    fail()
    fail(0)
    fail(nil)
    fail(2)
    fail(0, 9, 9)
    fail(nil, 9, 9)
    fail(2, nil)
    fail(2, nil, 0)
    fail(2, 0, nil)
    fail(2, nil, nil)
    fail(2, 0, 0)
end

local function ok (s, ...)
    local v = semver:new(...)
    assert(v:tostring() == s)
end

ok('0.0.0')
ok('0.0.0', 0)
ok('0.0.0', nil)
ok('0.0.0', 0, 0)
ok('0.0.0', nil, 0)
ok('0.0.0', 0, nil)
ok('0.0.0', nil, nil)
ok('0.0.0', 0, 0, 0)
ok('0.0.0', nil, 0, 0)
ok('0.0.0', 0, nil, 0)
ok('0.0.0', nil, nil, 0)
ok('0.0.0', 0, 0, nil)
ok('0.0.0', nil, 0, nil)
ok('0.0.0', 0, nil, nil)
ok('0.0.0', nil, nil, nil)

ok('1.0.0', 1)
ok('1.0.0', 1, 0)
ok('1.0.0', 1, nil)
ok('1.0.0', 1, nil, 0)
ok('1.0.0', 1, nil, nil)
ok('1.0.0', 1, 0, nil)

ok('2.5.7', 2, 5, 7)

ok('2.0.7', 2, 0, 7)
ok('2.0.7', 2, nil, 7)
