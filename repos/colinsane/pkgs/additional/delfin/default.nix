{ lib
, stdenv
, appstream
, cargo
, desktop-file-utils
, fetchFromGitea
, gitUpdater
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
, wrapGAppsHook4
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

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-jHXkpfNWs07WSnxWSEvSX6HFx3e3YOWGsYEs7lJcAds=";
  };

  # upstream pins the linker to clang, unnecessarily
  postPatch = ''
    rm .cargo/config.toml
  '';

  nativeBuildInputs = [
    appstream
    desktop-file-utils
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    cargo
    rustc
    wrapGAppsHook4
  ];

  buildInputs = [
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

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = with lib; {
    description = "stream movies and TV shows from Jellyfin";
    homepage = "https://www.delfin.avery.cafe/";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ colinsane ];
  };
}
