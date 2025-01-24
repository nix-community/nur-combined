{
  fetchFromGitHub,
  glib,
  gperf,
  gtk3,
  gtk4,
  gtk-mac-integration,
  lib,
  pkg-config,
  stdenv,
  meson,
  ninja,
  flex,
  gobject-introspection,
  desktop-file-utils,
  shared-mime-info,
}:
stdenv.mkDerivation {
  pname = "gtkwave";
  version = "latest";

  src = fetchFromGitHub {
    owner = "gtkwave";
    repo = "gtkwave";
    rev = "4435a9ef89892757eaf703085606f10040da6bfe";
    sha256 = "sha256-JKPUUVQCl1X5z/FCisujCPCxUhrDw9hsmjnKMSqSZSU=";
  };

  buildInputs =
    [
      flex
      ninja
      pkg-config
      gtk3
      gtk4
      glib
      gperf
      gobject-introspection
      desktop-file-utils
      shared-mime-info
    ]
    ++ lib.optional stdenv.isDarwin gtk-mac-integration;

  configurePhase = ''
    meson setup build --prefix=$out
  '';

  nativeBuildInputs = [
    meson
    ninja
  ];

  buildPhase = ''
    meson compile -C build
  '';

  installPhase = ''
    meson install -C build
  '';

  meta = {
    description = "VCD/Waveform viewer for Unix and Win32";
    homepage = "https://gtkwave.github.io/gtkwave";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}

