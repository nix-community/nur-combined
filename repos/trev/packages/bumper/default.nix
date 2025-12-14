{
  cargo-edit,
  cargo,
  fetchFromGitHub,
  gnused,
  jq,
  lib,
  makeWrapper,
  ncurses,
  nix-update,
  nodejs_latest,
  runtimeShell,
  shellcheck,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "bumper";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "spotdemo4";
    repo = "bumper";
    tag = "v${finalAttrs.version}";
    hash = "sha256-b6kAJxkwMOERp4C0in3INg9BUnXNYpAy9kb9SGb04g4=";
  };

  nativeBuildInputs = [
    makeWrapper
    shellcheck
  ];

  runtimeInputs = [
    jq
    ncurses
    gnused

    # rust
    cargo
    cargo-edit

    # nix
    nix-update

    # node
    nodejs_latest
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
    shellcheck src/*.sh
  '';

  installPhase = ''
    mkdir -p $out/lib/bumper
    cp -R src/*.sh $out/lib/bumper

    mkdir -p $out/bin
    makeWrapper "$out/lib/bumper/bumper.sh" "$out/bin/bumper"
  '';

  dontFixup = true;

  meta = {
    description = "Git semantic version bumper";
    mainProgram = "bumper";
    homepage = "https://github.com/spotdemo4/bumper";
    changelog = "https://github.com/spotdemo4/bumper/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
