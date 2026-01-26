{
  fetchFromGitHub,
  file,
  findutils,
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
  pname = "nix-flake-release";
  version = "0.9.5";

  src = fetchFromGitHub {
    owner = "spotdemo4";
    repo = "nix-flake-release";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jbr+krGbB4UHWT8JgYhpRrtOiGQhy62Ta2jCXQhzK94=";
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
    sed -i '1c\#!${runtimeShell}' src/nix-release.sh
    sed -i '2c\export PATH="${lib.makeBinPath finalAttrs.runtimeInputs}:$PATH"' src/nix-release.sh
  '';

  doCheck = true;
  checkPhase = ''
    shellcheck **/*.sh
  '';

  installPhase = ''
    mkdir -p $out/lib/nix-flake-release
    cp -R src/*.sh $out/lib/nix-flake-release

    mkdir -p $out/bin
    makeWrapper "$out/lib/nix-flake-release/nix-release.sh" "$out/bin/nix-flake-release"
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
    description = "Nix flake package releaser";
    mainProgram = "nix-flake-release";
    homepage = "https://github.com/spotdemo4/nix-flake-release";
    changelog = "https://github.com/spotdemo4/nix-flake-release/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
