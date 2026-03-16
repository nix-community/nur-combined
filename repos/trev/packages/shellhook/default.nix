{
  git,
  jq,
  lib,
  ncurses,
  nix,
  openssh,
  runtimeShell,
  shellcheck-minimal,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  name = "shellhook";
  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./shellhook.sh
      ./pre-push.sh
    ];
  };

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
    cp -a "$src/." .
    chmod -R a+w .
  '';

  dontConfigure = true;

  buildPhase = ''
    echo "#!${runtimeShell}" >> shellhook
    echo 'export PATH="${lib.makeBinPath finalAttrs.runtimeInputs}:$PATH"' >> shellhook
    echo "prepush=$out/etc/pre-push" >> shellhook
    tail -n +4 shellhook.sh >> shellhook
    chmod +x shellhook
  '';

  doCheck = true;
  checkPhase = ''
    shellcheck shellhook
  '';

  installPhase = ''
    mkdir -p $out/bin $out/etc
    cp pre-push.sh $out/etc/pre-push
    cp shellhook $out/bin/shellhook
  '';

  meta = {
    description = "Shell hook for nix development shells";
    mainProgram = "shellhook";
    homepage = "https://github.com/spotdemo4/nur/tree/main/pkgs/shellhook/shellhook.sh";
    platforms = lib.platforms.all;
  };
})
