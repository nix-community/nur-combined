{
  lib,
  pkgs,
  fetchFromGitHub,
}: let
  version = "0.3.1";
  src = fetchFromGitHub {
    owner = "levinion";
    repo = "fzfmenu";
    rev = "8c5e0584f0b4d864a3354f6dc174d587ab2ebecc";
    hash = "sha256-LgBv2F/zObmzSrO0rbGOUFjnRfcr0iZkXWI21ioZ9UM=";
  };

  cargoNix = pkgs.callPackage ./Cargo.nix {inherit pkgs;};
in (cargoNix.rootCrate.build.override {
  crateOverrides =
    pkgs.defaultCrateOverrides
    // {
      fzfmenu = attrs: {
        inherit src;
        inherit version;
        meta = {
          description = "An application launcher based on fzf";
          homepage = "https://github.com/levinion/fzfmenu";
          changelog = "https://github.com/levinion/fzfmenu/releases";
          license = lib.licenses.gpl3Plus;
          maintainers = [lib.maintainers.inogai];
          mainProgram = "fzfmenu";
          platforms = lib.platforms.all;
        };
      };
    };
})
