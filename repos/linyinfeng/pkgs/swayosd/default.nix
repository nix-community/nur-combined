{
  sources,
  rustc,
  rustPlatform,
  lib,
  pkg-config,
  autoconf,
  automake,
  libtool,
  python3,
  glib,
  gtk3,
  gtk-layer-shell,
  pulseaudio,
  udev,
  libinput,
}:

rustPlatform.buildRustPackage {
  inherit (sources.swayosd) pname version src;
  cargoLock = sources.swayosd.cargoLock."Cargo.lock";

  nativeBuildInputs = [
    pkg-config
    autoconf
    automake
    libtool
    python3
    glib
  ];
  buildInputs = [
    gtk3
    gtk-layer-shell
    pulseaudio
    udev
    libinput
  ];

  meta = with lib; {
    homepage = "https://github.com/ErikReider/SwayOSD";
    description = "A GTK based on screen display for keyboard shortcuts like caps-lock and volume";
    license = licenses.gpl3;
    maintainers = with maintainers; [ yinfeng ];
    broken = !(lib.versionAtLeast rustc.version "1.75");
  };
}
