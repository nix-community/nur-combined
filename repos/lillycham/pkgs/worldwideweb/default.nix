{
  lib,
  stdenv,
  fetchFromGitHub,
  imagemagick,
  libicns,
}:
stdenv.mkDerivation {
  pname = "worldwideweb";
  version = "0.16-unstable-2026-11-05";

  src = fetchFromGitHub {
    owner = "lillycham";
    repo = "worldwideweb";
    rev = "c20fe99e6a6252098c928b9d095994989563bab0";
    hash = "sha256-+dTwn7qs2QBAW03oNayO9fb0L6zirzifHNswZFSVago=";
  };

  nativeBuildInputs = [
    imagemagick
    libicns
  ];

  # The Makefile calls xcrun and builds a universal binary. Nix has no xcrun
  # and builds for one architecture, so use its compiler and no -arch flags.
  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "ARCHS="
  ];

  # The Makefile makes the icon with sips and iconutil, which only macOS has.
  preBuild = ''
    mkdir -p build
    magick original/NextStep/Implementation/worldbook2.tiff \
      -resize 128x128 -background none -gravity center -extent 128x128 \
      PNG32:build/icon.png
    png2icns build/WorldWideWeb.icns build/icon.png
  '';

  # `make test` traps in the build sandbox, which has no AppKit session. It
  # passes outside the sandbox, so run it there (`make test` in the source).
  doCheck = false;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications $out/bin $out/share/doc/worldwideweb
    cp -R build/WorldWideWeb.app $out/Applications/
    ln -s $out/Applications/WorldWideWeb.app/Contents/MacOS/WorldWideWeb $out/bin/worldwideweb
    cp NOTICE README.md PORTING.md $out/share/doc/worldwideweb/
    runHook postInstall
  '';

  meta = {
    description = "Tim Berners-Lee's first web browser and editor, ported to modern macOS";
    homepage = "https://github.com/lillycham/worldwideweb";
    # The W3C/CERN notice must stay on all copies; see NOTICE.
    license = lib.licenses.w3c;
    mainProgram = "worldwideweb";
    platforms = lib.platforms.darwin;
  };
}
