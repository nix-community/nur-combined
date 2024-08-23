{ lib, stdenv
, bash
, bubblewrap
, coreutils
, iproute2
, iptables
, landlock-sandboxer
, libcap
, passt
, substituteAll
, profileDir ? "/share/sanebox/profiles"
}:
stdenv.mkDerivation {
  pname = "sanebox";
  version = "0.1";

  src = ./sanebox;
  dontUnpack = true;

  buildInputs = [
    bash  # for cross builds, to ensure #!/bin/sh is substituted
  ];

  buildPhase = ''
    runHook preBuild
    substitute $src sanebox \
      --replace-fail '@bwrap@' '${lib.getExe bubblewrap}' \
      --replace-fail '@capsh@' '${lib.getExe' libcap "capsh"}' \
      --replace-fail '@env@' '${lib.getExe' coreutils "env"}' \
      --replace-fail '@ip@' '${lib.getExe' iproute2 "ip"}' \
      --replace-fail '@iptables@' '${lib.getExe' iptables "iptables"}' \
      --replace-fail '@landlockSandboxer@' '${lib.getExe landlock-sandboxer}' \
      --replace-fail '@pasta@' '${lib.getExe' passt "pasta"}' \
      --replace-fail '@readlink@' '${lib.getExe' coreutils "readlink"}' \

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -d "$out"
    install -d "$out/bin"
    install -m 755 sanebox $out/bin/sanebox
    runHook postInstall
  '';

  passthru = {
    interpreter = lib.getBin bash;
    runtimeDeps = [
      bubblewrap
      coreutils
      landlock-sandboxer
      libcap
      passt
    ];
  };

  meta = {
    description = ''
      helper program to run some other program in a sandbox.
      factoring this out allows:
      1. to abstract over the particular sandbox implementation (bwrap, landlock, ...).
      2. to modify sandbox settings without forcing a rebuild of the sandboxed package.
    '';
    mainProgram = "sanebox";
  };
}
