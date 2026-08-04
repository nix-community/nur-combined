{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  glib,
  gtk3,
  meson,
  ninja,
  pkg-config,
  libnotify,
  mate,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "brisk-menu";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "getsolus";
    repo = "brisk-menu";
    tag = "v${finalAttrs.version}";
    hash = "sha256-e7ETdVv0/9UFyfLFQiZalxCEiVaOWYq+0Cv3BTvYecU=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    desktop-file-utils # update-desktop-database
    glib # glib-compile-schemas
    gtk3 # gtk-update-icon-cache
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    gtk3
    libnotify
    mate.mate-menus
    mate.mate-panel
  ];

  strictDeps = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "An efficient menu for the MATE Desktop";
    homepage = "https://github.com/getsolus/brisk-menu";
    changelog = "https://github.com/getsolus/brisk-menu/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [
      gpl2Only
      cc-by-sa-40
    ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
