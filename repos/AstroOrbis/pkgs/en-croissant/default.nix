{
  lib,
  pkgs,
  openssl,
  libsoup_3,
  webkitgtk_4_1,
  gst_all_1,
}:
pkgs.appimageTools.wrapType2 rec {
  pname = "en-croissant";
  version = "0.15.0";

  src = pkgs.fetchurl {
    url = "https://github.com/franciscoBSalgueiro/en-croissant/releases/download/v${version}/en-croissant_${version}_amd64.AppImage";
    hash = "sha256-/Dr8n8rOYqGy3+/Qb4EDiZH/go56+m0Kt/b44mAYr/M=";
  };

  nativeBuildInputs = with pkgs; [
    makeWrapper
  ];

  buildInputs = [
    openssl
    libsoup_3
    webkitgtk_4_1
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-good
  ];

  extraInstallCommands =
    let
      contents = pkgs.appimageTools.extractType2 { inherit pname version src; };
    in
    ''
      mkdir -p "$out/share/applications" "$out/share/lib/${pname}"
      cp -r ${contents}/usr/share/* "$out/share"
      #cp "${contents}/${pname}.desktop" "$out/share/applications/"
      #substituteInPlace $out/share/applications/${pname}.desktop --replace-fail 'Exec=AppRun' 'Exec=${meta.mainProgram}'
    '';

  meta = {
    description = "Ultimate Chess Toolkit";
    homepage = "https://github.com/franciscoBSalgueiro/en-croissant/";
    license = lib.licenses.gpl3Only;
    mainProgram = "en-croissant";
    maintainers = with lib.maintainers; [ tomasajt ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };

}
