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
}:

let
  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "crate2nix";
    rev = "1cb60331b14f15dad145dbd4e207c1ec110e5675";
    hash = "sha256-S2NrwKB7aQa6HZsg2UGCmzQPI5Dw+bqUPm8R23BAUh8=";
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
