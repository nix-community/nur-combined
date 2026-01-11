{
  sources,
  lib,
  appimageTools,
  cacert,
  glib,
  glib-networking,
  gst_all_1,
  webkitgtk_4_1,
}:
let
  prNumber = builtins.match ".*_PR-([0-9]+)\\.AppImage" sources.bambu-studio-bin.version;
  version = if prNumber != null then builtins.head prNumber else sources.bambu-studio-bin.version;

  contents = appimageTools.extract {
    inherit (sources.bambu-studio-bin) pname src;
    inherit version;
  };
in
# https://github.com/NixOS/nixpkgs/issues/440951
appimageTools.wrapType2 {
  inherit (sources.bambu-studio-bin) pname src;
  inherit version;

  profile = ''
    export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
    export GIO_MODULE_DIR="${glib-networking}/lib/gio/modules/"
  '';

  extraPkgs = pkgs: [
    cacert
    glib
    glib-networking
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    webkitgtk_4_1
  ];

  extraInstallCommands = ''
    install -Dm644 ${contents}/BambuStudio.desktop $out/share/applications/bambu-studio.desktop
    substituteInPlace $out/share/applications/bambu-studio.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=bambu-studio-bin' \
      --replace-fail 'Icon=BambuStudio' 'Icon=bambu-studio'
    install -Dm644 ${contents}/BambuStudio.png $out/share/pixmaps/bambu-studio.png
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "PC Software for BambuLab and other 3D printers";
    homepage = "https://github.com/bambulab/BambuStudio";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "bambu-studio-bin";
  };
}
