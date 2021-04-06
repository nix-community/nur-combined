{ lib, pkgs }:

with pkgs;

rustPlatform.buildRustPackage rec {
  pname = "eww";
  version = "unstable-2021-04-04";

  src = fetchFromGitHub {
    owner = "elkowar";
    repo = pname;
    rev = "11f595be2c7a08d276b6c8ce514a7a8d9d16ea95";
    sha256 = "sha256-W5feEHgQmqiTnAKHMXDxXVuEB2T/JPMRdLH41fTCF3o=";
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

  checkPhase = null;
  cargoSha256 = "sha256-gOy+pfd6CG81MvtBxMHiwseamGn80P+yfvmMMZoel40=";

  meta = with lib; {
    description = "A standalone widget system made in Rust to add AwesomeWM like widgets to any WM";
    homepage = "https://github.com/elkowar/eww";
    license = licenses.mit;
    maintainers = with maintainers; [ fortuneteller2k ];
  };
}
