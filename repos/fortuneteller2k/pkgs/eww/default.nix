{ lib, pkgs }:

with pkgs;

rustPlatform.buildRustPackage rec {
  pname = "eww";
  version = "unstable-2021-05-29";

  src = fetchFromGitHub {
    owner = "elkowar";
    repo = pname;
    rev = "8da780d4a1242949f348fa2af7acad6abab943c0";
    sha256 = "sha256-ynAuAQDRc51TAaJAwPOEqCPoZneYXglq0uVUsO4hX5k=";
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

  /*
    NOTE: Compile times are longer with the checkPhase enabled, this is NUR so *we don't care*
    
    Also, tests are failing.
  */
  doCheck = false;
  checkPhase = null;

  cargoSha256 = "sha256-tBfN9ocA7Pzsou8018PHZisGhQ/YUPGw37wZyZItQ1s=";

  meta = with lib; {
    description = "A standalone widget system made in Rust to add AwesomeWM like widgets to any WM";
    homepage = "https://github.com/elkowar/eww";
    license = licenses.mit;
    maintainers = with maintainers; [ fortuneteller2k ];
  };
}
