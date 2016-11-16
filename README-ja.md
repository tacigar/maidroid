# Maidroid

Maidroidは、Minecraft用のMOD `littleMaidMob` にインスパイアされて開発している、Minetestの世界にメイドロボットを追加するMOD(MOD Pack)です。

# Usage

## Overview

- MaidroidはCoreと呼ばれるチップを埋め込まれると、そのチップに埋め込まれたプログラムを実行する
- CoreはCoreWriterと呼ばれるチップへの書き込みを行う機械を使うことで、様々なチップへ変換することができる

## Core

Coreの種類とその機能の説明を以下に示す。

|Core|説明|
|:--|:--|
|`maidroid_core:empty`|何もしない。CoreWriterで変換するための材料|
|`maidroid_core:basic`|プレーヤーの後ろを付いてくる。荷物持ちくらいにはなる|

## Crafting

```
"maidroid_tool:core_writer" : {
	{"default:steel_ingot",     "default:diamond", "default:steel_ingot"},
	{     "default:cobble", "default:steel_ingot",      "default:cobble"},
	{     "default:cobble",      "default:cobble",      "default:cobble"},
}
```

CoreWriterを用いてEmptyCoreへの書き込みを行う際には染料が必要であり、染料と生成されるCoreの種類は一対一に対応する。
その対応関係を以下に列挙する。

|染料|生成されるCore|
|:--|:--|
||`maidroid_core:empty`|
|`dye:red`|`maidroid_core:basic`|



