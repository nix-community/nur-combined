# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
#
# SPDX-License-Identifier: MIT
{lib, ...}: {
  options = {
    passthru = lib.mkOption {
      visible = false;
      type = with lib.types; attrsOf unspecified;
    };
  };
}
