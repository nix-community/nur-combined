final: prev: {
  dpdk = prev.dpdk.overrideAttrs (x: rec {
    mesonFlags = x.mesonFlags ++ ["-Denable_driver_sdk=true"];
  });
}
