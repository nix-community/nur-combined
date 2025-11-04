{
  appimageTools,
  fetchurl,
  lib,
}:
let
  version = "0.5.5";
  pname = "Handy";

  src = fetchurl {
    url = "https://github.com/cjpais/Handy/releases/download/v${version}/${pname}.AppImage";
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
    description = "A free, open source, and extensible speech-to-text application that works completely offline.";
    homepage = "https://github.com/cjpais/Handy";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ merrkry ];
    platforms = lib.platforms.linux;
  };
}
