require "util.safe"

local gutil = require "catan.gui.util"

for i = 1, 100 do
    local r = math.random(0, 255)
    local g = math.random(0, 255)
    local b = math.random(0, 255)
    local t = gutil:rgb(r, g, b)
    assert(type(t) == 'table')
    assert(#t == 3)
    assert(t[1] == r/255)
    assert(t[2] == g/255)
    assert(t[3] == b/255)
end

for i = 1, 100 do
    local d = math.random(-360, 360)
    local r = gutil:ccwdeg2cwrad(d)
    assert(r == - math.pi * d / 180)
end
