{ lib, ... }:
{
  config.nix.binaryCaches = lib.mkBefore [
    "https://aseipp-nix-cache.global.ssl.fastly.net"
  ];
}
