{ makeDesktopItem, stdenv, appimageTools, lib, fetchurl,
  cacert, glib-networking, ... }:
let
  pname = "orca-slicer";
  version = "2.0.0";
  sha256 = "sha256-PcCsqF1RKdSrbdp1jCF0n5Mu30EniaBEuJNw3XdPhO4=";
  url = "https://github.com/SoftFever/OrcaSlicer/releases/download/v${version}/OrcaSlicer_Linux_V${version}.AppImage";
  src = fetchurl {
    inherit url sha256;
  };
  extractedContents = appimageTools.extract {
    inherit pname version src;
    postExtract = ''
    substituteInPlace $out/OrcaSlicer.desktop --replace 'Exec=AppRun' 'Exec=env SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt GIO_MODULE_DIR=${glib-networking}/lib/gio/modules ${pname}'
    '';
  };
in
appimageTools.wrapType2 {
  inherit pname version src;
  name = pname;

  extraPkgs = pkgs: with pkgs; [
    webkitgtk
    gst_all_1.gstreamer # For camera streaming. TODO: need test
  ];
  extraInstallCommands = ''
                         install -m 444 -D ${extractedContents}/OrcaSlicer.desktop $out/share/applications/OrcaSlicer.desktop
                         install -m 444 -D ${extractedContents}/usr/share/icons/hicolor/192x192/apps/OrcaSlicer.png \
                           $out/share/icons/hicolor/192x192/apps/OrcaSlicer.png
                         '';

  meta = with lib; {
    description = "G-code generator for 3D printers (Bambu, Prusa, Voron, VzBot, RatRig, Creality, etc.)";
    homepage = "https://github.com/SoftFever/OrcaSlicer";
    license = licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
  };
}
