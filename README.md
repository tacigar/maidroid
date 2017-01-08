# Maidroid

<img src=http://i.imgur.com/oWjrLtK.png>

## Overview

Maidroid MOD is a MOD for Minetest which adds maid robots, inspired by littleMaidMob.

## Usage

First, in order to create a maidroid, you have to craft an empty egg and an egg writer that convert eggs.
Those recipe is as follows.

<img src="http://i.imgur.com/6ZGQF4J.png" />
<img src="http://i.imgur.com/Y5tzPGM.png" />

After you place an egg writer node, and rightclick it, you have to place an empty egg to the slot labeled `Egg`, a coal to the slot labeled `Fuel`, and a dye to the slot labeled `Dye`.
The kind of the dye placed decides a egg produced.
The correspondences are as follows.

|Dye|Egg|
|:--|:--|
|dye:white|maidroid:maidroid_mk1_egg|
|dye:grey|maidroid:maidroid_mk2_egg|
|dye:dark_grey|maidroid:maidroid_mk3_egg|
|dye:black|maidroid:maidroid_mk4_egg|
|dye:blue|maidroid:maidroid_mk5_egg|
|dye:cyan|maidroid:maidroid_mk6_egg|
|dye:green|maidroid:maidroid_mk7_egg|
|dye:dark_green|maidroid:maidroid_mk8_egg|
|dye:yellow|maidroid:maidroid_mk9_egg|
|dye:orange|maidroid:maidroid_mk10_egg|
|dye:brown|maidroid:maidroid_mk11_egg|
|dye:red|maidroid:maidroid_mk12_egg|
|dye:pink|maidroid:maidroid_mk13_egg|
|dye:magenta|maidroid:maidroid_mk14_egg|
|dye:violet|maidroid:maidroid_mk15_egg|

After a while, the empty egg will be converted to an new egg.
If you take and use it, a new maidroid will be born.

The maidroid, however, doesn't move now.
In order to have them move, you have to put a Core that is their brain.
You can create a core in a similar way to a maidroid egg.
First, you have to create an empty core and a core writer.
Those recipe is as follows.

<img src="http://i.imgur.com/Sxnr38Y.png">
<img src="http://i.imgur.com/97VENIl.png">

After you place a core writer node, rightclick it, and place a empty core to the slot labeled `Core`, a coal to the slot labeled `Fuel`, and a dye to the slot labeled `Dye`.
The correspondences of dyes and cores are as follows.

|Dye|Core|Description|
|:--|:--|:--|
|`dye:red`|`maidroid_core:basic`|Following the player.|
|`dye:yello`|`maidroid_core:farming`|Farming.|
|`dye:white`|`maidroid_core:ocr`|Reading a book written a program, and executing the program.|

When a new core is created, put it to the maidroid.
Rightclick it, and put the core to the slot labeled `Core`.
The maidroid will start.

## Dependencies

- bucket
- default
- dye
- [pdisc?](https://github.com/HybridDog/pdisc)

## Forum Topic

The forum topic for this mod on the Minetest Forums is located at:

* https://forum.minetest.net/viewtopic.php?f=9&t=14808

## License

- The source code of Maidroid is available under the [LGPLv2.1](https://www.gnu.org/licenses/old-licenses/lgpl-2.1.txt) or later license.
- The resouces included in Maidroid are available under the [CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) or later license.
