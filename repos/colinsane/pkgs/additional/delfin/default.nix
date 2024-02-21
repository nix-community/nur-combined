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
, mpv-unwrapped
, ninja
, openssl
, pkg-config
, rustc
, rustPlatform
, wrapGAppsHook4
, devBuild ? false, git
}:

stdenv.mkDerivation rec {
  pname = "delfin";
  version = "0.4.1";

  src = if devBuild then fetchFromGitea {
    domain = "git.uninsane.org";
    owner = "colin";
    repo = "delfin";
    rev = "dev-sane";
    hash = "sha256-l/Lm9dUtYfWbf8BoqNodF/5s0FzxhI/dyPevcaeyPME=";
  } else fetchFromGitea {
    domain = "codeberg.org";
    owner = "avery42";
    repo = "delfin";
    rev = "v${version}";
    hash = "sha256-LBdHWEGz6dujcF3clrJbViohgiBTyWR7Y70totimVJ8=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-TaUYqq4rkMBXhIM+0ZH6O0F+SUOpT1ImgLx2HCzJPrM=";
  };

  postPatch = ''
    substituteInPlace delfin/Cargo.toml \
      --replace-warn 'rust-version = "1.76.0"' 'rust-version = "1.75.0"'
  '' + lib.optionalString devBuild ''
    substituteInPlace video_player_mpv/sys/video-player-mpv/video-player-mpv.c \
      --replace-fail '// printf("mpv log: %s\n"' 'printf("mpv log: %s\n"'
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
  ] ++ lib.optionals devBuild [
    git
  ];

  buildInputs = [
    gtk4
    libadwaita
    libglvnd
    libepoxy
    mpv-unwrapped
    openssl
  ];

  mesonFlags = lib.optionals (!devBuild) [
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
