# Use at your own risk!
# Make backups!
self: super: {
  timewarrior = super.timewarrior.overrideAttrs (o: rec {
    name = "timewarrior-${version}";
    version = "2018-10-19";
    src = super.fetchFromGitHub {
      owner = "GothenburgBitFactory";
      repo = "timewarrior";
      rev = "72cfe7b4d8ee38016bc5565796797c5de052e7f1";
      sha256 = "0dgyfvcqlzlgwqqcb005cz7j5qqsnhhzmvvldcpa0yqlv1l2hs2w";
      fetchSubmodules = true;
    };
    #patches = [];
  });
}
