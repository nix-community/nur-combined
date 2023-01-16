{ callPackage, pkgs, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB335.23011";
  commit = "80884e32ef6e79b6de66fe02a16b0546282f75bb";
  branch = "3.3.5";
  sha256 = "sha256-i/YbCGyY2dG7Ot/Zr/K26ZuUzRSQY9PKF9lhVz3cedQ=";
})
