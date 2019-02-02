# Use at your own risk!
# Make backups!
self: super: {
  timewarrior = super.timewarrior.overrideAttrs (o: rec {
    name = "timewarrior-${version}";
    version = "2019-01-20";
    src = super.fetchFromGitHub {
      owner = "GothenburgBitFactory";
      repo = "timewarrior";
      rev = "f5bbe5e1bc23e4e8eced4189092a4ef505b93a8f";
      sha256 = "0cp2c0f81p9c7h7rgwarinqg61igbflyg1h1fzpzwsz91lp7icbk";
      fetchSubmodules = true;
    };
    #patches = [];
  });
}
