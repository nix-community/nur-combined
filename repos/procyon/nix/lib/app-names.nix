# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
#
# SPDX-License-Identifier: MIT

{ lib }:

let
  extractPname = n: lib.lists.last (lib.strings.split "/" n);
  trivial = p:
    let pname = extractPname p; in
    {
      "${p}" = {
        "${p}" = pname;
      };
    };
  empty = p: { "${p}" = { }; };
  merge = lib.fold lib.recursiveUpdate { };
  appNamesDict = merge [
    (trivial "devPackages/nvfetcher-self")
    (empty "cockpit-machines")
    (empty "cockpit-podman")
  ];
in
p: appNamesDict.${p}
