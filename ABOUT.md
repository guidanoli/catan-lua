# About this project

## Description

LuaCatan is an implementation of the Settlers of Catan board game in [Lua](https://www.lua.org/).
It follows the base rules established by the 5th edition of the game, which are available [here](https://www.catan.com/sites/default/files/2021-06/catan_base_rules_2020_200707.pdf).
The graphical user interface is implemented using [LÖVE](https://love2d.org/),
and serialization/deserialization is performed by the [Serpent](https://luarocks.org/modules/paulclinger/serpent) library.
LuaCatan has been tested extensively, reaching 100% of line coverage, as reported by [LuaCov](https://luarocks.org/modules/hisham/luacov).
Coverate reports in HTML can also be generated thanks to the [LuaCov-HTML](https://luarocks.org/modules/wesen1/luacov-html) library.
All modules have their own unit tests, and the main class `catan.logic.Game` has a special test bench, which tries random actions and checks if the state invariants are valid.
This fuzzy tester can be configured through command line arguments, thanks to the [argparse](https://luarocks.org/modules/argparse/argparse) library.
Apart from tests, all modules and classes are exhaustively documented.
All this documentation is nicely converted into HTML by [LDoc](https://luarocks.org/modules/lunarmodules/ldoc).

LuaCatan is composed of two logical parts: the back-end and the front-end.
This separation will be crucial for the implementation of the client and the server components.
However, it is important to point out that both parts currently run on the same machine.
The back-end part is written in Lua (5.1 or later), and uses the `serpent` library for serialization.
Meanwhile, the front-end part is loaded by LÖVE (which still runs on Lua 5.1).
Do note, however, that a central design goal of LuaCatan is to keep the front-end as uncoupled from the back-end as possible.
This means that you should have no problem in programming your own front-end on top of the LuaCatan back-end.

LuaCatan can be played by anyone that is already familiar with the rules of the game,
but may require a level of technical knowledge above the average to set it up.
We want to make LuaCatan as user-friendly and cross-platform as possible, specially for the client side.
However, for the time being, the user must know how to download LÖVE and serpent to enjoy all the features of LuaCatan.
Note that not all dependencies listed in the `README.md` are necessary for the execution of the client.
Most dependencies are only required for the developer to build the documentation, or to run the tests.

We must acknowledge that there are several other implementations of Catan out there, such as [colonist.io](https://colonist.io/).
They provide several interesting functionalities such as lobbies, custom maps, game settings, and a built-in chat.
These implementations, however, require an internet connection, which might not always be available.
For this reason, LuaCatan serves as an alternative to playing Catan offline.
In the future, we would also like to implement an option to set up a LAN session,
which would highly improve the user experience and interface.

Despite the long list of pending features, LuaCatan has several interesting feature already.
For instance, you can save and load game states into/from Lua files,
and run the client in debug mode, which allows you to draw as many resource cards as you like.

## Functional requirements

Here, we list all functional requirements of LuaCatan.
Note that some of them are not implemented yet.

The user must be able to start a match...

- with a random terrain
- with a random drawpile
- with 3 or 4 players **(PENDING, can only play with 4 players)**
- giving names to players **(PENDING, players are identified by their color)**

Players must have read access to...

- terrain hexes
- number tokens
- harbors
- the robber
- player roads
- player settlements
- player cities
- the amount of resource cards of each player
- the amount of development cards of each player
- the owner of the longest road special card
- the owner of the largest army special card
- their own resource cards
- their own development cards
- the amount of development cards in the drawpile **(PENDING)**
- the amount of each resource card in the bank **(PENDING)**

Players must not have access to...

- the resource cards of other players **(PENDING, all resource cards are public)**
- the development cards of other players **(PENDING, all development cards are public)**

On their turn, when the conditions described by the game rules are met, a player must be able to...

- build settlements
- build cities
- build roads
- roll the dice
- propose, commit and cancel trades to the other players
- trade through the harbors
- buy development cards
- play a development card
- end their turn

Not on their turn, a player must be able to...

- accept trade proposals (if possible)
- reject trade proposals

In the case of rolling a 7...

- all players must be able to discard half of their cards
- the player who rolled a 7 must be able to move the robber
- the player who rolled a 7 must be able to choose a victim

At any time, the user must also be able to...

- exit the game
- pause the game
- save the game
- load the game
