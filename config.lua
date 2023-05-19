-- LDoc configuration file

project = 'Catan in Lua'

description = 'The famous board game, now in Lua!'

format = 'markdown'

file = {
    'catan',
    'util',
}

local loveURL = "https://love2d.org/wiki/%s"

custom_see_handler('^love2d@(.*)$', function(name)
    return name .. ' (LÖVE)', loveURL:format(name)
end)
