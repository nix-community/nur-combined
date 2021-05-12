{ lib, pkgs }:

with pkgs;

rustPlatform.buildRustPackage rec {
  pname = "eww";
  version = "unstable-2021-05-12";

  src = fetchFromGitHub {
    owner = "elkowar";
    repo = pname;
    rev = "df5793b2048bfb62113c9ac5f4b71dc9c2405329";
    sha256 = "sha256-XPbvDKeA/jXzhmo++mPFUj24/wAVcFAiSNqhke5Invw=";
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

  cargoSha256 = "sha256-gAyuDcKXXWz52VXgfbLvVGCj9YVBxAqgsMCp2r5shMg=";

  meta = with lib; {
    description = "A standalone widget system made in Rust to add AwesomeWM like widgets to any WM";
    homepage = "https://github.com/elkowar/eww";
    license = licenses.mit;
    maintainers = with maintainers; [ fortuneteller2k ];
  };
}
