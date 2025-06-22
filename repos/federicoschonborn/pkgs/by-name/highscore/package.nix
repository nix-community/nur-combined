{
  lib,
  stdenv,
  fetchFromGitLab,
  replaceVars,
  appstream,
  blueprint-compiler,
  desktop-file-utils,
  gettext,
  libxml2,
  meson,
  ninja,
  pkg-config,
  vala,
  wrapGAppsHook4,
  feedbackd,
  glib,
  gtk4,
  libadwaita,
  libarchive,
  libepoxy,
  libgee,
  libhighscore,
  libmanette-1,
  libmirage,
  libpulseaudio,
  librsvg,
  sqlite,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "highscore";
  version = "0-unstable-2025-06-22";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "World";
    repo = "highscore";
    rev = "1bf9c1955b88bc42ba5114db001af174358fc6d6";
    hash = "sha256-fP3xsbWUkyRrsgOG/0008gvyoWQ1rCOBtbNYn9nWG9w=";
  };

  patches = [
    (replaceVars ./vcs_tag.patch { inherit (finalAttrs.src) rev; })
  ];

  nativeBuildInputs = [
    appstream # appstreamcli
    blueprint-compiler
    desktop-file-utils # desktop-file-validate
    gettext
    glib # glib-compile-schemas
    gtk4 # gtk4-update-icon-cache
    libxml2 # xmllint
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    feedbackd
    glib
    gtk4
    libadwaita
    libarchive
    libepoxy
    libgee
    libhighscore
    libmanette-1
    (libmirage.overrideAttrs (
      _: prevAttrs: {
        nativeBuildInputs = (prevAttrs.nativeBuildInputs or [ ]) ++ [
          vala
        ];
      }
    ))
    libpulseaudio
    librsvg
    sqlite
  ];

  strictDeps = true;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    mainProgram = "highscore";
    description = "Retro gaming application for the GNOME desktop";
    homepage = "https://gitlab.gnome.org/World/highscore";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
