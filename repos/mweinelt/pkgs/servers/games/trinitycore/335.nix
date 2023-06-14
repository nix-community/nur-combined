{ callPackage, pkgs, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB335.23061";
  commit = "40d1f7a2e8fa54b3c9432b4432d6df968ec60cc4";
  branch = "3.3.5";
  sha256 = "sha256-G2a9NwkaP9KoOmKQYcDYY4FB3yoURY/WRhrDM6X/yg0=";
})
