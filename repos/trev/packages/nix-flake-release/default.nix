{
  fetchFromGitHub,
  file,
  findutils,
  gh,
  gnused,
  jq,
  lib,
  makeWrapper,
  mktemp,
  ncurses,
  nix,
  runtimeShell,
  shellcheck,
  skopeo,
  stdenv,
  xz,
  zip,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "nix-flake-release";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "spotdemo4";
    repo = "nix-flake-release";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CFW3+25CBuXxrl/f3NS477WCkErAmDQNrTJyH/4RHOg=";
  };

  nativeBuildInputs = [
    makeWrapper
    shellcheck
  ];

  runtimeInputs = [
    file
    findutils
    gh
    gnused
    jq
    mktemp
    ncurses
    nix
    skopeo
    xz
    zip
  ];

  unpackPhase = ''
    cp -a "$src/." .
  '';

  dontBuild = true;

  configurePhase = ''
    chmod +w src
    sed -i '1c\#!${runtimeShell}' src/start.sh
    sed -i '2c\export PATH="${lib.makeBinPath finalAttrs.runtimeInputs}:$PATH"' src/start.sh
  '';

  doCheck = true;
  checkPhase = ''
    shellcheck src/*.sh
  '';

  installPhase = ''
    mkdir -p $out/lib/nix-flake-release
    cp -R src/*.sh $out/lib/nix-flake-release

    mkdir -p $out/bin
    makeWrapper "$out/lib/nix-flake-release/start.sh" "$out/bin/nix-flake-release"
  '';

  dontFixup = true;

  meta = {
    description = "Nix flake package releaser";
    mainProgram = "nix-flake-release";
    homepage = "https://github.com/spotdemo4/nix-flake-release";
    changelog = "https://github.com/spotdemo4/nix-flake-release/releases/tag/v${finalAttrs.version}";
    platforms = lib.platforms.all;
  };
})
