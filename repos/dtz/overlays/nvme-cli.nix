self: super: {
  nvme-cli = super.nvme-cli.overrideAttrs(o: rec {
    name = "nvme-cli-${version}";
    version = "2019-01-03";
    src = super.fetchFromGitHub {
      owner = "linux-nvme";
      repo = "nvme-cli";
      rev = "f7c5a51e66e85ec905f78045a444db50202e8329";
      sha256 = "1190g47hxcni6q28zii9hvra9vxwmcsm3mx07r1hdsnrxh6sq7pm";
    };
  });
}
