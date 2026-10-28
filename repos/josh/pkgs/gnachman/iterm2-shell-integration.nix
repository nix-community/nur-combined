{
  lib,
  stdenvNoCC,
  fetchFromGitHub,

  bash,
  makeWrapper,
  perl,
  python3,

  nix-update-script,
  runCommand,
}:
let
  venv = python3.withPackages (ps: [ ps.iterm2 ]);
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "iterm2-shell-integration";
  version = "0-unstable-2026-10-28";

  src = fetchFromGitHub {
    owner = "gnachman";
    repo = "iTerm2-shell-integration";
    rev = "0296291dae9051913044f8f55c7e41990dfe6f47";
    hash = "sha256-4lhN55zvNJJZvc3qlgGm1v9dyYao9LPqB+1HCaFKKpk=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    bash
    perl
    venv
  ];

  buildCommand = ''
    mkdir -p $out/bin
    cp -r $src/utilities/* $out/bin/
    patchShebangs --host $out/bin
    for bin in $out/bin/*; do
      wrapProgram "$bin" --prefix PATH : ${lib.strings.makeBinPath finalAttrs.buildInputs}
    done

    mkdir -p $out/share/iterm2-shell-integration
    cp $src/shell_integration/bash $out/share/iterm2-shell-integration/iterm2_shell_integration.bash
    cp $src/shell_integration/fish $out/share/iterm2-shell-integration/iterm2_shell_integration.fish
    cp $src/shell_integration/tcsh $out/share/iterm2-shell-integration/iterm2_shell_integration.tcsh
    cp $src/shell_integration/zsh $out/share/iterm2-shell-integration/iterm2_shell_integration.zsh
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    help =
      runCommand "test-iterm2-shell-integration-help" { nativeBuildInputs = [ finalAttrs.finalPackage ]; }
        ''
          export HOME="$PWD"
          for bin in imgcat it2api it2cat it2copy it2getvar it2profile it2setcolor it2tip; do
            "$bin" --help
          done
          touch $out
        '';
  };

  meta = {
    description = "Shell integration and utilities for iTerm2";
    homepage = "https://github.com/gnachman/iTerm2-shell-integration";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.darwin;
  };
})
