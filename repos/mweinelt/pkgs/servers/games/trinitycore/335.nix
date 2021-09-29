{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB335.21091";
  commit = "1526de722c9c81f1907de84054e342cd777e8501";
  branch = "3.3.5";
  sha256 = "1jq0g42jda9b9rvbnnsh50kbag3yk9m0lns4vfy4h1wfz3l900v1";
})
