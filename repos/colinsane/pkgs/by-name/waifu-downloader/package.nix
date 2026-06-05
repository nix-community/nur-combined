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
  version = "0-unstable-2026-03-05";

  src = fetchFromGitHub {
    # fetch from the "termux" fork.
    # i thought Termux was a terminal emulator, but in fact this is still a GUI program even 6 months after the fork.
    # README talks about totally unrelated things like "doesn't use proot" (ummMMM???? when did this ever use proot???)
    # complete diff: <https://github.com/NyarchLinux/WaifuDownloader/compare/master...WOOD6563:WaifuDownloader-termux:master>
    owner = "WOOD6563";
    repo = "WaifuDownloader-termux";
    rev = "fd22a17d88a13e9d31afe51a715fc66766a7f3b4";
    hash = "sha256-OSeYhjP7+2+2EJjy/kYuOjaMrT+Spge4wWmvOgJar7k=";
  };

  patches = [
    (fetchpatch {
      name = "revert-hardcoded-shebang-pkgdatadir-localedir";
      url = "https://github.com/WOOD6563/WaifuDownloader-termux/commit/d51fb52808e57d0aa004d96b3e0c0afb4f34a97c.patch?full_index=1";
      revert = true;
      hash = "sha256-zKEZYU3rW9blmiinchjfLC9Uk7juPcWoYGU5tWjn85A=";
    })
  ];

  # patches = [
  #   (fetchpatch {
  #     name = "fix-images-to-not-be-tiny";
  #     url = "https://github.com/WOOD6563/WaifuDownloader-termux/commit/6cc0b340497a8ce7e6d17f233cd15de2a73bf16a.patch?full_index=1";
  #     hash = "sha256-bK1/C8boIj8wWtmDemCF3zFdDlR3zZAw2hGwGDtN7H4=";
  #   })
  #   (fetchpatch {
  #     name = "refactor-waifudownloaderapi";
  #     url = "https://github.com/WOOD6563/WaifuDownloader-termux/commit/864c8fab94adeae6170e0fb5e47635f69019ce7a.patch?full_index=1";
  #     hash = "sha256-Hz5ACrnYiH3dzkaIGRD5KHz6RDYUS4v+LMOEoiZoixE=";
  #   })
  #   (fetchpatch {
  #     name = "fix-save-dialog";  # also does a bunch of other stuff but hopefully inconsequential...
  #     # url = "https://github.com/NyarchLinux/WaifuDownloader/commit/fd22a17d88a13e9d31afe51a715fc66766a7f3b4.patch?full_index=1";
  #     url = "https://github.com/WOOD6563/WaifuDownloader-termux/commit/fd22a17d88a13e9d31afe51a715fc66766a7f3b4.patch?full_index=1";
  #     hash = "sha256-oQ9RhOrocb2IxbRteEwpR/NcPFwc6XA7vi2q165hD9I=";
  #   })
  # ];

  postPatch = ''
    # fix meson to use the host python when cross compiling.
    # this is a "known issue": <https://github.com/mesonbuild/meson/issues/12540>.
    # somehow `buildPythonApplication` gets around this, if one were to use that for the packaging.
    substituteInPlace src/meson.build --replace-fail \
      "python.find_installation('python3').path()" \
      "'${pythonEnv.interpreter}'"

    # place settings not at ~/.config/config.json, but subdirectory
    substituteInPlace src/preferences.py --replace-fail \
      'self.directory = GLib.get_user_config_dir()' \
      'self.directory = os.path.join(GLib.get_user_config_dir(), "waifudownloader")'
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
    updateScript = unstableGitUpdater {
      hardcodeZeroVersion = true;
    };
    # updateScript = gitUpdater { };
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
