{
  pkgs,
  nurLib,
  lib,
  symlinkJoin,
  makeWrapper,
  cargo,
  nix,
  nix-prefetch-git,
  nixVersions,
  fetchFromGitHub,
  crate2nix-package-update-script,
}:

let
  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "crate2nix";
    rev = "5e1ecfd2d15b34ec90c2e51fdffbe8116595a767";
    hash = "sha256-2577vxyoBa8+ZRiXr3CuPtOuEtPRYsFPSZuEc/KI/80=";
  };

  rawCrate2nix = nurLib.crate2nix {
    inherit src;
    pname = "crate2nix";
    resolvedJson = ./Cargo.json;
    buildRustCrateForPkgs = pkgs: pkgs.buildRustCrate;

    updateScriptExtraArgs = [
      "--version"
      "branch"
      "--cargo-toml"
      "crate2nix/Cargo.toml"
    ];

    meta = {
      description = "A tool to generate Nix expressions for Rust crates";
      mainProgram = "crate2nix";
      homepage = "https://github.com/nix-community/crate2nix";
      license = [
        pkgs.lib.licenses.mit
        pkgs.lib.licenses.asl20
      ];
    };
  };

in
symlinkJoin {
  inherit (rawCrate2nix)
    name
    pname
    version
    meta
    passthru
    ;
  paths = [ rawCrate2nix ];
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/crate2nix \
      --suffix PATH : ${
        lib.makeBinPath [
          cargo
          nix
          nix-prefetch-git
        ]
      }

    rm -rf $out/lib $out/bin/crate2nix.d
    mkdir -p \
      $out/share/bash-completion/completions \
      $out/share/zsh/vendor-completions

    $out/bin/crate2nix completions -s bash -o $out/share/bash-completion/completions
    $out/bin/crate2nix completions -s zsh -o $out/share/zsh/vendor-completions
  '';
}
