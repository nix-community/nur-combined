{ lib, pkgs }:

with pkgs;

rustPlatform.buildRustPackage rec {
  pname = "eww";
  version = "unstable-2021-05-04";

  src = fetchFromGitHub {
    owner = "elkowar";
    repo = pname;
    rev = "9ea20cd7537bd9637c42e36ba260e360f5d51440";
    sha256 = "sha256-LPA2wu5ACv2n+y0JLD7o8q3JTtCzjcEGzLNmL8DZBkI=";
  };

  nativeBuildInputs = [
    wrapGAppsHook
    pkg-config
    # FIXME: something broke when using the latest rust nightly
    rust-bin.nightly."2021-04-20".default
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

  cargoSha256 = "sha256-IAEGNepyIMXtXgvl/Y4G64WBvDEiIrkPIOoFgN74zwg=";

  meta = with lib; {
    description = "A standalone widget system made in Rust to add AwesomeWM like widgets to any WM";
    homepage = "https://github.com/elkowar/eww";
    license = licenses.mit;
    maintainers = with maintainers; [ fortuneteller2k ];
  };
}
