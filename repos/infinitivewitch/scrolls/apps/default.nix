# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
#
# SPDX-License-Identifier: MIT
{self, ...}: {
  perSystem = {self', ...}: {
    apps = self.lib.makeApps self'.packages self.lib.appNames;
  };
}
