{
  fetchurl,
  stdenv,
  lib,
}:

stdenv.mkDerivation rec {
  pname = "lxgw-neo-xihei";
  version = "1.218.1";
  src = fetchurl {
    url = "https://github.com/lxgw/LxgwNeoXiHei/releases/download/v${version}/LXGWNeoXiHei.ttf";
    hash = "sha256-ZWotvGj2LpQbi3t6mVBL8kE19JC4X6VqkIXSQSuyjR0=";
  };
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/share/fonts/truetype/
    cp $src $out/share/fonts/truetype/LXGWNeoXiHei.ttf
  '';
  meta = with lib; {
    homepage = "https://github.com/welai/glow-sans";
    description = ''
      SHSans-derived CJK font family with a more concise & modern look
    '';
    license = with licenses; [
      mit
      ofl
    ];
    platforms = platforms.all;
  };
}
