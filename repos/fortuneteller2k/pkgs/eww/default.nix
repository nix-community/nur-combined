{ lib, pkgs }:

with pkgs;

rustPlatform.buildRustPackage rec {
  pname = "eww";
  version = "unstable-2021-04-14";

  src = fetchFromGitHub {
    owner = "elkowar";
    repo = pname;
    rev = "aaac4c3b43bbbb5085f0545ba95d16d0b2b8cf6f";
    sha256 = "sha256-WFIBynTlqM3LPI0JiqPmHu4/1201IZqj1q6jcYi6lDg=";
  };

  nativeBuildInputs = [ wrapGAppsHook pkg-config rust-bin.nightly.latest.rust ];

  buildInputs = [
    gtk3
    cairo
    glib
    atk
    pango
    gdk-pixbuf
    gdk-pixbuf-xlib
  ];

  # NOTE: Compile times are longer with the checkPhase enabled, this is NUR so *we don't care*
  checkPhase = null;

  cargoSha256 = "sha256-0qfsSnAk31CtMXTYqX3BEhQUj60W+mtGJsiCy2kNz4Q=";

  meta = with lib; {
    description = "A standalone widget system made in Rust to add AwesomeWM like widgets to any WM";
    homepage = "https://github.com/elkowar/eww";
    license = licenses.mit;
    maintainers = with maintainers; [ fortuneteller2k ];
  };
}
