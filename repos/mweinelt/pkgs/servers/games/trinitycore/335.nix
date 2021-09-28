{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB335.21091";
  commit = "1526de722c9c81f1907de84054e342cd777e8501";
  branch = "3.3.5";
  sha256 = "0q5yr393zd16py2fxsf3nvh50fdh5xwfzlpnw4cp0pxkv6v1053y";
})
