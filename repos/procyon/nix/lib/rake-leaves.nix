# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
#
# SPDX-License-Identifier: MIT

{ inputs, lib }:
let
  haumea = inputs.haumea.lib;
  loader = lib.const lib.id;
  transformer = _cursor: dir:
    if dir ? default
    then assert (lib.attrNames dir == [ "default" ]); dir.default
    else dir;
in
src:
haumea.load { inherit src loader transformer; }
