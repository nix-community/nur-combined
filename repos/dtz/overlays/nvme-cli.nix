self: super: {
  nvme-cli = super.nvme-cli.overrideAttrs(o: rec {
    name = "nvme-cli-${version}";
    version = "2018-11-26";
    src = super.fetchFromGitHub {
      owner = "linux-nvme";
      repo = "nvme-cli";
      rev = "5c8a6230947933f408a6e9a4de2da75e165b62f0";
      sha256 = "12c6mksndqbr9aj0i5lijqgaxiph0c55szxfpbl031bbjm72xzbv";
    };
  });
}
