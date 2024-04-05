{ 
  appimageTools
, lib
, fetchurl
, ...
}: let
  version = "1.2.3";
in appimageTools.wrapType2 {
  name = "rustdesk-${version}";

  src = fetchurl {
    url = "https://github.com/rustdesk/rustdesk/releases/download/${version}/rustdesk-${version}-x86_64.AppImage";
    sha256 = "sha256-MJqb50K8Y3mAZOcS0OuHRZh9VfdvMqjZniCJ26eweV4=";
  };

  meta = with lib; {
    description = "Virtual / remote desktop infrastructure for everyone! Open source TeamViewer / Citrix alternative";
    homepage = "https://rustdesk.com";
    license = licenses.agpl3Only;
    mainProgram = "rustdesk";
    platforms = [ "x86_64-linux" ];
  };
}
