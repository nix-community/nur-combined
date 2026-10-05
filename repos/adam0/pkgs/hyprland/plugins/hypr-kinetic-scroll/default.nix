{
  # keep-sorted start
  fetchFromGitHub,
  hyprland,
  lib,
  mkHyprlandPlugin,
  # keep-sorted end
}: let
  # The fork needs Hyprland 0.56 headers: earlier dev outputs ship no
  # include/hyprland/protocols, so the color-management header it includes is
  # missing.
  release =
    if lib.versionAtLeast hyprland.version "0.56"
    then {
      version = "1.0.0";
      owner = "mihap";
      rev = "df9c399da0844fb1f52eaf9c002777f324e003c4";
      hash = "sha256-Iuo1HEYUgWzO+uohnKByvdIEa1fU6wl/Gk+DwrVlirE=";
    }
    else if lib.versionAtLeast hyprland.version "0.55"
    then {
      version = "0.4.0";
      owner = "savonovv";
      rev = "1e77fb637b18bcc9d1f76f54212f5881d8b9223c";
      hash = "sha256-rYhrHXLqMOkiTCgub2s9s4CXoNkTrWq9Qsggq6oGjlQ=";
    }
    else {
      version = "0.3.1";
      owner = "savonovv";
      rev = "bcba127cb18320a3ba2418cd8282132ef147480d";
      hash = "sha256-OY1eg6KvdMGW0pXTCDOu6hZGe1HdMDdAaPxwiUaZOHg=";
    };
in
  mkHyprlandPlugin {
    pluginName = "hypr-kinetic-scroll";
    inherit (release) version;

    src = fetchFromGitHub {
      inherit (release) owner;
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
