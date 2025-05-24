# Enabling Commented-Out Features

> [!CAUTION]
> This page is incomplete!

Both system instructions assume you purchased and followed their given instructions

## AShop

1. Go to `gamemode/round/sv_round.lua`.
2. Uncomment all code entries containing "AShop".
3. Repeat for `cl_round.lua` and all other files as needed.

## Elite XP System 2

1. Go to `gamemode/round/sv_round.lua`.
2. Uncomment all code entries containing "EliteXP".
3. Repeat for `cl_round.lua` and all other files as needed.

## `hs_` features

You must have a settings area or panel or command made on your own accord.

1. Go to `gamemode/round/sv_round.lua`.
2. Uncomment all code entries containing "hs_" and any "end" keywords if wrapped in if-statements.
3. Add your own code for your settings panel or command to work with the "hs_" player datas.