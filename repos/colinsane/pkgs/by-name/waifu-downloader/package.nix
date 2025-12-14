# see also:
# - <https://github.com/Cleboost/Waifu-Generator>
# - <https://github.com/hexedrevii/CatGirlDownloader>
# - <https://github.com/Wind-Explorer/epik-waifu-downloader>
# - <https://github.com/WOOD6563/WaifuDownloader-termux> (fork, with fixes)
{
  appstream-glib,
  desktop-file-utils,
  fetchFromGitHub,
  fetchpatch,
  gitUpdater,
  gobject-introspection,
  gtk4,
  lib,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  python3,
  stdenv,
  testers,
  unstableGitUpdater,
  wrapGAppsHook4,
}:
let
  pythonEnv = python3.withPackages (ps: with ps; [
    pygobject3
    requests
  ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "waifu-downloader";
  version = "0.2.9";

  src = fetchFromGitHub {
    owner = "NyarchLinux";
    repo = "WaifuDownloader";
    rev = finalAttrs.version;
    hash = "sha256-voCmFwqY99JkeHshp75SbaZT+gAvselUtDWWz8O6oT0=";
  };

  patches = [
    (fetchpatch {
      name = "fix-images-to-not-be-tiny";
      url = "https://github.com/NyarchLinux/WaifuDownloader/commit/6cc0b340497a8ce7e6d17f233cd15de2a73bf16a.patch?full_index=1";
      hash = "sha256-bK1/C8boIj8wWtmDemCF3zFdDlR3zZAw2hGwGDtN7H4=";
    })
  ];

  # fix meson to use the host python when cross compiling.
  # this is a "known issue": <https://github.com/mesonbuild/meson/issues/12540>.
  # somehow `buildPythonApplication` gets around this, if one were to use that for the packaging.
  postPatch = ''
    substituteInPlace src/meson.build --replace-fail \
      "python.find_installation('python3').path()" \
      "'${pythonEnv.interpreter}'"
  '';

  nativeBuildInputs = [
    appstream-glib # for appstream-util
    desktop-file-utils # for update-desktop-database
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
    # pythonEnv  #< not needed as we patch it in directly
  ];

  strictDeps = true;

  passthru = {
    inherit pythonEnv;
    updateScript = gitUpdater { };
    # TODO: `waifudownloader` doesn't implement `--version` flag (only `--help`, which doesn't show version)
    # tests.version = testers.testVersion {
    #   package = finalAttrs.finalPackage;
    # };
  };

  meta = {
    homepage = "https://github.com/NyarchLinux/WaifuDownloader";
    description = "GTK4 application that downloads images of waifus based on https://waifu.im";
    maintainers = with lib.maintainers; [ colinsane ];
    mainProgram = "waifudownloader";
  };
})
