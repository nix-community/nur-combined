{ lib, fetchurl, appimageTools }:
let
  pname = "frame";
  version = "0.5.0-beta.13";
  name = "${pname}-${version}";
  src = fetchurl {
    url = "https://github.com/floating/frame/releases/download/v${version}/Frame-${version}.AppImage";
    sha256 = "sha256-QdF5lVYg9v9bvqlmQFuh6LRQeUgXCPSKHRk/+zjgA8U=";
  };
in appimageTools.wrapType2 {
  name = "frame";
  inherit src;
  meta = {
    description = "System-wide Web3 for macOS, Windows and Linux";
    homepage = "https://frame.sh";
    license = lib.licenses.gpl3;
    platforms = [ "x86_64-linux" ];
  };
}
