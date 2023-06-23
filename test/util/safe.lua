require 'util.safe'

-- global read (miss)
do
    local foo = bar
end

-- global write
foo = nil
foo = 123
foo = 'abc'
foo = {}
foo = function() end
foo = coroutine.running()
foo = io.stderr
