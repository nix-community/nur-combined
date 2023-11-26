# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
#
# SPDX-License-Identifier: MIT

{ selfLib, lib }:
let
  inherit (selfLib) flattenTree rakeLeaves;
in
dir: lib.attrValues (flattenTree (rakeLeaves dir))
