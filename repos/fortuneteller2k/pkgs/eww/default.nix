{ lib, pkgs }:

with pkgs;

rustPlatform.buildRustPackage rec {
  pname = "eww";
  version = "unstable-2021-03-03";

  src = fetchFromGitHub {
    owner = "elkowar";
    repo = pname;
    rev = "5cf18bfc43d84cad60f9a8df3a7a3038543f3dab";
    sha256 = "sha256-DMWYcSlS2tmu4Xd/f27ltiYUzEuMMUOD8HTmyg4xh6o=";
  };

  nativeBuildInputs = [ pkg-config rust-bin.nightly.latest.rust ];

  buildInputs = [
    gtk3
    cairo
    glib
    atk
    pango
    gdk-pixbuf
    gdk-pixbuf-xlib
  ];

  checkPhase = null;
  cargoSha256 = "sha256-ZzZEAxaWTueTKMrpxVxTat/bDZ0rU5WIWoS2AC83IOw=";

  meta = with lib; {
    description =
      "A standalone widget system made in Rust to add AwesomeWM like widgets to any WM";
    homepage = "https://github.com/elkowar/eww";
    license = licenses.mit;
    maintainers = with maintainers; [ fortuneteller2k ];
  };
}
