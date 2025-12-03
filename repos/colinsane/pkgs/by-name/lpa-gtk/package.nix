# 2025-10-25: package builds and launches, but with USB eSIM adapter displays error at launch:
# > No eSIM support
# > No eSIM card was detected.
# > Does your device have an eSIM chip built-in or have you inserted a removable eSIM into a physical SIM slot?
# logs say:
# > No APDU driver found
{
  appstream,
  blueprint-compiler,
  desktop-file-utils,
  fetchFromGitea,
  gitUpdater,
  gtk4,
  lib,
  libadwaita,
  lpac,
  meson,
  ninja,
  pkg-config,
  python3,
  stdenv,
  wrapGAppsHook4,
}:
let
  pythonEnv = python3.withPackages (
    ps: with ps; [
      pygobject3
    ]
  );
in
stdenv.mkDerivation rec {
  pname = "lpa-gtk";
  version = "0.3";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "lucaweiss";
    repo = "lpa-gtk";
    rev = version;
    hash = "sha256-pbvPfGBHTHGnKAE69TSVo/hvAbI8eY/HbS7aX8sTVuE=";
  };

  postPatch = ''
    substituteInPlace src/meson.build \
      --replace-fail \
        "python3 = python.find_installation('python3')" \
        "# python3 = python.find_installation('python3')" \
      --replace-fail \
        "python3.get_install_dir()" \
        "'$out/${pythonEnv.sitePackages}'" \
      --replace-fail \
        "python3.full_path()" \
        "'${lib.getExe pythonEnv}'"
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ lpac ]}
    )
  '';

  nativeBuildInputs = [
    appstream # for appstreamcli
    blueprint-compiler
    desktop-file-utils # for update-desktop-database
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
    pythonEnv
  ];

  strictDeps = true;

  passthru = {
    inherit pythonEnv;
    updateScript = gitUpdater { };
  };

  meta = {
    homepage = "https://codeberg.org/lucaweiss/lpa-gtk";
    description = "Download and manage eSIM profiles";
    maintainers = with lib.maintainers; [ colinsane ];
  };
}
