{ stdenv } :
let
  version = "";
in stdenv.mkDerivation {
  name = "XPKG-${version}";

  src = fetch {
    sha256 = "1iy810paf3fsr2230nrcrcskpqj376mw39fl0qbhr4a7hlrqj6yp";
  };

  nativeBuildInputs = [ ];
  buildInputs = [ ];

  meta = with stdenv.lib; {
    description = "";
    homepage = https://;
    license = licenses.;
    maintainers = [  ];
    platforms = platforms.linux;
  };
}

