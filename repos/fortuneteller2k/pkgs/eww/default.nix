{ lib, pkgs }:

with pkgs;

rustPlatform.buildRustPackage rec {
  pname = "eww";
  version = "unstable-2021-02-27";

  src = fetchFromGitHub {
    owner = "elkowar";
    repo = pname;
    rev = "a18901f187ff850a21a24c0c59022c0a5382ffd9";
    sha256 = "sha256-iHHXv1R9X5is0A5GwMFSHEdi043Ad9FdFUQ4YtZ3w+s=";
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
  cargoSha256 = "sha256-VrA/t+qPuREFULaKFnXzCCyAul/OXLX791ZL+D0PBSY=";

  meta = with lib; {
    description =
      "A standalone widget system made in Rust to add AwesomeWM like widgets to any WM";
    homepage = "https://github.com/elkowar/eww";
    license = licenses.mit;
  };
}
