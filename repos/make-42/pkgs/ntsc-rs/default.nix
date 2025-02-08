{
  stdenv,
  lib,
  fetchzip,
  autoPatchelfHook,
  pkgs,
}:
stdenv.mkDerivation rec {
  pname = "ntsc-rs";
  version = "0.9.0";

  dontConfigure = true;
  dontBuild = true;

  buildInputs = with pkgs; [
    at-spi2-core
    pkg-config
    glib.out
    glibc
    glow
    gtk3
    gobject-introspection
    gst_all_1.gstreamer
    # Common plugins like "filesrc" to combine within e.g. gst-launch
    gst_all_1.gst-plugins-base
    # Specialized plugins separated by quality
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    # Plugins to reuse ffmpeg to play almost every video format
    gst_all_1.gst-libav
    # Support the Video Audio (Hardware) Acceleration API
    gst_all_1.gst-vaapi
    libclang.lib
    rustPlatform.bindgenHook
    openfx.dev
    unzip
    glfw
    glm

    xorg.libxcb
    xorg.libX11.out
    xorg.libX11.dev
    xorg.libX11
    xorg.libXinerama
    libxkbcommon
  ];

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    unzip
  ];

  src = fetchzip {
    url = "https://github.com/valadaptive/ntsc-rs/releases/download/v${version}/ntsc-rs-linux-standalone.zip";
    hash = "sha256-tobTBgGMvubx0Un5sn/pqBnIm4gh56Q7ghrEWDACRFA=";
  };

  sourceRoot = ".";

  preFixup = let
    # we prepare our library path in the let clause to avoid it become part of the input of mkDerivation
    libPath = lib.makeLibraryPath (with pkgs; [
      at-spi2-core
      pkg-config
      glib.out
      glibc
      glow
      gtk3
      gobject-introspection
      gst_all_1.gstreamer
      # Common plugins like "filesrc" to combine within e.g. gst-launch
      gst_all_1.gst-plugins-base
      # Specialized plugins separated by quality
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-ugly
      # Plugins to reuse ffmpeg to play almost every video format
      gst_all_1.gst-libav
      # Support the Video Audio (Hardware) Acceleration API
      gst_all_1.gst-vaapi
      libclang.lib
      rustPlatform.bindgenHook
      openfx.dev
      unzip
      glfw
      glm

      xorg.libxcb
      xorg.libX11.out
      xorg.libX11.dev
      xorg.libX11
      xorg.libXinerama
      libxkbcommon
    ]);
  in ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath}" \
      $out/bin/ntsc-rs
  '';

  installPhase = ''
    runHook preInstall
    install -m755 -D $src/ntsc-rs-standalone $out/bin/ntsc-rs
    runHook postInstall
    runHook preFixup
  '';

  meta = with lib; {
    description = "ntsc-rs is a video effect which emulates NTSC and VHS video artifacts.";
    homepage = "https://github.com/valadaptive/ntsc-rs";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.linux;
  };
}
