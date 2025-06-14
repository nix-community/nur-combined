{ appimageTools, fetchurl }:
let
  pname = "qobuz-linux";
  version = "1.0.1-f15d602";

  src = fetchurl {
    url = "https://github.com/mattipunkt/qobuz-linux/releases/download/${version}/${pname}-${version}.AppImage";
    hash = "sha256-xJklwJ/jJ/V35XN4rA2kJZ0433jVXc4vPxzYRpFGQJA=";
  };
in
appimageTools.wrapType2 {
  inherit pname version src;
}
