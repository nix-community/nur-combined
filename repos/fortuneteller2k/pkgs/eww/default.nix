{ lib, pkgs }:

with pkgs;

rustPlatform.buildRustPackage rec {
  pname = "eww";
  version = "unstable-2021-04-22";

  src = fetchFromGitHub {
    owner = "elkowar";
    repo = pname;
    rev = "ca7ff95f2ccc7005190070a3974fe88c165cd956";
    sha256 = "sha256-O5bOXL1l+AYvyqHMdqvY7fWOLsH6/L2gYWf72+Ld7nI=";
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
  ];

  # NOTE: Compile times are longer with the checkPhase enabled, this is NUR so *we don't care*
  checkPhase = null;

  cargoSha256 = "sha256-Bzqs2Rln1g1ZmmJW9n18g2qIB2BeeAtsYFi2PurMOoA=";

  meta = with lib; {
    description = "A standalone widget system made in Rust to add AwesomeWM like widgets to any WM";
    homepage = "https://github.com/elkowar/eww";
    license = licenses.mit;
    maintainers = with maintainers; [ fortuneteller2k ];
  };
}
