-- LDoc configuration file

project = 'LuaCatan'

title = 'LuaCatan Documentation'

description = 'The famous board game, now in Lua!'

format = 'markdown'

file = {
    'catan',
    'util',
    'main.lua',
}

readme = {
    'README.md',
    'ABOUT.md'
}

style = 'style'

local loveURL = "https://love2d.org/wiki/%s"

custom_see_handler('^love2d@(.*)$', function(name)
    return name, loveURL:format(name)
end)
