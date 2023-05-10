require "util.safe"

local gutil = require "catan.gui.util"

for i = 1, 100 do
    local d = math.random(-360, 360)
    local r = gutil:ccwdeg2cwrad(d)
    assert(r == - math.pi * d / 180)
end
