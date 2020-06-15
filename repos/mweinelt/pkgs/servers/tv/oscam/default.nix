{ stdenv, lib, fetchsvn, subversion, openssl }:

stdenv.mkDerivation rec {
  pname = "oscam";
  rev = "11581";
  version = "1.20-svn${rev}";

  src = fetchsvn {
    url = "https://svn.streamboard.tv/oscam/trunk/";
    inherit rev;
    sha256 = "1kqb1xazipgh835d3hv70j3r4s74n20gkfr85zcsgx05sz6xqhbs";
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
