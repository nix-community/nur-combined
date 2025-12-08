# XXX: lemonade is ALPHA. literally unusable right now. it loads the top communities from lemmy.ml, but interacting with them in any form is completely unimplemented.
# my development fork: <https://git.uninsane.org/colin/lemonade>
# difference from tip:
# - flake.nix/default.nix
# - runs outside flatpak
# - more logging
{
  desktop-file-utils,
  fetchFromGitHub,
  gitUpdater,
  gobject-introspection,
  gtk4,
  lib,
  libadwaita,
  meson,
  ninja,
  python3,
  stdenv,
  wrapGAppsHook4,
}:

let
  pyEnv = python3.withPackages (ps: with ps; [
    pygobject3
    requests
  ]);
in
stdenv.mkDerivation (final: with final; {
  pname = "lemmy-lemonade";
  version = "2024.04.22";

  src = fetchFromGitHub {
    owner = "mdwalters";
    repo = "lemonade";
    rev = version;
    hash = "sha256-Y8mU57ty7PXhCmPKByAf/nBH41NgfW97wfOfE5rWKZ0=";
  };

  postPatch = ''
    # see: <https://github.com/mdwalters/lemonade/issues/9>
    substituteInPlace src/main.py \
      --replace-fail \
        "{os.environ['XDG_RUNTIME_DIR']}/app/ml.mdwalters.Lemonade/cache" \
        "{os.environ['HOME']}/.cache/ml.mdwalters.Lemonade" \
      --replace-fail \
        'os.path.join(f"{os.environ['"'"'XDG_RUNTIME_DIR'"'"']}/app/ml.mdwalters.Lemonade", "cache")' \
        'os.path.join(f"{os.environ['"'"'HOME'"'"']}/.cache", "ml.mdwalters.Lemonade")'
  '';

  nativeBuildInputs = [
    desktop-file-utils
    gobject-introspection
    meson
    ninja
    wrapGAppsHook4
  ];
  buildInputs = [
    gtk4
    libadwaita
    pyEnv
  ];

  passthru.updateScript = gitUpdater { };

  meta = with lib; {
    description = "🍋 Follow discussions on Lemmy";
    homepage = "https://github.com/mdwalters/lemonade";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ colinsane ];
  };
})
