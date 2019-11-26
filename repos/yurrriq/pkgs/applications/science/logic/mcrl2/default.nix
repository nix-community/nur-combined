{ stdenv, fetchurl, cmake, libGLU_combined, qt5, boost }:

stdenv.mkDerivation rec {
  name = "mcrl2-${version}";
  version = "201808";
  build_nr = "0";

  src = fetchurl {
    url = "https://www.mcrl2.org/download/release/mcrl2-${version}.${build_nr}.tar.gz";
    sha256 = "06409bhwfq6673l8ifmga92409cjdwi4z7w9nmb3ybd92bspapfg";
  };

  buildInputs = [ cmake libGLU_combined qt5.qtbase boost ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "A toolset for model-checking concurrent systems and protocols";
    longDescription = ''
      A formal specification language with an associated toolset,
      that can be used for modelling, validation and verification of
      concurrent systems and protocols
    '';
    homepage = https://www.mcrl2.org/;
    license = licenses.boost;
    maintainers = with maintainers; [ moretea ];
    platforms = platforms.unix;
  };
}
