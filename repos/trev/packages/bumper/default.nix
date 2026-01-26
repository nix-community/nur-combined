{
  cargo-edit,
  cargo,
  fetchFromGitHub,
  gnused,
  jq,
  lib,
  makeWrapper,
  ncurses,
  nix-update-script,
  nix-update,
  nodejs_latest,
  python3,
  runtimeShell,
  shellcheck,
  stdenv,
  uv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "bumper";
  version = "0.10.2";

  src = fetchFromGitHub {
    owner = "spotdemo4";
    repo = "bumper";
    tag = "v${finalAttrs.version}";
    hash = "sha256-o7tgHpVt9vt33323Um4Xjv/WxPkN0wQZOYzruZFvy1g=";
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

    # python
    python3
    uv
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

  passthru = {
    updateScript = lib.concatStringsSep " " (nix-update-script {
      extraArgs = [
        "--commit"
        "${finalAttrs.pname}"
      ];
    });
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
