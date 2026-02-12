{
  fetchFromGitHub,
  file,
  findutils,
  forgejo-cli,
  gh,
  gnused,
  jq,
  lib,
  makeWrapper,
  manifest-tool,
  mktemp,
  ncurses,
  nix-update-script,
  runtimeShell,
  shellcheck,
  skopeo,
  stdenv,
  tea,
  xz,
  zip,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "flake-release";
  version = "0.11.3";

  src = fetchFromGitHub {
    owner = "spotdemo4";
    repo = "flake-release";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YUSlKcrnMFluPvVWigsXl3ulLHEvLSugXxK5puM8XvY=";
  };

  nativeBuildInputs = [
    makeWrapper
    shellcheck
  ];

  runtimeInputs = [
    file
    findutils
    forgejo-cli
    gh
    gnused
    jq
    manifest-tool
    mktemp
    ncurses
    skopeo
    tea
    xz
    zip
  ];

  unpackPhase = ''
    cp -a "$src/." .
  '';

  dontBuild = true;

  configurePhase = ''
    chmod +w src
    sed -i '1c\#!${runtimeShell}' src/flake-release.sh
    sed -i '2c\export PATH="${lib.makeBinPath finalAttrs.runtimeInputs}:$PATH"' src/flake-release.sh
  '';

  doCheck = true;
  checkPhase = ''
    shellcheck **/*.sh
  '';

  installPhase = ''
    mkdir -p $out/lib/flake-release
    cp -R src/*.sh $out/lib/flake-release

    mkdir -p $out/bin
    makeWrapper "$out/lib/flake-release/flake-release.sh" "$out/bin/flake-release"
  '';

  dontFixup = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      "${finalAttrs.pname}"
    ];
  };

  meta = {
    description = "Flake package releaser";
    mainProgram = "flake-release";
    homepage = "https://github.com/spotdemo4/flake-release";
    changelog = "https://github.com/spotdemo4/flake-release/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
