# originally from: https://github.com/skiletro/nur-repo/blob/cb52464145b84f9c15f7252635767b60f713fc6c/pkgs/vacuumtube/default.nix
{
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  electron,
  pkgs,
  stdenv,
  darwin,
  lib,
}:

buildNpmPackage rec {
  pname = "vacuumtube";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "shy1132";
    repo = "vacuumtube";
    rev = "v${version}";
    hash = "sha256-DbcJJ9FL9LPCQrg6lGa5N9KC8stXLdaMI+2hKAiZFxQ=";
  };

  npmDepsHash = "sha256-/TAGGiNuT7YC29U9n6M+zD51kecbAPXzzEJU5ey1hXs=";

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    NIX_CFLAGS_COMPILE = "-I${pkgs.nodejs}/include/node";
  };

  NODE_OPTIONS = "--openssl-legacy-provider";

  npmPackFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals (stdenv.hostPlatform.isLinux) [ copyDesktopItems ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ darwin.autoSignDarwinBinariesHook ];

  buildInputs = [
    electron
  ];

  dontNpmBuild = true;

  installPhase = ''
    runHook preInstall
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
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

  ''
  + ''
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "vacuumtube";
      exec = "vacuumtube";
      icon = "vacuumtube";
      desktopName = "VacuumTube";
      comment = "YouTube Leanback on the desktop";
      categories = [
        "AudioVideo"
        "Video"
        "Network"
      ];
      startupNotify = true;
      startupWMClass = "VacuumTube";
    })
  ];

  meta = with lib; {
    description = "YouTube Leanback on the desktop, with enhancements";
    homepage = "https://github.com/shy1132/VacuumTube";
    license = licenses.mit;
    platforms = platforms.unix;
    broken = stdenv.hostPlatform.isDarwin;
  };
}
