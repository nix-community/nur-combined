{
  lib,
  pkgs,
  fetchFromGitHub,
}: let
  version = "0.4.6";
  src = fetchFromGitHub {
    owner = "levinion";
    repo = "fzfmenu";
    rev = "cd1079164c18dc4715879a24b04035472c351367";
    hash = "sha256-+P4OGRQrstw57X0/HKfRdrCzjnAajBZkJkMFK04SR64=";
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
