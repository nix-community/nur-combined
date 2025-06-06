{
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  electron,
  pkgs,
}:
buildNpmPackage rec {
  pname = "vacuumtube";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "shy1132";
    repo = "vacuumtube";
    rev = "v${version}";
    hash = "sha256-KmCrod5ud03EDut9RJpeKP3dIzKmR2FqGfzMFFSADRE=";
  };

  npmDepsHash = "sha256-tExOMbZsQxYfzRcFidNnLDyMTjLMOsEDws8mjxZSuM0=";

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    NIX_CFLAGS_COMPILE = "-I${pkgs.nodejs}/include/node";
  };

  NODE_OPTIONS = "--openssl-legacy-provider";

  npmPackFlags = ["--ignore-scripts"];

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    electron
  ];

  dontNpmBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/vacuumtube
    cp -r . $out/lib/vacuumtube/

    mkdir -p $out/bin
    makeWrapper ${electron}/bin/electron $out/bin/vacuumtube \
      --add-flags $out/lib/vacuumtube \
      --set-default ELECTRON_IS_DEV 0

    # Install icon if it exists
    if [ -f assets/icon.png ]; then
      mkdir -p $out/share/pixmaps
      cp assets/icon.png $out/share/pixmaps/vacuumtube.png
    fi

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "vacuumtube";
      exec = "vacuumtube";
      icon = "vacuumtube";
      desktopName = "VacuumTube";
      comment = "YouTube Leanback on the desktop";
      categories = ["AudioVideo" "Video" "Network"];
      startupNotify = true;
      startupWMClass = "VacuumTube";
    })
  ];

  meta.description = "YouTube Leanback on the desktop";
}
