self: super: {
  nvme-cli = super.nvme-cli.overrideAttrs(o: rec {
    name = "nvme-cli-${version}";
    version = "2018-12-07";
    src = super.fetchFromGitHub {
      owner = "linux-nvme";
      repo = "nvme-cli";
      rev = "e145ab4d9b5966ee7964a3b724af1855080465ca";
      sha256 = "03icfjjy4ymx1al9a78ylz4h47jx0fpnyqrcmhbgcr1km96284ml";
    };
  });
}
