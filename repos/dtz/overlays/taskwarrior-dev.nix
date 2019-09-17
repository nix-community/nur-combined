# Use at your own risk!
# Make backups!
self: super: {
  taskwarrior = super.taskwarrior.overrideAttrs (o: rec {
    name = "taskwarrior-${version}";
    version = "2019-08-11"; # 2.5.2 branch (dev, moving)
    src = super.fetchFromGitHub {
      owner = "GothenburgBitFactory";
      repo = "taskwarrior";
      rev = "e186d375dccda6b44bd72e900c900e0dd36a56cd";
      sha256 = "0pdlpv4jv02r00iy41hqbfn5sndrmh6fsgkw49a88ml5dvy9pq53";
      fetchSubmodules = true;
    };
    patches = [];
  });
}
