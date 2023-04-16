# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
#
# SPDX-License-Identifier: MIT
{lib}: {
  appNames = import ./app-names.nix {inherit lib;};
  makeApps = import ./make-apps.nix {inherit lib;};
  makePackages = import ./make-packages.nix {inherit lib;};
}
