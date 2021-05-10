{ lib, pkgs }:

with pkgs;

rustPlatform.buildRustPackage rec {
  pname = "eww";
  version = "unstable-2021-05-09";

  src = fetchFromGitHub {
    owner = "elkowar";
    repo = pname;
    rev = "6eea3e039d8362600df4030a29c84cf2f572809b";
    sha256 = "sha256-DnZDfvPhqMd6bNEmAwJfcufy0Ce9mSXyZknz0I1oV00=";
  };

  nativeBuildInputs = [
    wrapGAppsHook
    pkg-config
    rust-bin.nightly.latest.default
  ];

  buildInputs = [
    gtk3
    cairo
    glib
    atk
    pango
    gdk-pixbuf
    gdk-pixbuf-xlib
    wayland
    wayland-protocols
    gtk-layer-shell
  ];

  # NOTE: Compile times are longer with the checkPhase enabled, this is NUR so *we don't care*
  checkPhase = null;

  cargoSha256 = "sha256-xywnAUeEq2eFtBgcmnYafe7i+rfgZtMo8ZZdBiLuW00=";

  meta = with lib; {
    description = "A standalone widget system made in Rust to add AwesomeWM like widgets to any WM";
    homepage = "https://github.com/elkowar/eww";
    license = licenses.mit;
    maintainers = with maintainers; [ fortuneteller2k ];
  };
}
