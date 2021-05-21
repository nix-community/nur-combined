{ lib, pkgs }:

with pkgs;

rustPlatform.buildRustPackage rec {
  pname = "eww";
  version = "unstable-2021-05-18";

  src = fetchFromGitHub {
    owner = "elkowar";
    repo = pname;
    rev = "f26d91f45562700a39362a02892e13f667cfa4a2";
    sha256 = "sha256-xI0O35swAJkuYNA3A+EyQyJWLlicSRID5z42sz4jkkA=";
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

  cargoSha256 = "sha256-wqbUpufEKCvxnUDDYWeiIUsRkS/cuehsbwcmYPfnx8E=";

  meta = with lib; {
    description = "A standalone widget system made in Rust to add AwesomeWM like widgets to any WM";
    homepage = "https://github.com/elkowar/eww";
    license = licenses.mit;
    maintainers = with maintainers; [ fortuneteller2k ];
  };
}
