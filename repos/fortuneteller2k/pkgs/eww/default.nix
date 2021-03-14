{ lib, pkgs }:

with pkgs;

rustPlatform.buildRustPackage rec {
  pname = "eww";
  version = "unstable-2021-03-09";

  src = fetchFromGitHub {
    owner = "elkowar";
    repo = pname;
    rev = "c4cbdedec58d94fe4368da3bd740c07ea7907113";
    sha256 = "sha256-H1RdKwSqqwU2hJSCaNBp0DXimlhd0DUWUkD3nZYdTvs=";
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
  cargoSha256 = "sha256-YyYpezOkF7H44N+dIyU2ITwb8Sa8AFlH8bHvkk4gWa8=";

  meta = with lib; {
    description =
      "A standalone widget system made in Rust to add AwesomeWM like widgets to any WM";
    homepage = "https://github.com/elkowar/eww";
    license = licenses.mit;
    maintainers = with maintainers; [ fortuneteller2k ];
  };
}
