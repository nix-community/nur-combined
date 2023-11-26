# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
#
# SPDX-License-Identifier: MIT

{ lib }:
let
  mkNewPrefix = prefix: name: "${
    if prefix == ""
    then ""
    else "${prefix}/"
  }${name}";
  flattenTree' = prefix: remain:
    if lib.isAttrs remain
    then lib.flatten (lib.mapAttrsToList (name: value: flattenTree' (mkNewPrefix prefix name) value) remain)
    else [ (lib.nameValuePair prefix remain) ];
in
tree: lib.listToAttrs (flattenTree' "" tree)
