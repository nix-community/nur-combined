{
  appimageTools,
  fetchurl,
}:
appimageTools.wrapType2 rec {
  pname = "rotki";
  version = "v1.34.3";
  src = fetchurl {
    url = "https://github.com/rotki/rotki/releases/download/${version}/rotki-linux_x86_64-${version}.AppImage";
    hash = "sha256-6XaF5H+WF6jdiBm3NHbI5IEzYK/wZMWrVPky0kS4msU=";
  };

  meta.platforms = [ "x86_64-linux" ];
}
