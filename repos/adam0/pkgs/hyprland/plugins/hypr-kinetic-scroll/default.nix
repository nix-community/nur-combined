{
  # keep-sorted start
  fetchFromGitHub,
  hyprland,
  lib,
  mkHyprlandPlugin,
  # keep-sorted end
}: let
  release = {
    version = "1.0.0";
    rev = "df9c399da0844fb1f52eaf9c002777f324e003c4";
    hash = "sha256-Iuo1HEYUgWzO+uohnKByvdIEa1fU6wl/Gk+DwrVlirE=";
  };
in
  mkHyprlandPlugin {
    pluginName = "hypr-kinetic-scroll";
    inherit (release) version;

    src = fetchFromGitHub {
      owner = "mihap";
      repo = "hypr-kinetic-scroll";
      inherit (release) hash rev;
    };

    installPhase = ''
      runHook preInstall

      install -Dm755 hypr-kinetic-scroll.so $out/lib/libhypr-kinetic-scroll.so

      runHook postInstall
    '';

    meta = with lib; {
      # keep-sorted start
      broken = versionOlder hyprland.version "0.53.1";
      description = "Hyprland plugin adding compositor-level kinetic (inertial) touchpad scrolling";
      homepage = "https://github.com/mihap/hypr-kinetic-scroll";
      license = licenses.mit;
      platforms = platforms.linux;
      # keep-sorted end
    };
  }
