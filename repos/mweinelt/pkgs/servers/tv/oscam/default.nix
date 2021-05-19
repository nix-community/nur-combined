{ stdenv, lib, fetchsvn, subversion, openssl }:

stdenv.mkDerivation rec {
  pname = "oscam";
  rev = "11693";
  version = "1.20-svn${rev}";

  src = fetchsvn {
    url = "https://svn.streamboard.tv/oscam/trunk/";
    inherit rev;
    sha256 = "05fxwywykw40k9jhab7m0qjfmpzakg2pgaafp6bf8yjhzf12nlgs";
  };

  nativeBuildInputs = [ subversion ];
  buildInputs = [ openssl ];

  configurePhase = ''
    ./config.sh --enable IPV6SUPPORT
  '';

  installPhase = ''
    mkdir -p $out/{bin,share/${pname}}
    ls -lah ./Distribution
    rm -v ./Distribution/*.debug
    cp -v ./Distribution/oscam* $out/bin/oscam
    cp -rv ./Distribution/doc $out/share/${pname}
  '';

  meta = with lib; {
    description = "Open Source Conditional Access Module software";
    homepage = "http://www.streamboard.tv/oscam/";
    license = licenses.gpl3;
  };
}
