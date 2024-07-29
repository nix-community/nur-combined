{ lib, ... }:
lib.mkIf false  #< 2024/07/27: i don't use it, too much surface-area for me to run it pro-bono (`systemd-analyze security monero`)
{
  services.i2p.enable = true;
}
