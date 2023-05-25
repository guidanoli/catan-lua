# Catan GUI

This module is responsible for rendering the game state, receiving input from the user, and safely advancing the game state.
The engine we use for rendering and receiving input is LÖVE 2D, which is very popular in the Lua community.
The GUI still performs some safety checks on the state of the game by calling the `validate` method after every move.
