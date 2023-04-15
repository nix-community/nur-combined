# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
#
# SPDX-License-Identifier: MIT
{lib}: let
  extractPname = n: lib.lists.last (lib.strings.split "/" n);
  trivial = p: let
    pname = extractPname p;
  in {
    "${p}" = {
      "${p}" = pname;
    };
  };
  empty = p: {"${p}" = {};};
  merge = lib.fold lib.recursiveUpdate {};
  appNamesDict = merge [
    (empty "eupnea-scripts")
  ];
in
  p: appNamesDict.${p}
