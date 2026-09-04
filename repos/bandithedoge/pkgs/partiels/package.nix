{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  copyDesktopItems,
  git,
  juceCmakeHook,
  libjack2,
  libxi,
  makeDesktopItem,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "partiels";
  version = "2.5.1";
  src = fetchFromGitHub {
    owner = "Ircam-Partiels";
    repo = "Partiels";
    rev = finalAttrs.version;
    hash = "sha256-6dUmG64rhRylwLhy/PcEGwHHxU4jeXhEuag/npw5OJI=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    copyDesktopItems
    git
    juceCmakeHook
  ];

  buildInputs = [
    libjack2
    libxi
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/vamp}
    cp -r Partiels $out/libexec

    ln -s $out/libexec/Partiels $out/bin/Partiels
    ln -s $out/libexec/PlugIns/* $out/lib/vamp

    mkdir -p $out/share/icons/hicolor/512x512/apps
    ln -s $out/libexec/icon.png $out/share/icons/hicolor/512x512/apps/partiels.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "Partiels";
      exec = "Partiels";
      desktopName = "Partiels";
      categories = [ "Audio" ];
      icon = "partiels";
    })
  ];

  NIX_CFLAGS_COMPILE = [ "-Wno-error=format-security" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--use-github-releases" ]; };

  meta = {
    description = "Partiels is an audio analysis application that allow you to explore the content and characteristics of sounds";
    homepage = "https://github.com/Ircam-Partiels/Partiels";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "Partiels";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
