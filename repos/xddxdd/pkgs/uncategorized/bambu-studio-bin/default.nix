{
  fetchurl,
  lib,
  appimageTools,
  cacert,
  glib,
  glib-networking,
  gst_all_1,
  webkitgtk_4_1,
}:
let
  prNumber = builtins.match ".*_PR-([0-9]+)\\.AppImage" "02.05.02.51";
  version = if prNumber != null then builtins.head prNumber else "02.05.02.51";

  contents = appimageTools.extract {
    pname = "bambu-studio-bin";
    src = fetchurl {
      url = "https://github.com/bambulab/BambuStudio/releases/download/v02.05.02.51/BambuStudio_ubuntu-24.04_v02.05.02.51-20260327222803.AppImage";
      hash = "sha256-tWda80M3cV5hztEoYkZVGabQMgg6pyc/OniPJfghN0Q=";
    };
    inherit version;
  };
in
# https://github.com/NixOS/nixpkgs/issues/440951
appimageTools.wrapType2 {
  pname = "bambu-studio-bin";
  src = fetchurl {
    url = "https://github.com/bambulab/BambuStudio/releases/download/v02.05.02.51/BambuStudio_ubuntu-24.04_v02.05.02.51-20260327222803.AppImage";
    hash = "sha256-tWda80M3cV5hztEoYkZVGabQMgg6pyc/OniPJfghN0Q=";
  };
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
