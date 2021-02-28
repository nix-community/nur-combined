{ rustPlatform, lib, fetchFromGitHub, rust, gtk3, cairo, glib, atk, pango, gdk-pixbuf, gdk-pixbuf-xlib, pkg-config }:

rustPlatform.buildRustPackage rec {
  pname = "eww";
  version = "unstable-2021-02-27";

  src = fetchFromGitHub {
    owner = "elkowar";
    repo = pname;
    rev = "a18901f187ff850a21a24c0c59022c0a5382ffd9";
    sha256 = "sha256-okA97zqP/IUrc4YVwQBt2jBvvC+W2mBd5wZfcFVRMbA=";
  };

  nativeBuildInputs = [ rust pkg-config ];
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
  cargoSha256 = "sha256-23FBMJ0E9laHzsTg6n24k4o61jBrjvLXF3zPvoCvHpU=";

  meta = with lib; {
    broken = true;
    description =
      "A standalone widget system made in Rust to add AwesomeWM like widgets to any WM";
    homepage = "https://github.com/elkowar/eww";
    license = licenses.mit;
    maintainers = with maintainers; [ fortuneteller2k ];
  };
}
