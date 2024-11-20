{
  sources,
  lib,
  stdenv,
  meson,
  ninja,
  rustPlatform,
  rustc,
  cargo,
  glib,
  sassc,
  pkg-config,

  libevdev,
  gtk4,
  gtk4-layer-shell,
  pulseaudio,
  libinput,
}:
stdenv.mkDerivation {
  inherit (sources.swayosd) pname version src;

  patches = [ ./systemd-service-install-dir.patch ];

  nativeBuildInputs = [
    meson
    rustPlatform.cargoSetupHook
    rustc
    cargo
    glib
    sassc
    pkg-config
    ninja
  ];
  buildInputs = [
    libevdev
    gtk4
    gtk4-layer-shell
    pulseaudio
    libinput
  ];

  cargoDeps = rustPlatform.importCargoLock sources.swayosd.cargoLock."Cargo.lock";

  meta = with lib; {
    homepage = "https://github.com/ErikReider/SwayOSD";
    description = "A GTK based on screen display for keyboard shortcuts like caps-lock and volume";
    license = licenses.gpl3;
    maintainers = with maintainers; [ yinfeng ];
    broken = !(lib.versionAtLeast rustc.version "1.75");
  };
}
