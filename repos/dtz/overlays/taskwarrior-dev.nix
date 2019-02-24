# Use at your own risk!
# Make backups!
self: super: {
  taskwarrior = super.taskwarrior.overrideAttrs (o: rec {
    name = "taskwarrior-${version}";
    version = "2019-02-14";
    src = super.fetchFromGitHub {
      owner = "GothenburgBitFactory";
      repo = "taskwarrior";
      rev = "f6b2a6541c462eab1e89c3bbcb4610eca84ec295";
      sha256 = "13c9q6aikbzrhin5sf0l9754i7hmpc5pf28gkqfda3h732m7vzak";
      fetchSubmodules = true;
    };
    patches = [];
  });
}
