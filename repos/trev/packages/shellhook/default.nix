{
  git,
  jq,
  lib,
  ncurses,
  nix,
  openssh,
  runtimeShell,
  shellcheck-minimal,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  name = "shellhook";
  src = ./shellhook.sh;
  dontBuild = true;

  nativeBuildInputs = [
    shellcheck-minimal
  ];

  runtimeInputs = [
    git
    ncurses
    jq
    openssh
    nix
  ];

  passthru = {
    ref = "${lib.meta.getExe finalAttrs.finalPackage}";
  };

  unpackPhase = ''
    cp "$src" .
    mv *shellhook.sh shellhook.sh
  '';

  configurePhase = ''
    echo "#!${runtimeShell}" >> shellhook
    echo "${
      lib.concatMapStringsSep "\n" (option: "set -o ${option}") [
        "errexit"
        "nounset"
        "pipefail"
      ]
    }" >> shellhook
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
    description = "Shell hook for nix development shells";
    mainProgram = "shellhook";
    homepage = "https://github.com/spotdemo4/nur/tree/main/pkgs/shellhook/shellhook.sh";
    platforms = lib.platforms.all;
  };
})
