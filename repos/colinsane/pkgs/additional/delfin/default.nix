{ lib
, stdenv
, appstream
, cargo
, desktop-file-utils
, fetchFromGitea
, gtk4
, libadwaita
, libglvnd
, libepoxy
, meson
, mpv
, ninja
, openssl
, pkg-config
, rustc
, rustPlatform
}:

stdenv.mkDerivation rec {
  pname = "delfin";
  version = "0.2.1";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "avery42";
    repo = "delfin";
    rev = "v${version}";
    hash = "sha256-jkNMioh0NkUMQYnzGveYVu9Vn8k2Zv5sDog8C58DJ6M=";
  };

  # cargoHash = "sha256-jHXkpfNWs07WSnxWSEvSX6HFx3e3YOWGsYEs7lJcAds=";
  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-jHXkpfNWs07WSnxWSEvSX6HFx3e3YOWGsYEs7lJcAds=";
  };


  nativeBuildInputs = [
    desktop-file-utils
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];

  buildInputs = [
    appstream
    gtk4
    libadwaita
    libglvnd
    libepoxy
    mpv
    openssl
  ];

  mesonFlags = [
    "-Dprofile=release"
  ];

  # upstream pins the linker to clang, unnecessarily
  postPatch = ''
    rm .cargo/config.toml
  '';

  meta = with lib; {
    description = "stream movies and TV shows from Jellyfin";
    homepage = "https://www.delfin.avery.cafe/";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ colinsane ];
  };
}
