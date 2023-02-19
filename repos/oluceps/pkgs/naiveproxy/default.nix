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
  version = "108.0.5359.94-1";

  src = fetchurl {
    url = "https://github.com/klzgrad/naiveproxy/releases/download/v${version}/naiveproxy-v${version}-linux-x64.tar.xz";
    sha256 = "sha256-4KmFTLk1HPtc8FoT1SVXG40bH0zFB3WeKAWK3ek4+sg=";
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
