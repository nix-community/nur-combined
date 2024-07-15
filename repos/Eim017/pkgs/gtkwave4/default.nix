{
  fetchFromGitHub,
  glib,
  gperf,
  gtk3,
  gtk-mac-integration,
  judy,
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
    rev = "27f3a94aede651f232314d0fe0c86cc35308fa85";
    sha256 = "sha256-RxEI1dTMrrFccxuYkb9GQzuFrzTiWOnnfEBR7V918c8=";
  };

  buildInputs =
    [
      flex
      ninja
      pkg-config
      gtk3
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

