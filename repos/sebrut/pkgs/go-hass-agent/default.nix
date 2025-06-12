{
  stdenv,
  lib,
  pkgs,
  buildGoModule, # workaround till buildGoModule uses go 1.23 by default
  pkg-config,
  glfw,
  libX11,
  libXcursor,
  libXrandr,
  libXinerama,
  libXi,
  libXxf86vm,
  mage,
  writeShellScriptBin,
  git,
  ...
}:
buildGoModule rec {
  pname = "go-hass-agent";
  version = "13.2.7";

  src = pkgs.fetchFromGitHub {
    owner = "joshuar";
    repo = "go-hass-agent";
    rev = "v${version}";
    hash = "sha256-nec5gH/p65sfxNDD+5TEc7POP7B2MOA23aMqJ9aXAz8=";
  };

  vendorHash = "sha256-PVicvYGaZxNVUbmNCEGUd4BZklhgaSMKpeiy898YTbM=";

  doCheck = false;

  nativeBuildInputs =
    let
      fakeGit = writeShellScriptBin "git" ''
        if [[ $@ = "describe --tags --always --dirty" ]]; then
            echo "${version}"
        elif [[ $@ = "rev-parse --short HEAD" ]]; then
            echo "dummyrev"
        elif [[ $@ = "log --date=iso8601-strict -1 --pretty=%ct" ]]; then
            echo "0"
        else
            ${git}/bin/git $@
        fi
      '';
    in
    [
      fakeGit
      pkg-config
      mage
    ];
  buildInputs = [
    glfw
    libX11
    libXcursor
    libXrandr
    libXinerama
    libXi
    libXxf86vm
  ];

  buildPhase = ''
    runHook preBuild

    # Fixes “Error: error compiling magefiles” during build.
    export HOME=$(mktemp -d)

    mage -d build/magefiles -w . build:full

    runHook postBuild
  '';

  installPhase = ''
      runHook preInstall
      mv dist/go-hass-agent-amd64 dist/go-hass-agent
    install -Dt $out/bin dist/go-hass-agent
    runHook postInstall
  '';

  meta = {
    description = "A Home Assistant, native app for desktop/laptop devices.";
    homepage = "https://github.com/joshuar/go-hass-agent";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sebrut ];
    mainProgram = "go-hass-agent";
  };
}
