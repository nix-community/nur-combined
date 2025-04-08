{ appimageTools, fetchurl }:
let
  pname = "qobuz-linux";
  version = "1.0.1-6cd9e80";

  src = fetchurl {
    url = "https://github.com/mattipunkt/qobuz-linux/releases/download/1.0.1-6cd9e80/${pname}-${version}.AppImage";
    hash = "sha256-Ua1BASW5TwV35MMd5UGHYoOsUxwrTuYeiZjLmAp5ZYg=";
  };
in
appimageTools.wrapType2 {
  inherit pname version src;
}
