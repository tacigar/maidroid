# Maidroid

<img src="http://i.imgur.com/7HTh30v.png" />
<img src="http://i.imgur.com/wF1BBe6.gif" />

## Overview

Maidroid MOD は, Minecraft のMOD `littleMaidMob` にインスパイアされて開発を始めた, 孤独な Minetest の世界にメイドのロボットを追加する MOD です。

## Usage

Maidroid を作り出すには, まず空の卵と卵に命を吹き込むための, Maidroid-Egg Writer を作成しなければなりません.
それらのレシピを以下に示します.

<img src="http://i.imgur.com/6ZGQF4J.png" />
<img src="http://i.imgur.com/Y5tzPGM.png" />

次に, Maidroid-Egg Writer 設置, 右クリックし, `Egg` と書かれたスロットに先ほど作成した空の卵を置きます.
また, `Fuel` と書かれたスロットには石炭を, `Dye` と書かれたスロットには染料を設置します.
この染料の色によって, 生成される卵の種類が変化します.
以下に染料と, 生成される卵の対応を示します.

|染料|Egg|
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

しばらく待つと, 空の卵に命が吹き込まれ, 新しい卵に変換されます.
この卵を取り出し地面に投げつけると, Maidroid が誕生します.

この状態では, Maidroid は止まったままです.
Maidroid を動かすためには, Core, つまり Maidroid の脳を埋め込む必要があります.
Core を作り出す手順は Maidroid を作り出す手順と非常に似ています.
まず, 空の Core と Core に情報を書き込む為の Core Writer を作成します.
それらのレシピを以下に示します.

<img src="http://i.imgur.com/Sxnr38Y.png">
<img src="http://i.imgur.com/97VENIl.png">

Core Writer を設置 & 右クリックし, `Core` スロットに空の Core, `Fuel` スロットに石炭, `Dye` スロットに染料を設置します.
Maidroid-Egg Writer 同様, 設置される染料の種類によって, 生成される Core の種類が変化します.
以下に染料と, 生成される Core の対応を示します.

|染料|Core|説明|
|:--|:--|:--|
|`dye:red`|`maidroid_core:basic`|プレーヤーを追いかけてくる. |
|`dye:yellow`|`maidroid_core:farming`|農耕をする. |

Core が生成されたら早速 Maidroid に埋め込みましょう.
Maidroid を右クリックし, Core と書かれたスロットに先ほど作成した Core を設置します.
すると, Maidroid が動き始めるでしょう.

## Dependencies

- bucket
- default
- dye

## Lisense

- Source Code : [GPLv3](https://www.gnu.org/licenses/gpl-3.0.html) or later
- Resources : [CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) or later

## Contributers
