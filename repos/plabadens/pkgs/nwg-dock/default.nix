{ lib
, buildGoModule
, fetchFromGitHub
, pkg-config
, cairo
, gobject-introspection
, gtk3
, gtk-layer-shell
}:

buildGoModule rec {
  pname = "nwg-dock";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "nwg-piotr";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-0y4Kes8U1fg+ibawxIdYTi6Tlqj/BAz4G5qBL1EgLCE=";
  };

  vendorSha256 = "sha256-HyrjquJ91ddkyS8JijHd9HjtfwSQykXCufa2wzl8RNk=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ cairo gobject-introspection gtk3 gtk-layer-shell ];

  meta = with lib; {
    description = "Application drawer for sway Wayland compositor";
    homepage = "https://github.com/nwg-piotr/nwg-dock";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ plabadens ];
  };
}
