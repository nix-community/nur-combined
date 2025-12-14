{
  fetchFromGitea,
  gitUpdater,
  gtk4,
  lib,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  stdenv,
  wrapGAppsHook4,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "TODO";
  version = "0.1";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "lucaweiss";
    repo = "lpa-gtk";
    rev = finalAttrs.version;
    hash = "sha256-pbvPfGBHTHGnKAE69TSVo/hvAbI8eY/HbS7aX8sTVuE=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
  ];

  strictDeps = true;

  passthru.updateScript = gitUpdater { };

  meta = {
    homepage = "TODO";
    description = "TODO";
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
