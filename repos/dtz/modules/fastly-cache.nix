{ config, lib, ... }:

{
  config.nix.binaryCaches = lib.mkBefore [
    # http2 and ipv6?
    "https://aseipp-nix-cache.freetls.fastly.net"
    # "https://aseipp-nix-cache.global.ssl.fastly.net"
  ];
}
