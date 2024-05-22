{
  appimageTools,
  fetchurl,
}:
appimageTools.wrapType2 rec {
  pname = "rotki";
  version = "v1.33.0";
  src = fetchurl {
    url = "https://github.com/rotki/rotki/releases/download/${version}/rotki-linux_x86_64-${version}.AppImage";
    hash = "sha256-FnVb2GzgaPCb06bF3x/pccvTyTTUXbgruisgNQxh8sY=";
  };
}
