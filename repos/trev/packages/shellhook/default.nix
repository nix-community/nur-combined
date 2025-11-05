{
  pkgs,
  runtimeShell,
  lib,
}:
pkgs.stdenv.mkDerivation (finalAttrs: {
  name = "shellhook";
  src = ./shellhook.sh;
  dontBuild = true;

  nativeBuildInputs = with pkgs; [
    shellcheck-minimal
  ];

  runtimeInputs = with pkgs; [
    git
    ncurses
    jq
    openssh
    nix
  ];

  passthru = {
    ref = "${pkgs.lib.meta.getExe finalAttrs.finalPackage}";
  };

  unpackPhase = ''
    cp "$src" .
    mv *shellhook.sh shellhook.sh
  '';

  configurePhase = ''
    echo "#!${runtimeShell}" >> shellhook
    echo "${lib.concatMapStringsSep "\n" (option: "set -o ${option}") [
      "errexit"
      "nounset"
      "pipefail"
    ]}" >> shellhook
    echo 'export PATH="${lib.makeBinPath finalAttrs.runtimeInputs}:$PATH"' >> shellhook
    tail -n +2 shellhook.sh >> shellhook
    chmod +x shellhook
  '';

  doCheck = true;
  checkPhase = ''
    shellcheck ./shellhook
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp shellhook $out/bin/shellhook
  '';

  meta = {
    description = "shellHook for devShells";
    mainProgram = "shellhook";
    homepage = "https://github.com/spotdemo4/nur/tree/main/pkgs/shellhook/shellhook.sh";
    platforms = lib.platforms.all;
  };
})
