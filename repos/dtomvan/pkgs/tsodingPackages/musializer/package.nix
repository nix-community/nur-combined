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
  version = "alpha2-unstable-2025-05-16";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "musializer";
    rev = "332a173d3010c5e6bb0c883cd32bc0b6e5c3451f";
    hash = "sha256-UI5jkiBDeYgYwsDdnE5xg17N4FLjL7o8CeGtypXL/98=";
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
    (replaceVars ./use-nix-raylib.patch {
      RAYLIB = raylib;
      RAYLIB_SRC = raylib.src;
    })
    (replaceVars ./use-nix-nob.patch {
      RAYLIB = raylib;
      RAYLIB_SRC = raylib.src;
      NOB_H = nob_h;
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
