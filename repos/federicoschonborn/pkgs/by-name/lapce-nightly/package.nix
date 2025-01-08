{
  lib,
  stdenv,
  fetchFromGitHub,
  unstableGitUpdater,
  rustPlatform,
  cmake,
  pkg-config,
  perl,
  python3,
  fontconfig,
  glib,
  gtk3,
  openssl,
  libGL,
  libxkbcommon,
  wrapGAppsHook3,
  wayland,
  gobject-introspection,
  xorg,
  apple-sdk_11,
  darwin,
}:

let
  rpathLibs = lib.optionals stdenv.hostPlatform.isLinux [
    libGL
    libxkbcommon
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
    xorg.libXxf86vm
    xorg.libxcb
    wayland
  ];
in

rustPlatform.buildRustPackage rec {
  pname = "lapce-nightly";
  version = "0-unstable-2024-11-24";

  src = fetchFromGitHub {
    owner = "lapce";
    repo = "lapce";
    rev = "7100aa459e1d16f9255e148a8d9323835761822c";
    hash = "sha256-6XlIaLg4YVPV469X7rgHAfgcfp7VwkEu1+3c+hofPZk=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "alacritty_terminal-0.24.1-dev" = "sha256-aVB1CNOLjNh6AtvdbomODNrk00Md8yz8QzldzvDo1LI=";
      "floem-0.1.1" = "sha256-/4Y38VXx7wFVVEzjqZ2D6+jiXCXPfzK44rDiNOR1lAk=";
      "human-sort-0.2.2" = "sha256-tebgIJGXOY7pwWRukboKAzXY47l4Cn//0xMKQTaGu8w=";
      "locale_config-0.3.1-alpha.0" = "sha256-cCEO+dmU05TKkpH6wVK6tiH94b7k2686xyGxlhkcmAM=";
      "lsp-types-0.95.1" = "sha256-+tWqDBM5x/gvQOG7V3m2tFBZB7smgnnZHikf9ja2FfE=";
      "psp-types-0.1.0" = "sha256-/oFt/AXxCqBp21hTSYrokWsbFYTIDCrHMUBuA2Nj5UU=";
      "regalloc2-0.9.3" = "sha256-tzXFXs47LDoNBL1tSkLCqaiHDP5vZjvh250hz0pbEJs=";
      "structdesc-0.1.0" = "sha256-KiR0R2YWZ7BucXIIeziu2FPJnbP7WNSQrxQhcNlpx2Q=";
      "tracing-0.2.0" = "sha256-31jmSvspNstOAh6VaWie+aozmGu4RpY9Gx2kbBVD+CI=";
      "wasi-experimental-http-wasmtime-0.10.0" = "sha256-FuF3Ms1bT9bBasbLK+yQ2xggObm/lFDRyOvH21AZnQI=";
    };
  };

  # Get openssl-sys to use pkg-config
  env.OPENSSL_NO_VENDOR = 1;

  postPatch = ''
    substituteInPlace lapce-app/Cargo.toml --replace ", \"updater\"" ""
  '';

  nativeBuildInputs = [
    cmake
    gobject-introspection
    perl
    pkg-config
    python3
    wrapGAppsHook3 # FIX: No GSettings schemas are installed on the system
  ];

  buildInputs =
    rpathLibs
    ++ [
      glib
      gtk3
      openssl
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      fontconfig
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      apple-sdk_11
      darwin.libobjc
    ];

  postInstall =
    if stdenv.hostPlatform.isLinux then
      ''
        install -Dm0644 $src/extra/images/logo_color.svg $out/share/icons/hicolor/scalable/apps/dev.lapce.lapce.svg
        install -Dm0644 $src/extra/linux/dev.lapce.lapce.desktop $out/share/applications/lapce.desktop

        $STRIP -S $out/bin/lapce

        patchelf --add-rpath "${lib.makeLibraryPath rpathLibs}" $out/bin/lapce
      ''
    else
      ''
        mkdir $out/Applications
        cp -r extra/macos/Lapce.app $out/Applications
        ln -s $out/bin $out/Applications/Lapce.app/Contents/MacOS
      '';

  dontPatchELF = true;

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/lapce/lapce";
    hardcodeZeroVersion = true;
  };

  meta = {
    mainProgram = "lapce";
    description = "Lightning-fast and Powerful Code Editor written in Rust";
    homepage = "https://github.com/lapce/lapce";
    changelog = "https://github.com/lapce/lapce/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
