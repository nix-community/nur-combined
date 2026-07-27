{ lib,
  stdenv,
  fetchFromGitHub,

  cmake,
  gettext,
  wrapGAppsHook3,
  pkg-config,
  git,
  lsb-release,
  help2man,

  adwaita-icon-theme,
  alsa-lib,
  dav1d,
  flac,
  glib,
  gsettings-desktop-schemas,
  gtk3,
  gtksourceview4,
  lerc,
  libdatrie,
  libepoxy,
  libogg,
  libopus,
  libmpg123,
  librsvg,
  libselinux,
  libsepol,
  libsndfile,
  libsysprof-capture,
  libthai,
  libvorbis,
  libxkbcommon,
  libxml2,
  libXdmcp,
  libXtst,
  libzip,
  pcre2,
  poppler,
  portaudio,
  qpdf,
  util-linux,
  zlib,
  # plugins
  withLua ? true,
  lua5_3_compat,
}:

stdenv.mkDerivation {
  pname = "myxournalpp";
  version = "25-10-2025";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "xournalpp";
    rev = "7977a63d6ad6bce82fda10949f402833b8aea7e5";
    sha256 = "sha256-VpA2WeK+YHH1Npyw9WT6D+4WJUK6ZK3gW2Od1bLKXzE=";
  };

  nativeBuildInputs = [
    cmake
    gettext
    pkg-config
    wrapGAppsHook3
    git
    lsb-release
    help2man
  ];

  buildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [
      alsa-lib
    ]
    ++ [
      dav1d
      flac
      glib
      gsettings-desktop-schemas
      gtk3
      gtksourceview4
      lerc
      libdatrie
      libepoxy
      libmpg123
      libogg
      libopus
      librsvg
      libselinux
      libsepol
      libsndfile
      libsysprof-capture
      libthai
      libvorbis
      libxkbcommon
      libxml2
      libXdmcp
      libXtst
      libzip
      pcre2
      poppler
      portaudio
      qpdf
      util-linux
      zlib
    ]
    ++ lib.optional withLua lua5_3_compat;

  buildFlags = [ "translations" ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix XDG_DATA_DIRS : "${adwaita-icon-theme}/share"
    )
  '';

  meta = with lib; {
    description = "Xournal++ is a handwriting Notetaking software with PDF annotation support";
    homepage = "https://xournalpp.github.io/";
    changelog = "https://github.com/xournalpp/xournalpp/blob/v${version}/CHANGELOG.md";
    license = licenses.gpl2Plus;
    platforms = platforms.unix;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    mainProgram = "xournalpp";
  };
}
