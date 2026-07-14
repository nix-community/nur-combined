{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkHyprlandPlugin,
  # keep-sorted end
}:
mkHyprlandPlugin {
  pluginName = "hypr-kinetic-scroll";
  version = "0-unstable-2026-07-05";

  src = fetchFromGitHub {
    owner = "savonovv";
    repo = "hypr-kinetic-scroll";
    rev = "378e29c8ec9650965fe2713d53d1fff3ce137003";
    hash = "sha256-Vt8l9PMAgcmbBynqLa91N2nW0Caij52YUYg3mWXYwSE=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm755 hypr-kinetic-scroll.so $out/lib/libhypr-kinetic-scroll.so

    runHook postInstall
  '';

  meta = {
    # keep-sorted start
    description = "Hyprland plugin providing compositor-level kinetic scrolling for touchpads";
    homepage = "https://github.com/savonovv/hypr-kinetic-scroll";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    # keep-sorted end
  };
}
