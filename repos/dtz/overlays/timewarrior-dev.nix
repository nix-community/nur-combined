# Use at your own risk!
# Make backups!
self: super: {
  timewarrior = super.timewarrior.overrideAttrs (o: rec {
    name = "timewarrior-${version}";
    version = "2019-09-06";
    src = super.fetchFromGitHub {
      owner = "GothenburgBitFactory";
      repo = "timewarrior";
      rev = "cd0d5d175e6ce3c684514114b92efffb67448c37";
      sha256 = "0fsl8w7x6j1zdd7sb58i3gias46bmhlppshgdhmn75nkb613x544";
      fetchSubmodules = true;
    };
    #patches = [];
  });
}
