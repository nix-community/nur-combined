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
  version = "0-unstable-2026-07-29";

  src = fetchFromGitHub {
    owner = "gnachman";
    repo = "iTerm2-shell-integration";
    rev = "195281b1557531acc61af5f0bce56ecb6b3fe293";
    hash = "sha256-x2+5pCz/QOg8Lbuykn7gRJeQ2mhWEupWb16/bNnNxAw=";
  };

  __structuredAttrs = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    bash
    perl
    venv
  ];

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

  buildCommand = ''
    mkdir -p $out/bin
    cp -r $src/utilities/* $out/bin/
    patchShebangs --host $out/bin
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
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.darwin;
  };
})
