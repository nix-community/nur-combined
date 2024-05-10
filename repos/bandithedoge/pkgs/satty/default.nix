{
  pkgs,
  sources,
  ...
}:
pkgs.rustPlatform.buildRustPackage {
  inherit (sources.satty) pname src;
  version = sources.satty.date;
  cargoLock = sources.satty.cargoLock."Cargo.lock";

  nativeBuildInputs = with pkgs; [
    pkg-config
    copyDesktopItems
  ];

  buildInputs = with pkgs; [
    gtk4
    libadwaita
    libepoxy
  ];

  postInstall = ''
    mkdir -p $out/share/icons/hicolor/scalable/apps
    cp assets/satty.svg $out/share/icons/hicolor/scalable/apps
  '';
}
