# Tutorial

This tutorial will teach you how to install and play Catan through the LÖVE front-end of LuaCatan.
If you'd like to learn more about the project, please consult the `ABOUT.md` file.

## Installation

### System requirements

Currently, only Linux machines are supported.
Please consult the "User dependencies" section of the `README.md`.

### Downloading the source code

You can download the latest version of the source code through [this link](https://github.com/guidanoli/catan-lua/archive/refs/heads/main.zip).

## Execution

Open a terminal window and, on the repository root (the one with a `main.lua` file), and run the following command.

```sh
love .
```

This should create a random initial state for the game, and present you with a window similar to the one below.

![](https://i.imgur.com/m4gk1RT.png)

## Controls

You will need your mouse to perform most actions.
This section lists all the buttons and what each of them does.

### Build Road

![](https://i.imgur.com/S1DrRrZ.png)

Whenever this button is active, the player may choose a path to place one of its roads.
Each new road will cost the player 1x lumber and 1x brick.
However, if the player has recently played a Road Building card, then they can lay 2 roads for free.
Once the button is clicked, the available paths will be highlighted and the player may click in any one of them.
Before doing so, the action can be canceled by pressing the `Escape` key.

### Build Settlement

![](https://i.imgur.com/K01ctco.png)

Whenever this button is active, the player may choose a vertex to place one of its settlements.
Each new settlement will cost the player 1x lumber, 1x brick, 1x grain and 1x wool.
Once the button is clicked, the available vertices will be highlighted and the player may click in any one of them.
Before doing so, the action can be canceled by pressing the `Escape` key.

### Upgrade Settlement

![](https://i.imgur.com/Gs1h0zs.png)

Whenever this button is active, the player may choose one of its settlements to upgrage.
Each upgrage will cost the player 3x ore and 2x grain.
Once the button is clicked, the player may click in any of its settlements.
Before doing so, the action can be canceled by pressing the `Escape` key.

### Trade

![](https://i.imgur.com/4pvDC1E.png)

Whenever this button is active, the player may trade resource cards.
Once the button is clicked, the interface will switch to trade mode.
In this mode, the player may select resource cards from both sides of the trade.
If the proposed trade is possible, an OK button will appear in the middle of the screen.
If the trade can be performed with harbors, then the OK button will immediately execute the trade.
Otherwise, the OK button will prompt each player that can perform the trade whether they accept or reject it.
The player who proposed the trade can then commit the trade by clicking on the check symbol next to the player line in the table.
Trade mode can be exited by pressing the `Escape` key.

### Buy Development Card

![](https://i.imgur.com/QuQMDcN.png)

Whenever this button is active, the player may withdraw a development card from the pile.
Each development card will cost the player 1x ore, 1x grain and 1x wool.
Once the button is clicked, a development card is withdrawn from the pile.

### Roll Dice

![](https://i.imgur.com/RreE6CX.png)

Whenever this button is active, the player may roll the dice.
Once the button is clicked, the dice are rolled and the result is displayed on the screen.

### End Turn

![](https://i.imgur.com/FCwe55B.png)

Whenever this button is active, the player may end its turn.
Once the button is clicked, the player passes the control to the next player in the order.

## Rules

If this is your first time playing Catan, we highly suggest you to read the [base rules](https://www.catan.com/sites/default/files/2021-06/catan_base_rules_2020_200707.pdf) before.
