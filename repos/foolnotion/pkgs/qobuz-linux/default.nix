{ appimageTools, fetchurl }:
let
  pname = "qobuz-linux";
  version = "1.0.1-65b8d71";

  src = fetchurl {
    url = "https://github.com/mattipunkt/qobuz-linux/releases/download/${version}/${pname}-${version}.AppImage";
    hash = "sha256-2buHoGEvxthmuzWev3TK3cihho8hRHQonenJ2j0+1XU=";
  };
in
appimageTools.wrapType2 {
  inherit pname version src;
}
