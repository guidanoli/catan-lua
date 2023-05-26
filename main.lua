---
-- Module to be loaded by LÖVE.
--
-- Registers the appropriate callbacks for LÖVE to call.
--
-- All callbacks are mere tail calls to @{catan.gui} methods.
--
-- @module main

local CatanGUI = require "catan.gui"

---
-- Callback triggered once at the beginning of the game.
-- @param ... Forwarded to @{catan.gui:load}
-- @see love2d@love.load
function love.load (...)
    return CatanGUI:load(...)
end

---
-- Callback used to draw on the screen every frame.
-- @param ... Forwarded to @{catan.gui:draw}
-- @see love2d@love.draw
function love.draw (...)
    return CatanGUI:draw(...)
end

---
-- Callback used to update the state of the game every frame.
-- @param ... Forwarded to @{catan.gui:update}
-- @see love2d@love.update
function love.update (...)
    return CatanGUI:update(...)
end

---
-- Callback triggered when a mouse button is pressed.
-- @param ... Forwarded to @{catan.gui:mousepressed}
-- @see love2d@love.mousepressed
function love.mousepressed (...)
    return CatanGUI:mousepressed(...)
end

---
-- Callback triggered when the mouse is moved.
-- @param ... Forwarded to @{catan.gui:mousemoved}
-- @see love2d@love.mousemoved
function love.mousemoved (...)
    return CatanGUI:mousemoved(...)
end
