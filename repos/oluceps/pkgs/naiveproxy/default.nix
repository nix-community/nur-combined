{ stdenv
, lib
, fetchurl
, autoPatchelfHook
,
}:
stdenv.mkDerivation rec {
  pname = "naiveproxy";
  version = "111.0.5563.64-1";

  src = fetchurl {
    url = "https://github.com/klzgrad/naiveproxy/releases/download/v${version}/naiveproxy-v${version}-linux-x64.tar.xz";
    sha256 = "sha256-UejMNOX8Z0WKjNI8CRiMLzxvL+cJ3mLYenLd36jDWFs=";
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
