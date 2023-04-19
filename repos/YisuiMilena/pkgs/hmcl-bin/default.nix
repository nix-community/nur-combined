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

stdenv.mkDerivation rec {
  name = "hmcl-bin";
  version = "3.5.4.232";

  src = fetchurl {
    url = "https://github.com/huanghongxun/HMCL/releases/download/v${version}/HMCL-${version}.jar";
    sha256 = "sha256-6UCyrnTkLTM+09ulJP55AN5ChiTrcC9wLUUe1MNJw60=";
  };

  dontUnpack = true;

  icon = fetchurl {
    url = "https://aur.archlinux.org/cgit/aur.git/plain/craft_table.png?h=hmcl-bin";
    sha256 = "sha256-KYmhtTAbjHua/a5Wlsak5SRq+i1PHz09rVwZLwNqm0w";
  };

  buildInputs = [ glib ];
  nativeBuildInputs = [ jdk17 wrapGAppsHook makeWrapper copyDesktopItems ];

  installPhase = let
    libpath = with xorg; lib.makeLibraryPath ([
      libGL
      glfw
      openal
      libglvnd
    ] ++ lib.lists.optionals stdenv.isLinux [
      libX11
      libXext
      libXcursor
      libXrandr
      libXxf86vm
      libpulseaudio
      wayland
    ]);
  in ''
    runHook preInstall
    mkdir -p $out/{bin,lib/hmcl-bin}
    ln -s $src $out/lib/hmcl-bin/hmcl-bin.jar
    install -Dm644 $icon $out/share/icons/hicolor/48x48/apps/hmcl.png
    makeWrapper  ${jdk17}/bin/java $out/bin/hmcl-bin \
      --add-flags "-jar $out/lib/hmcl-bin/hmcl-bin.jar" \
      --set LD_LIBRARY_PATH ${libpath}
    runHook postInstall
  '';

  desktopItems = lib.toList (makeDesktopItem {
    name = "HMCL (bin)";
    exec = "hmcl-bin";
    icon = "hmcl";
    comment = "A Minecraft Launcher which is multi-functional, cross-platform and popular";
    desktopName = "HMCL (bin)";
    categories = [ "Game" ];
  });
}
