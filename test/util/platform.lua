local platform = require "util.platform"

do
    local sep = platform.PATH_SEPARATOR
    assert(type(sep) == 'string')
    assert(#sep > 0)
end
