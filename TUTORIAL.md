# Tutorial

This tutorial will teach you how to install and play Catan through the LÖVE front-end of LuaCatan.

If you'd like to learn more about the project, please go to [`ABOUT.md`](./ABOUT.md).

## Installation

### System requirements

Currently, only Linux machines are supported.

Please consult the "User dependencies" section of the [`README.md`](./README.md).

### Downloading the source code

You can download the latest version of the source code through [this link](https://github.com/guidanoli/catan-lua/archive/refs/heads/main.zip).

## Execution

Open a terminal window and, on the repository root (the one with a `main.lua` file), and run the following command.

```sh
love .
```

This should create a random initial state for the game, and present you with a window similar to the one below.

![](https://i.imgur.com/m4gk1RT.png)

## Rules

If this is your first time playing Catan, we highly suggest you to read the [base rules](https://www.catan.com/sites/default/files/2021-06/catan_base_rules_2020_200707.pdf) before.

## Leaderboard

You can keep up with the progress of the game through the leaderboard on the top right of the screen.

![](https://i.imgur.com/GCOxgfS.png)

A **yellow** arrow points to the current player,
a **red** arrow points to the player currently discarding half of their cards,
and a **green** arrow points to the player currently assessing a trade proposal.

Here is what each column in the leaderboard represents, in order:

1. the number of resource cards; gets red whenever the player is vulnerable to losing half of their cards
2. the number of development cards
3. the number of used knight cards; gets red whenever the player possesses the Largest Army special card
4. the length of the longest road; gets red whenever the player possesses the Longest Road special card
5. the total number of victory point (taking victory point cards into account)

## Buttons

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

## Events

### Rolling a 7

When a player rolls a seven, the game first checks whether there are any players with more than 7 resource cards.

If that is the case, then each player with more than 7 resource cards is prompted to discard half of their resource cards, like in the image below.

![](https://imgur.com/snbOFur.png)

You may add/remove cards from the set of cards to be discarded by clicking on them.

When you have selected half of the cards, you may click on the OK button that will appear on the screen.

![](https://imgur.com/FZ78BeK.png)

After all the players with more than 7 resource cards have discarded half of their cards, the game prompts the player that rolled the 7 to move the robber.

### Moving the robber

When a player rolls a 7 or uses a knight card, they must move the robber to another hex tile, which can be done by clicking in any of the highlighted tiles.

![](https://imgur.com/BlsIiXb.png)

If you move the robber to a tile that contains more than one opponent, then you will have to choose which player you are going to rob by clicking on their building.

![](https://imgur.com/kS3MIGZ.png)

### Playing the Year of Plenty card

When a player uses their Year of Plenty card, they will be prompted to select the resources they wish to receive.

This can be done by selecting resources from the right corner of the screen and then pressing the OK in the middle of the screen.

**Note:** You may select 0-2 resource cards!

![](https://imgur.com/7Es1dJY.png)

### Playing the Monopoly card

When a player uses their monopoly card, they will be prompted to select the resource they wish to monopolize.

This can be done by selecting one resource from the right corner of the screen and then pressing the OK in the middle of the screen.

![](https://imgur.com/aZpdLD9.png)
