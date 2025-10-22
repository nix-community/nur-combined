{
  fetchFromGitHub,
  lib,
  rustPlatform,
  glib,
  pango,
  cairo,
  gdk-pixbuf,
  gtk3,
  pkg-config,
}:
rustPlatform.buildRustPackage rec {
  pname = "waybar-vd";
  version = "0.1.1";
  cargoLock.lockFile = ./Cargo.lock;
  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  src = fetchFromGitHub {
    owner = "givani30";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-G1zIBh0djVcHnXIGDlyVP6DjYMtXOnj2Xiyu6kyo0G8=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    glib
    pango
    cairo
    gdk-pixbuf
    gtk3
  ];

  meta = with lib; {
    description = "A high-performance CFFI module for Waybar that displays Hyprland virtual desktops with real-time updates and click handling.";
    homepage = "https://github.com/givani30/waybar-vd";
    license = with licenses; [mit];
    platforms = with platforms; (intersectLists x86_64 linux);
    sourceProvenance = with sourceTypes; [fromSource];
  };
}
