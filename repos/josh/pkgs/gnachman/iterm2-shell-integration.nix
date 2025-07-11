{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  bash,
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
  version = "0-unstable-2025-07-10";

  src = fetchFromGitHub {
    owner = "gnachman";
    repo = "iTerm2-shell-integration";
    rev = "25bad779fbf0165543b9ab50a101cbc0852d7cc9";
    hash = "sha256-NkdmvzGOO1T3YDlgGauDrjxqYSfZgnUDmhsR4SIybR0=";
  };

  __structuredAttrs = true;

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.strings.makeBinPath [
      bash
      perl
      venv
    ])
  ];

  nativeBuildInputs = [ makeWrapper ];

  buildCommand = ''
    mkdir -p $out/bin
    cp -r $src/utilities/* $out/bin/
    for bin in $out/bin/*; do
      wrapProgram "$bin" "''${makeWrapperArgs[@]}"
    done

    mkdir -p $out/share/iterm2-shell-integration
    cp $src/shell_integration/bash $out/share/iterm2-shell-integration/iterm2_shell_integration.bash
    cp $src/shell_integration/fish $out/share/iterm2-shell-integration/iterm2_shell_integration.fish
    cp $src/shell_integration/tcsh $out/share/iterm2-shell-integration/iterm2_shell_integration.tcsh
    cp $src/shell_integration/zsh $out/share/iterm2-shell-integration/iterm2_shell_integration.zsh
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests =
    let
      pkg = finalAttrs.finalPackage;
    in
    {
      imgcat-help = runCommand "test-imgcat-help" { nativeBuildInputs = [ pkg ]; } ''
        imgcat --help
        touch $out
      '';

      it2api-help = runCommand "test-it2api-help" { nativeBuildInputs = [ pkg ]; } ''
        it2api --help
        touch $out
      '';

      it2cat-help = runCommand "test-it2cat-help" { nativeBuildInputs = [ pkg ]; } ''
        it2cat --help
        touch $out
      '';

      it2copy-help = runCommand "test-it2copy-help" { nativeBuildInputs = [ pkg ]; } ''
        it2copy --help
        touch $out
      '';

      it2getvar-help = runCommand "test-it2getvar-help" { nativeBuildInputs = [ pkg ]; } ''
        it2getvar --help
        touch $out
      '';

      it2profile-help = runCommand "test-it2profile-help" { nativeBuildInputs = [ pkg ]; } ''
        it2profile --help
        touch $out
      '';

      it2setcolor-help = runCommand "test-it2setcolor-help" { nativeBuildInputs = [ pkg ]; } ''
        it2setcolor --help
        touch $out
      '';

      it2tip-help = runCommand "test-it2tip-help" { nativeBuildInputs = [ pkg ]; } ''
        export HOME="$PWD"
        it2tip --help
        touch $out
      '';
    };

  meta = {
    description = "Shell integration and utilities for iTerm2";
    homepage = "https://github.com/gnachman/iTerm2-shell-integration";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.darwin;
  };
})
