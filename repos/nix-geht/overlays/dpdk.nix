self: super: {
  dpdk = super.dpdk.overrideAttrs (x: rec {
    mesonFlags = x.mesonFlags ++ ["-Denable_driver_sdk=true"];
  });
}
