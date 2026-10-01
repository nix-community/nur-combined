{ lib
, stdenv
, sources
, dpkg
, autoPatchelfHook
, makeWrapper
, desktop-file-utils
, shared-mime-info

, gdk-pixbuf
, glib
, gtk3
, libsoup_3
, webkitgtk_4_1
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "astrobox";
  inherit (sources.astrobox) version src;

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    gdk-pixbuf
    glib
    gtk3
    libsoup_3
    webkitgtk_4_1
  ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec $out/share/applications
    install -Dm755 usr/bin/AstroBox-ng $out/libexec/AstroBox-ng
    cp -r usr/share/icons $out/share/
    cp usr/share/applications/AstroBox.desktop $out/share/applications/

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper $out/libexec/AstroBox-ng $out/bin/AstroBox-ng \
      --prefix PATH : ${lib.makeBinPath [ desktop-file-utils shared-mime-info ]}
  '';

  meta = with lib; {
    description = "Multifunctional toolbox designed for Xiaomi Vela wearable devices";
    homepage = "https://github.com/AstralSightStudios/AstroBox-NG";
    changelog = "https://github.com/AstralSightStudios/AstroBox-NG/releases/tag/v${finalAttrs.version}";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    license = licenses.unfree;
    mainProgram = "AstroBox-ng";
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
})
