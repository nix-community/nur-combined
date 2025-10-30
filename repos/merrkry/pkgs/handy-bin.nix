{
  appimageTools,
  fetchurl,
  lib,
}:
let
  version = "0.5.3";
  pname = "Handy";

  src = fetchurl {
    url = "https://github.com/cjpais/Handy:q
    /releases/download/v${version}/${pname}.AppImage";
    hash = "sha256-UVmLVIYcEbIuhPI94eQ9gbG/yra6WviJAOGFtE7hq90=";
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
    install -Dm444 ${appimageContents}/${pname}.desktop -t $out/share/applications
    install -Dm444 ${appimageContents}/${pname}.png -t $out/share/pixmaps
  '';

  meta = {
    description = "A modlist installation and configuration tool for Wabbajack modlists on Linux";
    homepage = "https://github.com/Omni-guides/Jackify";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ merrkry ];
    platforms = lib.platforms.linux;
  };
}
