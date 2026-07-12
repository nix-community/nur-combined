{
  lib,
  nob_h,
  buildNobPackage,
  fetchFromGitHub,
  nix-update-script,
  copyDesktopItems,
  makeDesktopItem,
  replaceVars,
  makeWrapper,
  ffmpeg,
  zenity,
  raylib,
  dialogProgram ? zenity,
}:
(buildNobPackage rec {
  pname = "musializer";
  version = "appimage-test-unstable-2026-06-27";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "musializer";
    rev = "4d7d2fa849ef66e94ce03a53a2e7aa3e36aa2392";
    hash = "sha256-sL9IGDJCbDKTOxngcbqWaqMpAxFi59G15R3GNjzUFus=";
  };

  desktopItems = [
    (makeDesktopItem {
      name = "musializer";
      exec = "musializer";
      comment = meta.description;
      desktopName = "Musializer";
      genericName = "Musializer";
      icon = "musializer";
    })
  ];

  # 2nd patch depends on the first one, hence sharing vars, idk what to do about that
  patches = [
    (replaceVars ./use-nix-nob.patch {
      NOB_H = nob_h;
    })
    (replaceVars ./use-nix-raylib.patch {
      NOB_H = nob_h;
      RAYLIB = raylib;
      RAYLIB_SRC = raylib.src;
    })
  ];

  buildInputs = [
    raylib
  ];

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  postInstall = ''
    wrapProgram $out/bin/musializer \
      --prefix PATH : ${
        lib.makeBinPath [
          dialogProgram
          ffmpeg
        ]
      }

    install -Dm644 resources/logo/logo-256.png $out/share/pixmaps/musializer.png
  '';

  outPaths = [ "build/musializer" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Music Visualizer";
    homepage = "https://github.com/tsoding/musializer";
    license = lib.licenses.mit;
    mainProgram = "musializer";
  };
})
