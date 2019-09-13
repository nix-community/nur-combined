# Use at your own risk!
# Make backups!
self: super: {
  taskwarrior = super.taskwarrior.overrideAttrs (o: rec {
    name = "taskwarrior-${version}";
    version = "2019-03-20"; # 2.5.2 branch (dev, moving)
    src = super.fetchFromGitHub {
      owner = "GothenburgBitFactory";
      repo = "taskwarrior";
      rev = "82ed5d35b7d5994606873ccf1916e9af445d8b1c
";
      sha256 = "0rr9hya30jyzz7gxyjfmhbfkpaavr5i67yzgkzpfxyjq69zpm7ci";
      fetchSubmodules = true;
    };
    patches = [];
  });
}
