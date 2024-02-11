{
  lib,
  stdenv,
  fetchFromGitLab,
  desktop-file-utils,
  gtk3,
  meson,
  ninja,
  pkg-config,
  wrapQtAppsHook,
  qtwayland,
  wayland,
  nix-update-script,
}:

stdenv.mkDerivation (
  finalAttrs: {
    pname = "waycheck";
    version = "1.1.0";

    src = fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "serebit";
      repo = "waycheck";
      rev = "v${finalAttrs.version}";
      hash = "sha256-y8fuy2ed2yPRiqusMZBD7mzFBDavmdByBzEaI6P5byk=";
    };

    nativeBuildInputs = [
      desktop-file-utils
      gtk3 # gtk-update-icon-cache
      meson
      ninja
      pkg-config
      wrapQtAppsHook
    ];

    buildInputs = [
      qtwayland
      wayland
    ];

    passthru.updateScript = nix-update-script { };

    meta = {
      mainProgram = "waycheck";
      description = "Simple GUI that displays the protocols implemented by a Wayland compositor";
      homepage = "https://gitlab.freedesktop.org/serebit/waycheck";
      license = lib.licenses.asl20;
      platforms = lib.platforms.linux;
      maintainers = with lib.maintainers; [ federicoschonborn ];
    };
  }
)
