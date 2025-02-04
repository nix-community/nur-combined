{
  lib,
  stdenv,
  fetchFromGitHub,
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
  nix-update-script,
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
  version = "nightly";

  src = fetchFromGitHub {
    owner = "lapce";
    repo = "lapce";
    rev = "7100aa459e1d16f9255e148a8d9323835761822c";
    hash = "sha256-6XlIaLg4YVPV469X7rgHAfgcfp7VwkEu1+3c+hofPZk=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-cgSr1GHQUF4ccVd9w3TT0+EI+lqQpDzfXHdRWr75eDE=";

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

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "unstable"
    ];
  };

  meta = {
    mainProgram = "lapce";
    description = "Lightning-fast and Powerful Code Editor written in Rust";
    homepage = "https://github.com/lapce/lapce";
    changelog = "https://github.com/lapce/lapce/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
}
