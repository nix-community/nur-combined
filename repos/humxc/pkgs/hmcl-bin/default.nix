# Base: https://github.com/nix-community/nur-combined/blob/master/repos/YisuiMilena/pkgs/hmcl-bin/default.nix
# Add xorg.libXtst
# Change desktop item
{ lib
, stdenv
, glib
, fetchurl
, makeWrapper
, wrapGAppsHook
, jdk17
, xorg
, wayland
, libpulseaudio
, libglvnd
, libGL
, dconf
, glfw
, makeDesktopItem
, copyDesktopItems
, openal
}:
let
  sources = import ./sources.nix;
in
stdenv.mkDerivation rec {
  pname = "hmcl-bin";
  version = sources.version;

  src = fetchurl {
    url = "https://github.com/HMCL-dev/HMCL/releases/download/v${version}/HMCL-${version}.jar";
    sha256 = sources.jar_hash;
  };

  dontUnpack = true;

  icon = fetchurl {
    url = "https://aur.archlinux.org/cgit/aur.git/plain/icon@8x.png?h=hmcl-bin";
    sha256 = "sha256-1OVq4ujA2ZHboB7zEk7004kYgl9YcoM4qLq154MZMGo=";
  };

  buildInputs = [ glib ];
  nativeBuildInputs = [ jdk17 wrapGAppsHook makeWrapper copyDesktopItems ];

  installPhase =
    let
      libpath = with xorg; lib.makeLibraryPath ([
        libGL
        glfw
        openal
        libglvnd
        xorg.libXtst
      ] ++ lib.lists.optionals stdenv.isLinux [
        libX11
        libXext
        libXcursor
        libXrandr
        libXxf86vm
        libpulseaudio
        wayland
      ]);
    in
    ''
      runHook preInstall
      mkdir -p $out/{bin,lib/hmcl-bin}
      ln -s $src $out/lib/hmcl-bin/hmcl-bin.jar
      install -Dm644 $icon $out/share/icons/hicolor/48x48/apps/hmcl.png
      makeWrapper  ${jdk17}/bin/java $out/bin/hmcl-bin \
        --add-flags "-jar $out/lib/hmcl-bin/hmcl-bin.jar" \
        --set LD_LIBRARY_PATH ${libpath}
      runHook postInstall
    '';
  passthru.updateScript = ./update.sh;

  meta = with lib; {
    homepage = "https://github.com/HMCL-dev/HMCL/";
    description = "HMCL is a cross-platform Minecraft launcher.";
    license = licenses.gpl3;
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
  };

  desktopItems = lib.toList (makeDesktopItem {
    name = "HMCL";
    exec = "hmcl-bin";
    icon = "hmcl";
    comment = "A Minecraft Launcher which is multi-functional, cross-platform and popular";
    desktopName = "HMCL";
    categories = [ "Game" ];
  });
}
