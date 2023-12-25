# SPDX-FileCopyrightText: 2023 Mia Kanashi <chad@redpilled.dev>
#
# SPDX-License-Identifier: MIT

{ ... }:
{
  boot.kernel.sysctl = {
    "vm.page-cluster" = 0;
    "vm.swappiness" = 180;
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 200;
  };
}
