self: super: {
  dpdk = super.dpdk.overrideAttrs (x: rec {
    pname = "old-dpdk";
    version = "22.03";
    src = super.fetchurl {
      url = "https://fast.dpdk.org/rel/dpdk-${version}.tar.xz";
      sha256 = "sha256-st5fCLzVcz+Q1NfmwDJRWQja2PyNJnrGolNELZuDp8U=";
    };
  });
}
