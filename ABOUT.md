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

## Architecture

LuaCatan is composed of two logical parts: the back-end and the front-end.
This separation will be crucial for the implementation of the client and the server components.
However, it is important to point out that both parts currently run on the same machine.
The back-end part is written in Lua (5.1 or later), and uses the `serpent` library for serialization.
Meanwhile, the front-end part is loaded by LÖVE (which still runs on Lua 5.1).
Do note, however, that a central design goal of LuaCatan is to keep the front-end as uncoupled from the back-end as possible.
This means that you should have no problem in programming your own front-end on top of the LuaCatan back-end.

## Target audience

LuaCatan can be played by anyone that is already familiar with the rules of the game,
but may require a level of technical knowledge above the average to set it up.
We want to make LuaCatan as user-friendly and cross-platform as possible, specially for the client side.
However, for the time being, the user must know how to download LÖVE and serpent to enjoy all the features of LuaCatan.
Note that not all dependencies listed in the [`README.md`](./README.md) are necessary for the execution of the client.
Most dependencies are only required for the developer to build the documentation, or to run the tests.

## Expected usage

We must acknowledge that there are several other implementations of Catan out there, such as [colonist.io](https://colonist.io/).
They provide several interesting functionalities such as lobbies, custom maps, game settings, and a built-in chat.
These implementations, however, require an internet connection, which might not always be available.
For this reason, LuaCatan serves as an alternative to playing Catan offline.
In the future, we would also like to implement an option to set up a LAN session,
which would highly improve the user experience and interface.

## Key features

Despite the long list of pending features, LuaCatan has several interesting feature already.
For instance, you can save and load game states into/from Lua files,
and run the client in debug mode, which allows you to draw as many resource cards as you like.

## Functional requirements

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

## Non-functional requirements

- the source code must be licensed with GPLv3
- the source code must only depend on free and open-source software
- any extra resources (such as images) must also be used under a free license
- the back-end and the front-end must be written in Lua >= 5.1
- the back-end must be as uncoupled from the front-end as possible
- the back-end should provide an entry point to validate the state of the game against a set of invariants
- the back-end must be easily run on Linux environments
- the front-end must use LÖVE >= 11.4
- the front-end may only listen to mouse and keyboard events
- the front-end must be easily run on any platform **(PENDING, client-server separation)**
- each Lua module must be thoroughly documented and tested
- the code documentation must be accessible in HTML format
- the ratio of program lines covered the tests must be >= 95%

## Documentation

The front-end is documented in the [`TUTORIAL.md`](./TUTORIAL.md).

The back-end is fully documented by the pages generated by LDoc.

## Use cases

### Using the LuaCatan back-end

- **Who is the user?** The user has some level of expertise with Lua, and knows how to install the dependencies with LuaRocks.
- **In what context would LuaCatan be useful to the user?** The user might want to use only the back-end, because they want to develop a front-end for it. This usage may be either for professional, educational, or research purposes.
- **How would the user use LuaCatan?** The user might fork the repository, and add their code next to the already existing code. They might iteratively improve the front-end to contemplate all possible game actions, and meta-actions such as serialization. They might resort to the reference front-end implementation in LÖVE to understand how the back-end should be used.
- **What does the user expect from LuaCatan, and what would they do with the result of its usage?** The user expects the back-end to properly implement the game rules; to have an easy-to-use interface; to raise erros whenever internal invariants are violated; to have sensible default values; to implement efficient algorithms in terms of computational effort and memory usage; and to have a thorough and clear documentation. With all of these properties, the user would be able to concentrate more on the development of the front-end instead of facing problems with the back-end. For the user of their front-end, they would benefit from having a reliable back-end, with efficient algorithms, etc.

### Using the LuaCatan front-end

- **Who is the user?** The user has the dependencies installed on their machine, or knows how to install them. They are generally only interested in playing the games, and not on the implementation necessarily.
- **In what context would LuaCatan be useful to the user?** If the user would like to play Catan offline, given that most Catan implementations are Web-based and require an internet connection.
- **How would the user use LuaCatan?** They would install the dependencies and run the game through the command line, and then interact with LuaCatan through the GUI.
- **What does the user expect from LuaCatan, and do with the result of its usage?** They expect LuaCatan to faithfully reflect the analog board game, or other digital replicas. They also expect the GUI to be reliable, responsive, aesthetically pleasing, and intuitive. The user would also indirectly use the back-end, so it is crucial that the back-end also correctly and efficiently implements the game rules. Having played LuaCatan, the user would be satisfied with the game experience.
