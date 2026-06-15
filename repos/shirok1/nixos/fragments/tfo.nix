{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot.kernel.sysctl."net.ipv4.tcp_fastopen" = "3";
}
