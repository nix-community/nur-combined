{
  webkitgtk_6_0,
  libpulseaudio,
  vulkan-loader,
  libxkbcommon,
  stdenvNoCC,
  fontconfig,
  libXcursor,
  gst_all_1,
  libXrandr,
  fetchurl,
  alsa-lib,
  freetype,
  pipewire,
  libglvnd,
  wayland,
  libX11,
  unzip,
  libXi,
  gtk4,
  dbus,
  zlib,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "serein";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);
  inherit (ver) version;

  meta = {
    description = "Tiny, performant & 100% native client for Discord made in Rust";
    homepage = "https://github.com/ViceVerse-cz/Serein";
    changelog = "https://github.com/ViceVerse-cz/Serein/releases/tag/v${version}";
    license = with lib.licenses; [mit asl20];
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.darwin ++ ["x86_64-linux"];
    mainProgram = "serein";
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [unzip];
    })
  else
    lib.helper.mkAppImage {
      inherit pname version src meta;

      desktopId = "cz.viceverse.serein";
      desktopName = "Serein";
      startupWMClass = "cz.viceverse.serein";
      categories = [
        "Network"
        "InstantMessaging"
      ];

      extraPkgs = [
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-libav
        gst_all_1.gstreamer
        webkitgtk_6_0
        libpulseaudio
        vulkan-loader
        libxkbcommon
        fontconfig
        libXcursor
        libXrandr
        alsa-lib
        freetype
        pipewire
        libglvnd
        wayland
        libX11
        libXi
        gtk4
        dbus
        zlib
      ];
    }
