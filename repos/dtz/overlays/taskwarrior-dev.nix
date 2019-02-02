# Use at your own risk!
# Make backups!
self: super: {
  taskwarrior = super.taskwarrior.overrideAttrs (o: rec {
    name = "taskwarrior-${version}";
    version = "2019-01-02";
    src = super.fetchFromGitHub {
      owner = "GothenburgBitFactory";
      repo = "taskwarrior";
      rev = "5ae4ed1076320cd4753e70a22f96367e6fff5ad7";
      sha256 = "05whgx19ys0clzc7x539y8p61djir23ab26vsjplfmj5k82da8k3";
      fetchSubmodules = true;
    };
    patches = [];
  });
}
