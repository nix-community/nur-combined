import ./generic.nix ({ lib,
... } @ args: self: super: {
  version = "2.2.0";

  src = super.src // {
    sha256 = "0fpc09yvxjcvjkai7afyig4gyc7inaqxxrwzs17mh8wdgzawb6dl";
  };

  cargoSha256 = "0nlgq94796p8a4hc4mk072s1ay6ljxrh8ssm645jihq22xx9dgac";
})
