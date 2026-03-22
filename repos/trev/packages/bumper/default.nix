{
  fetchFromGitHub,
  gnused,
  jq,
  lib,
  makeWrapper,
  ncurses,
  nix-update-script,
  nix-update,
  runtimeShell,
  shellcheck,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bumper";
  version = "0.11.1";

  src = fetchFromGitHub {
    owner = "spotdemo4";
    repo = "bumper";
    tag = "v${finalAttrs.version}";
    hash = "sha256-st/e7Y6Xw75RfY/3aeRBa+9JGLxzuTcvGLP4ssuF0H8=";
  };

  nativeBuildInputs = [
    makeWrapper
    shellcheck
  ];

  runtimeInputs = [
    ncurses
    gnused
    jq

    # nix
    nix-update
  ];

  unpackPhase = ''
    cp -a "$src/." .
  '';

  dontBuild = true;

  configurePhase = ''
    chmod +w src
    sed -i '1c\#!${runtimeShell}' src/bumper.sh
    sed -i '2c\export PATH="${lib.makeBinPath finalAttrs.runtimeInputs}:$PATH"' src/bumper.sh
  '';

  doCheck = true;
  checkPhase = ''
    shellcheck **/*.sh
  '';

  installPhase = ''
    mkdir -p $out/lib/bumper
    cp -R src/*.sh $out/lib/bumper

    mkdir -p $out/bin
    makeWrapper "$out/lib/bumper/bumper.sh" "$out/bin/bumper"
  '';

  dontFixup = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      finalAttrs.pname
    ];
  };

  meta = {
    description = "Git semantic version bumper";
    mainProgram = "bumper";
    homepage = "https://github.com/spotdemo4/bumper";
    changelog = "https://github.com/spotdemo4/bumper/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
