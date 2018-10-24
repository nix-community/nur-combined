self: super: {
  nvme-cli = super.nvme-cli.overrideAttrs(o: rec {
    name = "nvme-cli-${version}";
    version = "2018-10-24";
    src = super.fetchFromGitHub {
      owner = "linux-nvme";
      repo = "nvme-cli";
      rev = "829dd58029bd38c395613d46e3a488b7fcf3ec55";
      sha256 = "0aaflwmhx43m8qs765f2vislhbc400x5wh4fvicqbdqcisk3g1ax";
    };
  });
}
