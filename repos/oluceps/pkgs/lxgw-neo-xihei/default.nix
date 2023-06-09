{ fetchurl
, stdenv
, lib
}:

stdenv.mkDerivation rec {
  pname = "lxgw-neo-xihei";
  version = "1.100";
  src = fetchurl {
    url = "https://github.com/lxgw/LxgwNeoXiHei/releases/download/v${version}/LXGWNeoXiHei.ttf";
    sha256 = "sha256-CQ+A0Hcpo54iaZXdoEyguSO9ACCl1khdqPaOg+QKvVA=";
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
    license = with licenses;[ mit ofl ];
    platforms = platforms.all;
  };
}
