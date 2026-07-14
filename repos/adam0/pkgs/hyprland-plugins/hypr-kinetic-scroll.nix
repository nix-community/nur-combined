{
  # keep-sorted start
  fetchFromGitHub,
  hyprland,
  lib,
  mkHyprlandPlugin,
  # keep-sorted end
}: let
  release =
    if lib.versionAtLeast hyprland.version "0.55"
    then {
      version = "0.4.0";
      rev = "1e77fb637b18bcc9d1f76f54212f5881d8b9223c";
      hash = "sha256-rYhrHXLqMOkiTCgub2s9s4CXoNkTrWq9Qsggq6oGjlQ=";
    }
    else {
      version = "0.3.1";
      rev = "bcba127cb18320a3ba2418cd8282132ef147480d";
      hash = "sha256-OY1eg6KvdMGW0pXTCDOu6hZGe1HdMDdAaPxwiUaZOHg=";
    };
in
  mkHyprlandPlugin {
    pluginName = "hypr-kinetic-scroll";
    inherit (release) version;

    src = fetchFromGitHub {
      owner = "savonovv";
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
      description = "Hyprland plugin providing compositor-level kinetic scrolling for touchpads";
      homepage = "https://github.com/savonovv/hypr-kinetic-scroll";
      license = licenses.mit;
      platforms = platforms.linux;
      # keep-sorted end
    };
  }
