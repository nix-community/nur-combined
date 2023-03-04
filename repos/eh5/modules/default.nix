let
  modules = {
    fake-hwclock = import ./fake-hwclock;
    mosdns = import ./mosdns;
    nftables-fullcone = import ./nftables-fullcone;
    stalwart-jmap = import ./stalwart-jmap;
    system-tarball-extlinux = import ./system-tarball-extlinux;
    v2ray-next = import ./v2ray-next;
    v2ray-rules-dat = import ./v2ray-rules-dat;
    vlmcsd = import ./vlmcsd;
  };
  default = { ... }: {
    imports = builtins.attrValues modules;
  };
in
modules // { inherit default; }
