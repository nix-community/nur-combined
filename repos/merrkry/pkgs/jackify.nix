{
  appimageTools,
  fetchurl,
}:
let
  version = "0.1.5.3";
  pname = "Jackify";
  id = "com.jackify.app";

  src = fetchurl {
    url = "https://github.com/Omni-guides/Jackify/releases/download/v${version}/${pname}.AppImage";
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
    install -Dm444 ${appimageContents}/${id}.desktop -t $out/share/applications
    install -Dm444 ${appimageContents}/${id}.png -t $out/share/pixmaps
  '';
}
