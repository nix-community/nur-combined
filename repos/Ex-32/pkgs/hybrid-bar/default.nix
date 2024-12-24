{
  lib,
  fetchFromGitHub,
  rustPlatform,
  # build dependencies
  pkg-config,
  # run-time dependencies
  gdk-pixbuf,
  atkmm,
  pango,
  gtk3,
  gtk-layer-shell,
}:
rustPlatform.buildRustPackage rec {
  pname = "hybrid-bar";
  version = "0.4.9";

  src = fetchFromGitHub {
    owner = "vars1ty";
    repo = "HybridBar";
    rev = version;
    hash = "sha256-e9QVDDN8AtCZYuYqef1rzLJ0mklaKXzxgj+ZqGrSYEY=";
  };

  cargoHash = "sha256-9vHoa7t9XA7zuN7MLG8Q5pDae6dznYrGMKp6H8/+Iu0=";

  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    gdk-pixbuf
    atkmm
    pango
    gtk3
    gtk-layer-shell
  ];

  meta = {
    homepage = "https://github.com/vars1ty/HybridBar";
    description = "A status bar focused on wlroots Wayland compositors";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
