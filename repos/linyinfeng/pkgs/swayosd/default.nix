{ sources
, rustPlatform
, lib
, pkg-config
, gtk3
, gtk-layer-shell
, pulseaudio
}:

rustPlatform.buildRustPackage
rec {
  inherit (sources.swayosd) pname version src;
  cargoLock = sources.swayosd.cargoLock."Cargo.lock";

  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    gtk3
    gtk-layer-shell
    pulseaudio
  ];

  meta = with lib; {
    homepage = "https://github.com/ErikReider/SwayOSD";
    description = "A GTK based on screen display for keyboard shortcuts like caps-lock and volume";
    license = licenses.gpl3;
    maintainers = with maintainers; [ yinfeng ];
  };
}
