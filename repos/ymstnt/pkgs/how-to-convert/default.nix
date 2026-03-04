{
  lib,
  requireFile,
  stdenvNoCC,
  autoPatchelfHook,
  dpkg,
  wrapGAppsHook3,
  cairo,
  glib,
  gst_all_1,
  gtk3,
  libsoup_3,
  openssl,
  webkitgtk_4_1,
  ffmpeg,
  pandoc,
  imagemagick,
  libreoffice,
  texliveFull,
}:

let
  pname = "how-to-convert";
  version = source.version;

  source = lib.importJSON ./source.json;

  # Binary is not distributed, it needs to be purchased from howtoconvert.co and added to the nix store.
  src = requireFile {
    name = "How.to.Convert_${version}_amd64.deb";
    hash = source.hash;
    url = "https://howtoconvert.co/";
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit pname version src;

  unpackCmd = "dpkg -x $curSrc source";

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    wrapGAppsHook3
  ];

  buildInputs = [
    cairo
    glib
    gtk3
    libsoup_3
    openssl
    webkitgtk_4_1
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : "${
        lib.makeBinPath [
          ffmpeg
          pandoc
          imagemagick
          libreoffice
          texliveFull
        ]
      }"
    )
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    cp -r usr/bin/app $out/bin/how-to-convert
    cp -r usr/share $out/share

    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;
  
  meta = {
    description = "Local file converter app";
    homepage = "https://howtoconvert.co/";
    downloadPage = "https://howtoconvert.co/dashboard";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "how-to-convert";
    platforms = [ "x86_64-linux" ];
  };
})
