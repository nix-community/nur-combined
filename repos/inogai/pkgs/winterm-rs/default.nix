{
  lib,
  pkgs,
  fetchFromGitHub,
}: let
  version = "0.2.0";
  src = fetchFromGitHub {
    owner = "inogai";
    repo = "winterm-rs";
    rev = "387c5a429bc176d9acef604a900e580e6576e83f";
    hash = "sha256-h7rjh98zL8yAFuwdTh/M69FINbXrCrhPOh8PFCHK7NI=";
  };

  cargoNix = pkgs.callPackage ./Cargo.nix {inherit pkgs;};
in (cargoNix.rootCrate.build.override {
  crateOverrides =
    pkgs.defaultCrateOverrides
    // {
      winterm-rs = attrs: {
        inherit src;
        inherit version;
        meta = {
          description = "A snowfall animation in your terminal";
          homepage = "https://github.com/inogai/winterm-rs";
          changelog = "https://github.com/inogai/winterm-rs/releases";
          license = lib.licenses.mit;
          maintainers = [lib.maintainers.inogai];
          mainProgram = "winterm-rs";
          platforms = lib.platforms.all;
        };
      };
    };
})
