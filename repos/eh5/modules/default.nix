let
  modules = {
    einat = import ./einat;
    fake-hwclock = import ./fake-hwclock;
    mosdns = import ./mosdns;
    nftables-fullcone = import ./nftables-fullcone;
    system-tarball-extlinux = import ./system-tarball-extlinux;
    v2ray-rules-dat = import ./v2ray-rules-dat;
    vlmcsd = import ./vlmcsd;
  };
  default =
    { ... }:
    {
      imports = builtins.attrValues modules;
    };
in
modules // { inherit default; }
