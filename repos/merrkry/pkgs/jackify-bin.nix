{
  appimageTools,
  fetchurl,
  lib,
}:
let
  version = "0.1.6.6";
  pname = "Jackify";
  id = "com.jackify.app";

  src = fetchurl {
    url = "https://github.com/Omni-guides/Jackify/releases/download/v${version}/${pname}.AppImage";
    hash = "sha256-4BLqhmZC/ltom0rTzJpYUvHdn6WzUwS4UYo9TZAhFBI=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs =
    pkgs:
    (with pkgs; [
      icu
      zstd
    ]);

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/${id}.desktop -t $out/share/applications
    install -Dm444 ${appimageContents}/${id}.png -t $out/share/pixmaps
  '';

  meta = {
    description = "A modlist installation and configuration tool for Wabbajack modlists on Linux";
    homepage = "https://github.com/Omni-guides/Jackify";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ merrkry ];
    platforms = lib.platforms.linux;
  };
}
