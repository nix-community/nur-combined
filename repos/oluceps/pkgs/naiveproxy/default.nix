{ stdenv
, lib
, fetchurl
, pkgs
, gzip
, autoPatchelfHook
,
}:
stdenv.mkDerivation rec {
  pname = "naiveproxy";
  version = "106.0.5249.91-1";

  src = fetchurl {
    url = "https://github.com/klzgrad/naiveproxy/releases/download/v${version}/naiveproxy-v${version}-linux-x64.tar.xz";
    sha256 = "sha256-szF+Pmv1rLOYysKIXgj97we6jZrSg4ZVH2Oj3Ftrgfw=";
  };
  
  nativeBuildInputs = [
    autoPatchelfHook
  ];

  installPhase = ''
    install -m755 -D naive $out/bin/naive
  '';

  meta = with lib; {
    homepage = "https://github.com/klzgrad/naiveproxy";
    description = "naiveproxy";
    platforms = platforms.linux;
  };
}
