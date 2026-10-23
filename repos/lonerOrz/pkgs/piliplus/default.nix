{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  makeWrapper,
  tree,
  imagemagick,
  webkitgtk_4_1,

  # Host libs the AppImage expects but doesn't bundle (Nix provides them explicitly).
  alsa-lib,
  atk,
  cairo,
  fontconfig,
  gdk-pixbuf,
  glib,
  gtk3,
  harfbuzz,
  libsoup_3,
  libepoxy,
  libX11,
  libXi,
  mpv-unwrapped,
  pango,
  zlib,
}:
let
  current = lib.trivial.importJSON ./version.json;

  pname = "piliplus";
  version = current.version;

  src = fetchurl {
    url = "https://github.com/bggRGjQaUbCoE/PiliPlus/releases/download/${version}/${current.asset-name}";
    hash = current.x86_64-linux-hash;
  };

  appimageContents = appimageTools.extract {
    inherit src pname version;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  nativeBuildInputs = [
    tree
    makeWrapper
    imagemagick
  ];

  extraInstallCommands = ''
    tree ${appimageContents}

    install -m 444 -D \
      ${appimageContents}/com.example.piliplus.desktop \
      $out/share/applications/com.example.piliplus.desktop

    for size in 16 24 32 48 64 128 256 512; do
      mkdir -p $out/share/icons/hicolor/"$size"x"$size"/apps
      magick ${appimageContents}/piliplus.png -background none -resize "$size"x"$size" $out/share/icons/hicolor/"$size"x"$size"/apps/piliplus.png
    done

    substituteInPlace $out/share/applications/com.example.piliplus.desktop \
      --replace-fail 'Exec=piliplus %u' 'Exec=piliplus %U'

    # Native Wayland + GPU: avoids the SwiftShader stutter from the old
    # --ozone-platform=x11 --disable-gpu combo. --force-device-scale-factor=1
    # keeps the render buffer 1:1 with the window so non-fullscreen stays sharp.
    wrapProgram $out/bin/piliplus \
      --add-flags "--ozone-platform=wayland" \
      --add-flags "--enable-features=VaapiVideoDecoder,Vulkan" \
      --add-flags "--force-device-scale-factor=1" \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          alsa-lib
          atk
          cairo
          fontconfig
          gdk-pixbuf
          glib
          gtk3
          harfbuzz
          libepoxy
          libX11
          libXi
          libsoup_3
          mpv-unwrapped
          pango
          webkitgtk_4_1
          zlib
        ]
      }"
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "A third-party Bilibili client developed in Flutter";
    homepage = "https://github.com/bggRGjQaUbCoE/PiliPlus";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "piliplus";
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
}
