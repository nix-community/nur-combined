{ lib, pkgs }:

with pkgs;

rustPlatform.buildRustPackage rec {
  pname = "eww";
  version = "unstable-2021-03-28";

  src = fetchFromGitHub {
    owner = "elkowar";
    repo = pname;
    rev = "8436b666c292c3479916577c3142421f9455560c";
    sha256 = "sha256-K94Utgw+0oFnVmmyQQ4CbSeiRkAviDGoilSy6D/jmMY=";
  };

  cargoPatches = [ ./update-cargo-lock.patch ];

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
  cargoSha256 = "sha256-9OefhdIHK252Cu/xVmET2oh1YkPpe/Vt4YrBS+lSSUc=";

  meta = with lib; {
    description =
      "A standalone widget system made in Rust to add AwesomeWM like widgets to any WM";
    homepage = "https://github.com/elkowar/eww";
    license = licenses.mit;
    maintainers = with maintainers; [ fortuneteller2k ];
  };
}
