{ lib
, stdenv
, fetchFromGitLab
, blueprint-compiler
, desktop-file-utils
, gettext
, libadwaita
, meson
, ninja
, pkg-config
, vala
, wrapGAppsHook4
, nix-update-script
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "blurble";
  version = "0.4.0";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "World";
    repo = "Blurble";
    rev = "v${finalAttrs.version}";
    hash = "sha256-wxj+wyD09ueU6p/6Tc7ISI/oLre41DhGVhjsACDsmpE=";
  };

  nativeBuildInputs = [
    blueprint-compiler
    desktop-file-utils
    gettext
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    libadwaita
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "blurble";
    description = "Word guessing game";
    homepage = "https://gitlab.gnome.org/World/Blurble";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
